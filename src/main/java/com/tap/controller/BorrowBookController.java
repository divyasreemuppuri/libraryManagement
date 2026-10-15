
package com.tap.controller;

import java.io.IOException;

import com.tap.dao.BorrowDAO;
import com.tap.daoimpl.BorrowDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/borrow-book")
public class BorrowBookController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BorrowDAO borrowDAO;

    @Override
    public void init() throws ServletException {
        borrowDAO = new BorrowDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        // CHECK WHETHER THE USER IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // ALLOW ONLY NORMAL USER ACCOUNTS
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(contextPath + "/admin-dashboard");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            return;
        }

        // VALIDATE THE BOOK ID
        int bookId;

        try {
            bookId = Integer.parseInt(request.getParameter("bookId"));

            if (bookId <= 0) {
                response.sendRedirect(
                        contextPath + "/user/books?borrowResult=invalid");
                return;
            }
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect(
                    contextPath + "/user/books?borrowResult=invalid");
            return;
        }

        // SUBMIT A BORROW REQUEST FOR ADMIN APPROVAL
        boolean success = borrowDAO.submitBorrowRequest(
                loggedInUser.getUserId(), bookId);

        if (success) {
            response.sendRedirect(
                    contextPath + "/user/books?borrowResult=requested");
        } else {
            response.sendRedirect(
                    contextPath + "/user/books?borrowResult=unavailable");
        }
    }
}
