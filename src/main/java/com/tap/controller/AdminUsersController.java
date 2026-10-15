
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import com.tap.dao.UserDAO;
import com.tap.daoimpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/users")
public class AdminUsersController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = session == null
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ALLOW ONLY ADMIN USERS
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Admin privileges are required."
            );
            return;
        }

        // RETRIEVE ALL REGISTERED USERS
        List<User> users = userDAO.getAllUsers();

        // PASS USER DATA TO THE JSP
        request.setAttribute("usersList", users);

        // DISPLAY DELETE OPERATION MESSAGES
        String deleteSuccess = request.getParameter("deleteSuccess");
        String deleteError = request.getParameter("deleteError");

        if ("true".equals(deleteSuccess)) {
            request.setAttribute(
                    "successMessage",
                    "User account deleted successfully."
            );
        } else if ("self".equals(deleteError)) {
            request.setAttribute(
                    "errorMessage",
                    "You cannot delete your own admin account."
            );
        } else if ("failed".equals(deleteError)) {
            request.setAttribute(
                    "errorMessage",
                    "Unable to delete this user. The account may have related records."
            );
        }

        // SET ADMIN PAGE DETAILS
        request.setAttribute("pageTitle", "Users Management");
        request.setAttribute(
                "pageSubtitle",
                "View and manage registered library users"
        );
        request.setAttribute("activePage", "users");
        request.setAttribute(
                "adminContent",
                "/admin-users-content.jsp"
        );

        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}
