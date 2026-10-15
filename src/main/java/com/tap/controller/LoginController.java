
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

// MAP THE LOGIN CONTROLLER TO /login
@WebServlet("/login")
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // USE THE EXISTING USER DAO
    private UserDAO userDAO;

    // INITIALIZE THE DAO
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
    }

    // DISPLAY THE LOGIN PAGE
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }

    // PROCESS LOGIN FORM SUBMISSION
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // SET REQUEST ENCODING
        request.setCharacterEncoding("UTF-8");

        // READ LOGIN CREDENTIALS
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // VALIDATE REQUIRED FIELDS
        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {

            showError(request, response,
                    "Email and password are required.");
            return;
        }

        email = email.trim();

        // VERIFY CREDENTIALS AND RETRIEVE ACCOUNT STATUS
        User user = userDAO.authenticateForAccountStatus(email, password);

        // HANDLE INVALID CREDENTIALS
        if (user == null) {
            showError(request, response,
                    "Invalid email or password.");
            return;
        }

        // READ ACCOUNT STATUS
        String status = user.getStatus();

        // HANDLE PENDING ACCOUNTS
        if ("PENDING".equalsIgnoreCase(status)) {
            showAccountStatus(request, response,
                    "PENDING",
                    "Your registration is awaiting approval. Please wait for the library administrator to review your account.");
            return;
        }

        // HANDLE REJECTED ACCOUNTS
        if ("REJECTED".equalsIgnoreCase(status)) {
            showAccountStatus(request, response,
                    "REJECTED",
                    "Unfortunately, your registration has been rejected by the library administrator. Please contact the library administrator for further information.");
            return;
        }

        // ALLOW ONLY APPROVED ACCOUNTS TO CONTINUE
        if (!"APPROVED".equalsIgnoreCase(status)) {
            showError(request, response,
                    "Your account status is invalid. Please contact the administrator.");
            return;
        }

        // VALIDATE THE AUTHENTICATED USER ROLE
        String role = user.getRole();

        if (!"ADMIN".equalsIgnoreCase(role)
                && !"USER".equalsIgnoreCase(role)) {

            showError(request, response,
                    "Your account has an invalid role. Please contact the administrator.");
            return;
        }

        // INVALIDATE THE OLD SESSION AFTER SUCCESSFUL AUTHENTICATION
        HttpSession oldSession = request.getSession(false);

        if (oldSession != null) {
            oldSession.invalidate();
        }

        // CREATE A NEW SESSION FOR THE APPROVED USER
        HttpSession session = request.getSession(true);

        // STORE THE LOGGED-IN USER IN THE SESSION
        session.setAttribute("loggedInUser", user);

        // REDIRECT APPROVED USERS TO THE EXISTING HOME ROUTE
        response.sendRedirect(request.getContextPath() + "/home");
    }

    // DISPLAY ACCOUNT STATUS PAGE
    private void showAccountStatus(HttpServletRequest request,
                                   HttpServletResponse response,
                                   String accountStatus,
                                   String message)
            throws ServletException, IOException {

        request.setAttribute("accountStatus", accountStatus);
        request.setAttribute("accountStatusMessage", message);

        request.getRequestDispatcher("/account-status.jsp")
               .forward(request, response);
    }

    // DISPLAY LOGIN ERRORS
    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }
}
