
package com.tap.controller;

import java.io.IOException;
import java.util.regex.Pattern;

import com.tap.dao.UserDAO;
import com.tap.daoimpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user/account")
public class UserAccountController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[0-9]{10}$");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User loggedInUser = getAuthorizedUser(request, response);

        if (loggedInUser == null) {
            return;
        }

        showAccountPage(request, response, loggedInUser);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User loggedInUser = getAuthorizedUser(request, response);

        if (loggedInUser == null) {
            return;
        }

        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        if (name.isEmpty() || email.isEmpty()
                || phone.isEmpty() || address.isEmpty()) {

            showAccountPage(request, response, loggedInUser,
                    "All profile fields are required.", "error");
            return;
        }

        if (name.length() > 100 || email.length() > 255
                || phone.length() > 20 || address.length() > 500) {

            showAccountPage(request, response, loggedInUser,
                    "One or more fields exceed the permitted length.",
                    "error");
            return;
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            showAccountPage(request, response, loggedInUser,
                    "Please enter a valid email address.", "error");
            return;
        }

        if (!PHONE_PATTERN.matcher(phone).matches()) {
            showAccountPage(request, response, loggedInUser,
                    "Enter a valid 10-digit phone number.", "error");
            return;
        }

        User updatedUser = new User();

        updatedUser.setUserId(loggedInUser.getUserId());
        updatedUser.setName(name);
        updatedUser.setEmail(email);
        updatedUser.setPhone(phone);
        updatedUser.setAddress(address);

        boolean updated = userDAO.updateProfile(updatedUser);

        if (!updated) {
            showAccountPage(request, response, loggedInUser,
                    "Profile could not be updated. The email or phone "
                    + "may already be in use, or no changes were saved.",
                    "error");
            return;
        }

        // REFRESH THE SESSION USER WITHOUT CHANGING ROLE OR STATUS
        loggedInUser.setName(name);
        loggedInUser.setEmail(email);
        loggedInUser.setPhone(phone);
        loggedInUser.setAddress(address);

        HttpSession session = request.getSession(false);
        session.setAttribute("loggedInUser", loggedInUser);

        response.sendRedirect(
                request.getContextPath()
                + "/user/account?updated=true");
    }

    private User getAuthorizedUser(HttpServletRequest request,
                                   HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        // REDIRECT USERS WHO ARE NOT LOGGED IN
        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return null;
        }

        // ALLOW ONLY NORMAL USERS TO ACCESS THIS PAGE
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {

            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(
                        request.getContextPath() + "/admin-dashboard");
            } else {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN);
            }

            return null;
        }

        return loggedInUser;
    }

    private void showAccountPage(HttpServletRequest request,
                                 HttpServletResponse response,
                                 User loggedInUser)
            throws ServletException, IOException {

        String message = null;
        String messageType = null;

        if ("true".equals(request.getParameter("updated"))) {
            message = "Your profile has been updated successfully.";
            messageType = "success";
        }

        showAccountPage(request, response, loggedInUser,
                message, messageType);
    }

    private void showAccountPage(HttpServletRequest request,
                                 HttpServletResponse response,
                                 User loggedInUser,
                                 String message,
                                 String messageType)
            throws ServletException, IOException {

        request.setAttribute("accountUser", loggedInUser);
        request.setAttribute("profileMessage", message);
        request.setAttribute("profileMessageType", messageType);

        // CONFIGURE THE EXISTING USER DASHBOARD LAYOUT
        request.setAttribute("pageTitle", "My Account");
        request.setAttribute(
                "pageSubtitle",
                "View and update your personal and library account details");
        request.setAttribute("activePage", "account");
        request.setAttribute(
                "contentPage",
                "/user/account-content.jsp");

        request.getRequestDispatcher(
                "/user/user-layout.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
