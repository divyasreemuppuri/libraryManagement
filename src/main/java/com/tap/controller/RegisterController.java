
package com.tap.controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import com.tap.dao.UserDAO;
import com.tap.daoimpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/register.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = trimValue(request.getParameter("name"));
        String email = trimValue(request.getParameter("email"));
        String password = request.getParameter("password");
        String phone = trimValue(request.getParameter("phone"));
        String address = trimValue(request.getParameter("address"));

        // VALIDATE REQUIRED FIELDS
        if (name == null || email == null || password == null
                || phone == null || address == null
                || name.isEmpty() || email.isEmpty()
                || password.isEmpty() || phone.isEmpty()
                || address.isEmpty()) {

            showError(request, response,
                    "All fields are required.");
            return;
        }

        // VALIDATE FIELD LENGTHS
        if (name.length() > 100 || email.length() > 150
                || phone.length() > 20 || address.length() > 500) {

            showError(request, response,
                    "One or more fields exceed the allowed length.");
            return;
        }

        // VALIDATE EMAIL FORMAT
        if (!email.matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {

            showError(request, response,
                    "Please enter a valid email address.");
            return;
        }

        // VALIDATE MINIMUM PASSWORD LENGTH
        if (password.length() < 8) {

            showError(request, response,
                    "Password must contain at least 8 characters.");
            return;
        }

        // BCRYPT SUPPORTS UP TO 72 UTF-8 BYTES OF PASSWORD INPUT
        if (password.getBytes(StandardCharsets.UTF_8).length > 72) {

            showError(request, response,
                    "Password is too long. Please use a password of up to 72 UTF-8 bytes.");
            return;
        }

        // CHECK WHETHER THE EMAIL IS ALREADY REGISTERED
        User existingUser = userDAO.getUserByEmail(email);

        if (existingUser != null) {

            showError(request, response,
                    "This email is already registered. Please use another email.");
            return;
        }

        // CREATE THE USER MODEL
        User user = new User();

        user.setName(name);
        user.setEmail(email);
        user.setPassword(password);
        user.setPhone(phone);
        user.setAddress(address);

        // THE DAO HASHES THE PASSWORD AND SETS USER/PENDING IN SQL
        boolean registered = userDAO.registerUser(user);

        if (registered) {

            request.setAttribute("successMessage",
                    "Registration successful! Your account is pending admin approval. "
                    + "You can log in after your account is approved.");

            request.getRequestDispatcher("/register.jsp")
                   .forward(request, response);

        } else {

            showError(request, response,
                    "Registration could not be completed. "
                    + "Your email or phone number may already be registered. "
                    + "Please check your details and try again.");
        }
    }

    private String trimValue(String value) {
        return value == null ? null : value.trim();
    }

    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        request.getRequestDispatcher("/register.jsp")
               .forward(request, response);
    }
}
