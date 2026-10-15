
package com.tap.controller;

import java.io.IOException;

import com.tap.dao.UserDAO;
import com.tap.daoimpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/delete-user")
public class AdminDeleteUserController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request,
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

        // ALLOW ONLY ADMIN USERS TO DELETE ACCOUNTS
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Admin privileges are required."
            );
            return;
        }

        // VALIDATE THE USER ID
        String userIdValue = request.getParameter("userId");

        int userId;

        try {
            userId = Integer.parseInt(userIdValue);

            if (userId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid user ID."
                );
                return;
            }

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user ID."
            );
            return;
        }

        // PREVENT AN ADMIN FROM DELETING THEIR OWN ACCOUNT
        if (userId == loggedInUser.getUserId()) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/users?deleteError=self"
            );
            return;
        }

        // DELETE THE SELECTED NON-ADMIN USER
        boolean deleted = userDAO.deleteUser(userId);

        if (deleted) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/users?deleteSuccess=true"
            );
        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/users?deleteError=failed"
            );
        }
    }
}
