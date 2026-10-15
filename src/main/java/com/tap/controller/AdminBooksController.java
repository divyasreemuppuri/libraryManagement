
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

@WebServlet("/admin/books")
public class AdminBooksController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // USE THE EXISTING BOOK DAO
    private final BookDAO bookDAO = new BookDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        // REDIRECT UNAUTHENTICATED USERS TO LOGIN
        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        // BLOCK NON-ADMIN USERS
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Admin privileges are required.");
            return;
        }

        // LOAD ALL BOOKS
        List<Book> books = bookDAO.getAllBooks();
        request.setAttribute("books", books);

        // CONFIGURE THE SHARED ADMIN LAYOUT
        request.setAttribute("pageTitle", "Manage Books");
        request.setAttribute("pageSubtitle",
                "View and manage the library collection");
        request.setAttribute("activePage", "books");
        request.setAttribute("adminContent", "/admin-books.jsp");

        // DISPLAY THE BOOKS CONTENT INSIDE THE SHARED LAYOUT
        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}