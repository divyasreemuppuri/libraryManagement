
package com.tap.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// ADDED: MAP THE LOGOUT CONTROLLER TO /logout
@WebServlet("/logout")
public class LogoutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ADDED: END THE CURRENT USER SESSION
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // ADDED: GET THE EXISTING SESSION WITHOUT CREATING A NEW ONE
        HttpSession session = request.getSession(false);

        // ADDED: INVALIDATE THE SESSION IF IT EXISTS
        if (session != null) {
            session.invalidate();
        }

        // ADDED: REDIRECT TO THE LANDING PAGE
        response.sendRedirect(request.getContextPath() + "/home");
    }

    // ADDED: SUPPORT LOGOUT THROUGH POST AS WELL
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
