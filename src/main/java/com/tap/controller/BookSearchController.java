
package com.tap.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.BookDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.model.Book;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// ADDED: MAP THE BOOK SEARCH CONTROLLER
@WebServlet("/search-books")
public class BookSearchController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookDAO bookDAO;

    // ADDED: INITIALIZE THE EXISTING BOOK DAO
    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAOImpl();
    }

    // ADDED: SEARCH ALL BOOKS IN THE DATABASE
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // ADDED: GET THE SEARCH TERM
        String searchTerm = request.getParameter("query");

        List<Book> searchResults = new ArrayList<>();

        // ADDED: SEARCH BY TITLE AND CATEGORY
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {

            searchTerm = searchTerm.trim();

            searchResults.addAll(
                bookDAO.searchBooksByTitle(searchTerm)
            );

            // ADDED: INCLUDE CATEGORY MATCHES WITHOUT DUPLICATES
            for (Book book : bookDAO.searchBooksByCategory(searchTerm)) {

                boolean alreadyAdded = false;

                for (Book existingBook : searchResults) {
                    if (existingBook.getBookId() == book.getBookId()) {
                        alreadyAdded = true;
                        break;
                    }
                }

                if (!alreadyAdded) {
                    searchResults.add(book);
                }
            }
        }

        // ADDED: SEND RESULTS TO THE SEARCH RESULTS PAGE
        request.setAttribute("searchResults", searchResults);
        request.setAttribute("searchTerm", searchTerm);

        request.getRequestDispatcher("/search-results.jsp")
               .forward(request, response);
    }
}

