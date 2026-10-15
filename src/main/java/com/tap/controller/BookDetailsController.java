
package com.tap.controller;

import java.io.IOException;

import com.tap.dao.BookDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.model.Book;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// ADDED: MAP THE CONTROLLER TO THE BOOK DETAILS URL
@WebServlet("/book-details")
public class BookDetailsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ADDED: USE THE EXISTING BOOK DAO
    private BookDAO bookDAO;

    // ADDED: INITIALIZE THE DAO
    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAOImpl();
    }

    // ADDED: FETCH AND DISPLAY THE SELECTED BOOK
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // ADDED: READ THE BOOK ID FROM THE REQUEST
        String bookIdParameter = request.getParameter("bookId");

        // ADDED: VALIDATE THE BOOK ID
        if (bookIdParameter == null || bookIdParameter.trim().isEmpty()) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Book ID is required."
            );
            return;
        }

        int bookId;

        try {
            bookId = Integer.parseInt(bookIdParameter);
        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid book ID."
            );
            return;
        }

        // ADDED: FETCH THE BOOK USING THE EXISTING DAO METHOD
        Book book = bookDAO.getBookById(bookId);

        // ADDED: HANDLE A BOOK THAT DOES NOT EXIST
        if (book == null) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Book not found."
            );
            return;
        }

        // ADDED: PASS THE BOOK TO THE JSP
        request.setAttribute("book", book);

        // ADDED: FORWARD THE REQUEST TO THE BOOK DETAILS PAGE
        request.getRequestDispatcher("/book-details.jsp")
               .forward(request, response);
    }
}

