
package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.dao.BorrowDAO;
import com.tap.daoimpl.BorrowDAOImpl;
import com.tap.model.User;
import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/borrowings")
public class AdminBorrowingsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BorrowDAO borrowDAO = new BorrowDAOImpl();

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

        // RETRIEVE EXISTING BORROWING RECORDS
        String sql =
                "SELECT br.borrowId, u.name AS userName, "
              + "b.title AS bookTitle, br.borrowDate, "
              + "br.dueDate, br.returnDate, br.status "
              + "FROM borrow br "
              + "JOIN user u ON br.userId = u.userId "
              + "JOIN book b ON br.bookId = b.bookId "
              + "ORDER BY br.borrowDate DESC";

        List<Map<String, Object>> borrowingList = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();

                row.put("borrowId", rs.getInt("borrowId"));
                row.put("userName", rs.getString("userName"));
                row.put("bookTitle", rs.getString("bookTitle"));
                row.put("borrowDate", rs.getTimestamp("borrowDate"));
                row.put("dueDate", rs.getTimestamp("dueDate"));
                row.put("returnDate", rs.getTimestamp("returnDate"));

                // DISPLAY OVERDUE STATUS WITHOUT CHANGING THE DATABASE
                String status = rs.getString("status");

                if (!"RETURNED".equalsIgnoreCase(status)
                        && rs.getTimestamp("dueDate") != null
                        && rs.getTimestamp("dueDate").before(
                                new java.sql.Timestamp(
                                        System.currentTimeMillis()))) {
                    status = "OVERDUE";
                }

                row.put("status", status);
                borrowingList.add(row);
            }

        } catch (java.sql.SQLException e) {
            throw new ServletException(
                    "Unable to retrieve borrowing records.", e
            );
        }

        // PASS BORROWING RECORDS TO THE ADMIN PAGE
        request.setAttribute("borrowingList", borrowingList);

        // LOAD REJECTED BORROW REQUESTS FOR THE ADMIN
        request.setAttribute(
                "rejectedBorrowRequests",
                borrowDAO.getRejectedBorrowRequests()
        );

        // SET ADMIN PAGE DETAILS
        request.setAttribute("pageTitle", "Borrowings");
        request.setAttribute(
                "pageSubtitle",
                "Monitor active and completed library borrowing records"
        );
        request.setAttribute("activePage", "borrowings");
        request.setAttribute(
                "adminContent",
                "/admin-borrowings-content.jsp"
        );

        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}
