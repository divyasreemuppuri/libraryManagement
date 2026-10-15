
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

@WebServlet("/admin/renewal-requests")
public class AdminRenewalRequestsController extends HttpServlet {

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

        // LOAD PENDING RENEWAL REQUESTS
        request.setAttribute(
                "pendingRenewalRequests",
                borrowDAO.getPendingRenewalRequests()
        );

        request.setAttribute("pageTitle", "Renewal Requests");
        request.setAttribute(
                "pageSubtitle",
                "Review and approve or reject book renewal requests"
        );
        request.setAttribute("activePage", "renewal-requests");
        request.setAttribute(
                "adminContent",
                "/admin-renewal-requests-content.jsp"
        );

        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}
