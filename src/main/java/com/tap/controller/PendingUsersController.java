
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

// MAP THE CONTROLLER TO THE ADMIN PENDING-USERS URL
@WebServlet("/admin/pending-users")
public class PendingUsersController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        // INITIALIZE THE EXISTING USER DAO
        userDAO = new UserDAOImpl();
    }

    // DISPLAY ALL USERS WAITING FOR ADMIN APPROVAL
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // VERIFY THAT THE LOGGED-IN USER IS AN ADMIN
        User admin = getLoggedInAdmin(request, response);

        if (admin == null) {
            return;
        }

        // RETRIEVE USERS WHOSE STATUS IS PENDING
        List<User> pendingUsers = userDAO.getPendingUsers();

        request.setAttribute("pendingUsers", pendingUsers);

        // SET THE SHARED ADMIN LAYOUT ATTRIBUTES
        request.setAttribute("pageTitle", "Pending Users");
        request.setAttribute("pageSubtitle",
                "Review new library registrations");
        request.setAttribute("activePage", "pending-users");
        request.setAttribute("adminContent", "/pending-users.jsp");

        // DISPLAY THE PAGE INSIDE THE SHARED ADMIN LAYOUT
        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }

    // PROCESS ADMIN APPROVE AND REJECT ACTIONS
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // VERIFY THAT THE LOGGED-IN USER IS AN ADMIN
        User admin = getLoggedInAdmin(request, response);

        if (admin == null) {
            return;
        }

        String action = request.getParameter("action");
        String userIdValue = request.getParameter("userId");

        // VALIDATE THE REQUIRED FORM PARAMETERS
        if (action == null || userIdValue == null) {
            redirectWithResult(request, response, "invalid");
            return;
        }

        int userId;

        // VALIDATE THE USER ID
        try {
            userId = Integer.parseInt(userIdValue);

            if (userId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            redirectWithResult(request, response, "invalid");
            return;
        }

        String result;

        // APPROVE THE USER USING THE EXISTING DAO METHOD
        if ("approve".equals(action)) {

            boolean updated = userDAO.approveUser(
                    userId,
                    admin.getUserId()
            );

            result = updated ? "approved" : "failed";

        // REJECT THE USER USING THE EXISTING DAO METHOD
        } else if ("reject".equals(action)) {

            boolean updated = userDAO.rejectUser(userId);

            result = updated ? "rejected" : "failed";

        } else {
            result = "invalid";
        }

        // REDIRECT AFTER POST TO AVOID REPEATING THE ACTION ON REFRESH
        redirectWithResult(request, response, result);
    }

    // REDIRECT TO THE PENDING-USERS PAGE WITH AN ACTION RESULT
    private void redirectWithResult(HttpServletRequest request,
                                    HttpServletResponse response,
                                    String result)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/admin/pending-users?result="
                + result
        );
    }

    // RETURN THE SESSION USER ONLY WHEN THE USER IS AN ADMIN
    private User getLoggedInAdmin(HttpServletRequest request,
                                  HttpServletResponse response)
            throws IOException {

        // CHECK THE EXISTING SESSION WITHOUT CREATING A NEW ONE
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return null;
        }

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        // REDIRECT UNAUTHENTICATED USERS TO LOGIN
        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return null;
        }

        // BLOCK NORMAL USERS FROM ADMIN ACTIONS
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Admin privileges are required."
            );
            return null;
        }

        return loggedInUser;
    }
}