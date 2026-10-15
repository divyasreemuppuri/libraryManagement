
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import com.tap.dao.FineDAO;
import com.tap.daoimpl.FineDAOImpl;
import com.tap.model.Fine;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user/fines")
public class UserFinesController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FineDAO fineDAO;

    @Override
    public void init() throws ServletException {
        fineDAO = new FineDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {

            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(
                        request.getContextPath() + "/admin-dashboard");
            } else {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN);
            }

            return;
        }

        try {

            // LOAD ONLY THE LOGGED-IN USER'S FINES
            List<Fine> userFines =
                    fineDAO.getFinesByUser(loggedInUser.getUserId());

            // PASS FINE RECORDS TO THE JSP PAGE
            request.setAttribute("userFines", userFines);

            // CONFIGURE THE EXISTING USER DASHBOARD LAYOUT
            request.setAttribute("pageTitle", "My Fines");
            request.setAttribute(
                    "pageSubtitle",
                    "Review your library fines and payment status");
            request.setAttribute("activePage", "fines");
            request.setAttribute(
                    "contentPage",
                    "/user/fines-content.jsp");

            request.getRequestDispatcher(
                    "/user/user-layout.jsp").forward(request, response);

        } catch (Exception e) {

            getServletContext().log(
                    "ERROR LOADING USER FINES", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load your fines. Please try again.");
        }
    }
}