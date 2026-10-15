
package com.tap.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import com.tap.dao.BookDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.model.Book;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// UPDATED: MAP THE CONTROLLER TO THE LANDING PAGE
@WebServlet("/home")
public class BookController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookDAO bookDAO;

    // ADDED: INITIALIZE THE EXISTING BOOK DAO
    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAOImpl();
    }

    // UPDATED: LOAD FEATURED BOOKS OR SEARCH RESULTS
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // ADDED: GET THE SEARCH TERM FROM THE URL
        String searchTerm = request.getParameter("query");

        // ADDED: RETRIEVE ALL BOOKS FROM THE DATABASE
        List<Book> allBooks = bookDAO.getAllBooks();

        if (allBooks == null) {
            allBooks = new ArrayList<>();
        }

        // ADDED: CALCULATE LIBRARY STATISTICS
        int totalBooks = 0;
        int availableCopies = 0;

        for (Book book : allBooks) {
            totalBooks += book.getTotalCopies();
            availableCopies += book.getAvailableCopies();
        }

        // ADDED: SEARCH THE COMPLETE DATABASE WHEN A TERM IS PROVIDED
        List<Book> displayedBooks;

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {

            searchTerm = searchTerm.trim();

            displayedBooks = new ArrayList<>(
                bookDAO.searchBooksByTitle(searchTerm)
            );

            // ADDED: INCLUDE CATEGORY MATCHES WITHOUT DUPLICATES
            List<Book> categoryResults =
                bookDAO.searchBooksByCategory(searchTerm);

            for (Book book : categoryResults) {

                boolean alreadyExists = false;

                for (Book existingBook : displayedBooks) {
                    if (existingBook.getBookId() == book.getBookId()) {
                        alreadyExists = true;
                        break;
                    }
                }

                if (!alreadyExists) {
                    displayedBooks.add(book);
                }
            }

        } else {

            // ADDED: SHOW THE SIX NEWEST BOOKS BY DEFAULT
            displayedBooks = allBooks.stream()
                .sorted(
                    Comparator.comparingInt(Book::getBookId).reversed()
                )
                .limit(6)
                .collect(Collectors.toList());
        }

        // ADDED: SEND BOOKS AND STATISTICS TO index.jsp
        request.setAttribute("featuredBooks", displayedBooks);
        request.setAttribute("totalBooks", totalBooks);
        request.setAttribute("availableCopies", availableCopies);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("isSearch", 
            searchTerm != null && !searchTerm.trim().isEmpty());

        // ADDED: DISPLAY THE SAME LANDING PAGE
        request.getRequestDispatcher("/index.jsp")
               .forward(request, response);
    }
}

