
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

@WebServlet("/admin/borrow-request-action")
public class AdminBorrowRequestController extends HttpServlet {

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

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // ALLOW ONLY ADMIN ACCOUNTS
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // VALIDATE THE REQUEST ID
        int requestId;

        try {
            requestId = Integer.parseInt(request.getParameter("requestId"));

            if (requestId <= 0) {
                response.sendRedirect(
                        contextPath
                        + "/admin/borrow-requests?requestResult=invalid");
                return;
            }

        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect(
                    contextPath
                    + "/admin/borrow-requests?requestResult=invalid");
            return;
        }

        // READ THE ADMIN ACTION
        String action = request.getParameter("action");

        if (action == null
                || (!"approve".equals(action)
                && !"reject".equals(action))) {

            response.sendRedirect(
                    contextPath
                    + "/admin/borrow-requests?requestResult=invalid");
            return;
        }

        boolean success;

        if ("approve".equals(action)) {

            // APPROVE THE BORROW REQUEST
            success = borrowDAO.approveBorrowRequest(
                    requestId,
                    loggedInUser.getUserId()
            );

            response.sendRedirect(
                    contextPath + "/admin/borrow-requests?requestResult="
                    + (success ? "approved" : "unavailable")
            );

        } else {

            // REQUIRE A REASON WHEN REJECTING
            String rejectionReason =
                    request.getParameter("rejectionReason");

            if (rejectionReason == null
                    || rejectionReason.trim().isEmpty()) {

                response.sendRedirect(
                        contextPath
                        + "/admin/borrow-requests?requestResult=reasonRequired");
                return;
            }

            rejectionReason = rejectionReason.trim();

            if (rejectionReason.length() > 500) {
                rejectionReason = rejectionReason.substring(0, 500);
            }

            // REJECT THE BORROW REQUEST
            success = borrowDAO.rejectBorrowRequest(
                    requestId,
                    loggedInUser.getUserId(),
                    rejectionReason
            );

            response.sendRedirect(
                    contextPath + "/admin/borrow-requests?requestResult="
                    + (success ? "rejected" : "unavailable")
            );
        }
    }
}
