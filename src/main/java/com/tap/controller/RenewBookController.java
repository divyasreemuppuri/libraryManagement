
package com.tap.controller;

import java.io.IOException;

import com.tap.dao.BorrowDAO;
import com.tap.daoimpl.BorrowDAOImpl;
import com.tap.model.Borrow;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/renew-book")
public class RenewBookController extends HttpServlet {

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

        // ALLOW ONLY NORMAL USERS TO REQUEST RENEWALS
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(contextPath + "/admin-dashboard");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            return;
        }

        // ALLOW ONLY APPROVED USERS TO REQUEST RENEWALS
        if (loggedInUser.getStatus() == null
                || !"APPROVED".equalsIgnoreCase(loggedInUser.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // VALIDATE THE BORROWING RECORD ID
        int borrowId;

        try {
            borrowId = Integer.parseInt(request.getParameter("borrowId"));

            if (borrowId <= 0) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?renewResult=invalid");
                return;
            }
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect(
                    contextPath + "/user/borrowings?renewResult=invalid");
            return;
        }

        try {
            int userId = loggedInUser.getUserId();

            // VERIFY THAT THE BORROWING RECORD BELONGS TO THIS USER
            Borrow borrow = borrowDAO.getBorrowById(borrowId);

            if (borrow == null || borrow.getUserId() != userId) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?renewResult=invalid");
                return;
            }

            // ALLOW REQUESTS FOR BORROWED OR OVERDUE BOOKS
            String status = borrow.getStatus();

            if (status == null
                    || (!"BORROWED".equalsIgnoreCase(status)
                    && !"OVERDUE".equalsIgnoreCase(status))) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?renewResult=unavailable");
                return;
            }

            // SUBMIT A RENEWAL REQUEST FOR ADMIN APPROVAL
            // THE DAO MUST CHECK THE FIVE-DAY WINDOW AND PENDING REQUESTS
            boolean submitted = borrowDAO.submitRenewalRequest(
                    borrowId, userId);

            if (submitted) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?renewResult=requested");
            } else {
                response.sendRedirect(
                        contextPath + "/user/borrowings?renewResult=unavailable");
            }

        } catch (Exception e) {
            getServletContext().log("ERROR SUBMITTING RENEWAL REQUEST", e);

            response.sendRedirect(
                    contextPath + "/user/borrowings?renewResult=error");
        }
    }
}
