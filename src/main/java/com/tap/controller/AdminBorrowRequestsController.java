
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

@WebServlet("/admin/borrow-requests")
public class AdminBorrowRequestsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BorrowDAO borrowDAO;

    @Override
    public void init() throws ServletException {
        borrowDAO = new BorrowDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        if (loggedInUser == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // ALLOW ONLY ADMIN ACCOUNTS
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // LOAD PENDING BORROW REQUESTS
        request.setAttribute(
                "pendingBorrowRequests",
                borrowDAO.getPendingBorrowRequests()
        );

        request.setAttribute("pageTitle", "Borrow Requests");
        request.setAttribute(
                "pageSubtitle",
                "Review and approve or reject book borrowing requests"
        );
        request.setAttribute("activePage", "borrow-requests");
        request.setAttribute(
                "adminContent",
                "/admin-borrow-requests-content.jsp"
        );

        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}
