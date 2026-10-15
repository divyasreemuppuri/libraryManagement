
package com.tap.controller;

import java.io.IOException;
import java.util.List;

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

@WebServlet("/user/books")
public class UserBooksController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookDAO bookDAO;

    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
                         throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = session == null
                ? null
                : (User) session.getAttribute("loggedInUser");

        // CHECK WHETHER THE USER IS LOGGED IN.
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ALLOW ONLY NORMAL USERS TO ACCESS THIS PAGE.
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {

            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(
                    request.getContextPath() + "/admin-dashboard"
                );
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }

            return;
        }

        try {
            // RETRIEVE ALL BOOKS USING THE EXISTING DAO.
            List<Book> allBooks = bookDAO.getAllBooks();

            // MAKE THE BOOK LIST AVAILABLE TO THE JSP.
            request.setAttribute("allBooks", allBooks);

            // CONFIGURE THE SHARED USER LAYOUT.
            request.setAttribute("pageTitle", "Browse Books");
            request.setAttribute(
                "pageSubtitle",
                "Explore the books in your library"
            );
            request.setAttribute("activePage", "books");
            request.setAttribute(
                "contentPage",
                "/user/books-content.jsp"
            );

            // DISPLAY THE BOOKS INSIDE THE EXISTING SHARED LAYOUT.
            request.getRequestDispatcher("/user/user-layout.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            getServletContext().log("ERROR LOADING USER BOOKS", e);

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Unable to load books. Please try again."
            );
        }
    }
}
