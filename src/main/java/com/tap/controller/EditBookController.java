package com.tap.controller;

import java.io.IOException;

import com.tap.dao.BookDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.model.Book;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/edit-book")
public class EditBookController extends HttpServlet {

private static final long serialVersionUID = 1L;

// USE THE EXISTING BOOK DAO
private final BookDAO bookDAO = new BookDAOImpl();

// DISPLAY THE EDIT BOOK FORM
@Override
protected void doGet(HttpServletRequest request,
                     HttpServletResponse response)
        throws ServletException, IOException {

    // VERIFY ADMIN ACCESS
    if (!isAdmin(request, response)) {
        return;
    }

    // VALIDATE THE BOOK ID
    int bookId;

    try {
        bookId = Integer.parseInt(request.getParameter("bookId"));
        if (bookId <= 0) {
            throw new NumberFormatException();
        }
    } catch (NumberFormatException e) {
        response.sendRedirect(
                request.getContextPath() + "/admin/books?result=invalid");
        return;
    }

    // FETCH THE EXISTING BOOK
    Book book = bookDAO.getBookById(bookId);

    if (book == null) {
        response.sendRedirect(
                request.getContextPath() + "/admin/books?result=notfound");
        return;
    }

    // PASS THE BOOK TO THE EDIT FORM
    request.setAttribute("book", book);

    // CONFIGURE THE SHARED ADMIN LAYOUT
    setEditBookPageAttributes(request);

    // DISPLAY THE FORM INSIDE THE SHARED LAYOUT
    request.getRequestDispatcher("/admin-layout.jsp")
           .forward(request, response);
}

// PROCESS THE UPDATED BOOK DETAILS
@Override
protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
        throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    // VERIFY ADMIN ACCESS
    if (!isAdmin(request, response)) {
        return;
    }

    int bookId;

    try {
        bookId = Integer.parseInt(request.getParameter("bookId"));
        if (bookId <= 0) {
            throw new NumberFormatException();
        }
    } catch (NumberFormatException e) {
        response.sendRedirect(
                request.getContextPath() + "/admin/books?result=invalid");
        return;
    }

    // FETCH THE CURRENT DATABASE RECORD
    Book existingBook = bookDAO.getBookById(bookId);

    if (existingBook == null) {
        response.sendRedirect(
                request.getContextPath() + "/admin/books?result=notfound");
        return;
    }

    try {
        // READ THE FORM VALUES
        String title = getParameter(request, "title");
        String author = getParameter(request, "author");
        String category = getParameter(request, "category");
        String isbn = getParameter(request, "isbn");
        String publisher = getParameter(request, "publisher");
        String yearText = getParameter(request, "publishedYear");
        String copiesText = getParameter(request, "totalCopies");
        String description = getParameter(request, "description");
        String image = getParameter(request, "image");

        // VALIDATE REQUIRED FIELDS
        if (title.isEmpty() || author.isEmpty()
                || category.isEmpty() || isbn.isEmpty()
                || copiesText.isEmpty()) {

            showError(request, response, existingBook,
                    "Please fill in all required book details.");
            return;
        }

        // VALIDATE FIELD LENGTHS
        if (title.length() > 200 || author.length() > 150
                || category.length() > 100 || isbn.length() > 20
                || publisher.length() > 150 || image.length() > 1000) {

            showError(request, response, existingBook,
                    "One or more fields exceed the allowed length.");
            return;
        }

        // VALIDATE PUBLICATION YEAR
        int publishedYear = 0;

        if (!yearText.isEmpty()) {
            publishedYear = Integer.parseInt(yearText);

            if (publishedYear < 1 || publishedYear > 9999) {
                showError(request, response, existingBook,
                        "Please enter a valid publication year.");
                return;
            }
        }

        // VALIDATE TOTAL COPIES
        int totalCopies = Integer.parseInt(copiesText);

        if (totalCopies < 1 || totalCopies > 10000) {
            showError(request, response, existingBook,
                    "Total copies must be between 1 and 10000.");
            return;
        }

        // PRESERVE THE NUMBER OF COPIES CURRENTLY BORROWED
        int borrowedCopies = existingBook.getTotalCopies()
                - existingBook.getAvailableCopies();

        if (totalCopies < borrowedCopies) {
            showError(request, response, existingBook,
                    "Total copies cannot be less than the number of books currently borrowed ("
                            + borrowedCopies + ").");
            return;
        }

        // UPDATE THE EXISTING MODEL
        existingBook.setTitle(title);
        existingBook.setAuthor(author);
        existingBook.setCategory(category);
        existingBook.setIsbn(isbn);
        existingBook.setPublisher(publisher);
        existingBook.setPublishedYear(publishedYear);
        existingBook.setTotalCopies(totalCopies);

        // KEEP BORROWED COPIES UNCHANGED
        existingBook.setAvailableCopies(totalCopies - borrowedCopies);

        existingBook.setDescription(description);
        existingBook.setImage(image);

        // SAVE CHANGES USING THE EXISTING DAO METHOD
        boolean updated = bookDAO.updateBook(existingBook);

        if (updated) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/admin/books?result=updated");
            return;
        }

        showError(request, response, existingBook,
                "The book could not be updated. Check whether the ISBN already exists.");

    } catch (NumberFormatException e) {
        showError(request, response, existingBook,
                "Enter valid numbers for the publication year and total copies.");
    }
}

// CONFIGURE THE SHARED ADMIN LAYOUT
private void setEditBookPageAttributes(HttpServletRequest request) {
    request.setAttribute("pageTitle", "Edit Book");
    request.setAttribute("pageSubtitle",
            "Update the details of an existing book");
    request.setAttribute("activePage", "books");
    request.setAttribute("adminContent", "/edit-book.jsp");
}

// VERIFY THAT THE CURRENT USER IS AN ADMIN
private boolean isAdmin(HttpServletRequest request,
                        HttpServletResponse response)
        throws IOException {

    HttpSession session = request.getSession(false);

    User user = session == null ? null
            : (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return false;
    }

    if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Admin privileges are required.");
        return false;
    }

    return true;
}

// SAFELY READ FORM PARAMETERS
private String getParameter(HttpServletRequest request, String name) {
    String value = request.getParameter(name);
    return value == null ? "" : value.trim();
}

// SHOW VALIDATION ERRORS WITHIN THE SHARED ADMIN LAYOUT
private void showError(HttpServletRequest request,
                       HttpServletResponse response,
                       Book book,
                       String message)
        throws ServletException, IOException {

    request.setAttribute("book", book);
    request.setAttribute("errorMessage", message);

    setEditBookPageAttributes(request);

    request.getRequestDispatcher("/admin-layout.jsp")
           .forward(request, response);
}

}
