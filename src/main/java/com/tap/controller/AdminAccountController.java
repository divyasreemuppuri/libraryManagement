
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

@WebServlet("/admin/account")
public class AdminAccountController extends HttpServlet {

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

        User admin = getAuthorizedAdmin(request, response);

        if (admin == null) {
            return;
        }

        String message = null;
        String messageType = null;

        if ("true".equals(request.getParameter("updated"))) {
            message = "Your administrator profile was updated successfully.";
            messageType = "success";
        }

        showAccountPage(request, response, admin, admin,
                message, messageType);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User admin = getAuthorizedAdmin(request, response);

        if (admin == null) {
            return;
        }

        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        // PRESERVE SUBMITTED VALUES IF VALIDATION FAILS
        User formUser = new User();
        formUser.setUserId(admin.getUserId());
        formUser.setName(name);
        formUser.setEmail(email);
        formUser.setPhone(phone);
        formUser.setAddress(address);
        formUser.setRole(admin.getRole());
        formUser.setStatus(admin.getStatus());
        formUser.setRegisteredAt(admin.getRegisteredAt());
        formUser.setApprovedAt(admin.getApprovedAt());

        if (name.isEmpty() || email.isEmpty()
                || phone.isEmpty() || address.isEmpty()) {
            showAccountPage(request, response, admin, formUser,
                    "All profile fields are required.", "error");
            return;
        }

        if (name.length() > 100 || email.length() > 255
                || phone.length() > 20 || address.length() > 500) {
            showAccountPage(request, response, admin, formUser,
                    "One or more fields exceed the permitted length.",
                    "error");
            return;
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            showAccountPage(request, response, admin, formUser,
                    "Please enter a valid email address.", "error");
            return;
        }

        if (!PHONE_PATTERN.matcher(phone).matches()) {
            showAccountPage(request, response, admin, formUser,
                    "Enter a valid 10-digit phone number.", "error");
            return;
        }

        User updatedAdmin = new User();
        updatedAdmin.setUserId(admin.getUserId());
        updatedAdmin.setName(name);
        updatedAdmin.setEmail(email);
        updatedAdmin.setPhone(phone);
        updatedAdmin.setAddress(address);

        boolean updated = userDAO.updateProfile(updatedAdmin);

        if (!updated) {
            showAccountPage(request, response, admin, formUser,
                    "Profile could not be updated. The email or phone "
                    + "may already be in use, or no changes were saved.",
                    "error");
            return;
        }

        // UPDATE ONLY THE ADMINISTRATOR'S PERSONAL PROFILE FIELDS
        admin.setName(name);
        admin.setEmail(email);
        admin.setPhone(phone);
        admin.setAddress(address);

        HttpSession session = request.getSession(false);

        if (session != null) {
            session.setAttribute("loggedInUser", admin);
        }

        response.sendRedirect(
                request.getContextPath() + "/admin/account?updated=true");
    }

    private User getAuthorizedAdmin(HttpServletRequest request,
                                    HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = session == null
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            if ("USER".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(
                        request.getContextPath() + "/user/account");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }

            return null;
        }

        return loggedInUser;
    }

    private void showAccountPage(HttpServletRequest request,
                                 HttpServletResponse response,
                                 User admin,
                                 User formUser,
                                 String message,
                                 String messageType)
            throws ServletException, IOException {

        request.setAttribute("accountUser", formUser);
        request.setAttribute("profileMessage", message);
        request.setAttribute("profileMessageType", messageType);

        request.setAttribute("pageTitle", "MyAccount");
        request.setAttribute(
                "pageSubtitle",
                "View and update your administrator profile");
        request.setAttribute("activePage", "account");
        request.setAttribute(
                "adminContent",
                "/admin-account-content.jsp");

        request.getRequestDispatcher(
                "/admin-layout.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
