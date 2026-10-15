
package com.tap.controller;

import java.io.IOException;

import com.tap.dao.BookDAO;
import com.tap.dao.BorrowDAO;
import com.tap.dao.UserDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.daoimpl.BorrowDAOImpl;
import com.tap.daoimpl.UserDAOImpl;
import com.tap.model.Book;
import com.tap.model.Borrow;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin-dashboard")
public class AdminDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookDAO bookDAO;
    private UserDAO userDAO;
    private BorrowDAO borrowDAO;

    // INITIALIZE THE DAOS
    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAOImpl();
        userDAO = new UserDAOImpl();
        borrowDAO = new BorrowDAOImpl();
    }

    // LOAD THE ADMIN OVERVIEW
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        // REDIRECT UNAUTHENTICATED USERS TO LOGIN
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // PREVENT NORMAL USERS FROM ACCESSING THE ADMIN DASHBOARD
        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        // CALCULATE TOTAL BOOK COPIES AND AVAILABLE COPIES
        int totalBooks = 0;
        int availableCopies = 0;

        for (Book book : bookDAO.getAllBooks()) {
            totalBooks +=1;
            availableCopies += book.getAvailableCopies();
        }

        // COUNT PENDING REGISTRATIONS
        int pendingRegistrations =
                userDAO.getPendingUsers().size();

        // COUNT ACTIVE BORROWINGS
        int activeBorrowings = 0;

        for (Borrow borrow : borrowDAO.getAllBorrows()) {
            String status = borrow.getStatus();

            if ("BORROWED".equalsIgnoreCase(status)
                    || "OVERDUE".equalsIgnoreCase(status)) {
                activeBorrowings++;
            }
        }

        // COUNT PENDING BORROW REQUESTS
        int pendingBorrowRequests =
                borrowDAO.getPendingBorrowRequests().size();

        // COUNT PENDING RENEWAL REQUESTS
        int pendingRenewalRequests =
                borrowDAO.getPendingRenewalRequests().size();

        // PASS DASHBOARD STATISTICS TO THE JSP
        request.setAttribute("totalBooks", totalBooks);
        request.setAttribute("availableCopies", availableCopies);
        request.setAttribute(
                "pendingRegistrations", pendingRegistrations
        );
        request.setAttribute("activeBorrowings", activeBorrowings);
        request.setAttribute(
                "pendingBorrowRequests", pendingBorrowRequests
        );
        request.setAttribute(
                "pendingRenewalRequests", pendingRenewalRequests
        );

        // CONFIGURE THE SHARED ADMIN LAYOUT
        request.setAttribute("pageTitle", "Overview");
        request.setAttribute(
                "pageSubtitle",
                "Welcome to your Library Management System"
        );
        request.setAttribute("activePage", "overview");
        request.setAttribute(
                "adminContent",
                "/admin-overview-content.jsp"
        );

        // FORWARD THE REQUEST TO THE SHARED ADMIN LAYOUT
        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}
