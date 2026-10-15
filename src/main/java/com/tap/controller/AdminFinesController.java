
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.model.User;
import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/fines")
public class AdminFinesController extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Admin privileges are required."
            );
            return;
        }

        // STORE ALL FINE RECORDS FOR THE JSP PAGE
        List<Map<String, Object>> fineList = new ArrayList<>();

        String sql =
                "SELECT u.name AS userName, " +
                "b.title AS bookTitle, " +
                "f.daysOverdue, f.fineAmount, " +
                "f.createdAt, f.status, f.paidAt " +
                "FROM fine f " +
                "JOIN user u ON f.userId = u.userId " +
                "JOIN borrow br ON f.borrowId = br.borrowId " +
                "JOIN book b ON br.bookId = b.bookId " +
                "ORDER BY f.createdAt DESC";

        // FETCH FINE DETAILS WITH USER AND BOOK INFORMATION
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> fine = new HashMap<>();

                fine.put("userName", rs.getString("userName"));
                fine.put("bookTitle", rs.getString("bookTitle"));
                fine.put("daysOverdue", rs.getInt("daysOverdue"));
                fine.put("fineAmount", rs.getBigDecimal("fineAmount"));
                fine.put("createdAt", rs.getTimestamp("createdAt"));
                fine.put("status", rs.getString("status"));
                fine.put("paidAt", rs.getTimestamp("paidAt"));

                fineList.add(fine);
            }

        } catch (Exception e) {

            // DISPLAY A GENERAL ERROR MESSAGE ON THE ADMIN PAGE
            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Unable to load fine records. Please try again."
            );
        }

        // PASS DATA TO THE SHARED ADMIN LAYOUT
        request.setAttribute("fineList", fineList);
        request.setAttribute("pageTitle", "Fines");
        request.setAttribute(
                "pageSubtitle",
                "View overdue fines and payment status"
        );
        request.setAttribute("activePage", "fines");
        request.setAttribute(
                "adminContent",
                "/admin-fines-content.jsp"
        );

        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}
