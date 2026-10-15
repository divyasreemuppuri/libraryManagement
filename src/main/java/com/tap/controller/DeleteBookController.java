
package com.tap.controller;

import java.io.IOException;

import com.tap.dao.BookDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/delete-book")
public class DeleteBookController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // REUSE THE EXISTING BOOK DAO
    private final BookDAO bookDAO = new BookDAOImpl();

    // PROCESS THE BOOK DELETION REQUEST
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // VERIFY THAT AN ADMIN IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = session == null ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Admin privileges are required.");
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

        // DELETE THE BOOK USING THE EXISTING DAO METHOD
        boolean deleted = bookDAO.deleteBook(bookId);

        if (deleted) {
            response.sendRedirect(
                    request.getContextPath() + "/admin/books?result=deleted");
        } else {
            response.sendRedirect(
                    request.getContextPath() + "/admin/books?result=deletefailed");
        }
    }
}
