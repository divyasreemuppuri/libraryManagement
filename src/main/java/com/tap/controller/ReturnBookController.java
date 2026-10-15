
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

@WebServlet("/return-book")
public class ReturnBookController extends HttpServlet {

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

        // ALLOW ONLY NORMAL USERS TO RETURN THEIR BOOKS
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(contextPath + "/admin-dashboard");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            return;
        }

        // VALIDATE THE BORROWING RECORD ID
        int borrowId;

        try {
            borrowId = Integer.parseInt(request.getParameter("borrowId"));

            if (borrowId <= 0) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?returnResult=invalid");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    contextPath + "/user/borrowings?returnResult=invalid");
            return;
        }

        try {
            int userId = loggedInUser.getUserId();

            // VERIFY THAT THE BORROWING RECORD BELONGS TO THIS USER
            Borrow borrow = borrowDAO.getBorrowById(borrowId);

            if (borrow == null || borrow.getUserId() != userId) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?returnResult=invalid");
                return;
            }

            // RETURN THE BOOK ONLY IF THE RECORD IS STILL ACTIVE
            String status = borrow.getStatus();

            if (status == null
                    || !("BORROWED".equalsIgnoreCase(status)
                    || "OVERDUE".equalsIgnoreCase(status))) {

                response.sendRedirect(
                        contextPath + "/user/borrowings?returnResult=unavailable");
                return;
            }

            boolean returned = borrowDAO.returnBook(borrowId);

            if (returned) {
                response.sendRedirect(
                        contextPath + "/user/borrowings?returnResult=success");
            } else {
                response.sendRedirect(
                        contextPath + "/user/borrowings?returnResult=unavailable");
            }

        } catch (Exception e) {
            getServletContext().log("ERROR RETURNING BOOK", e);

            response.sendRedirect(
                    contextPath + "/user/borrowings?returnResult=error");
        }
    }
}
