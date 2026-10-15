
package com.tap.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.tap.dao.BookDAO;
import com.tap.dao.BorrowDAO;
import com.tap.dao.FineDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.daoimpl.BorrowDAOImpl;
import com.tap.daoimpl.FineDAOImpl;
import com.tap.model.Book;
import com.tap.model.Borrow;
import com.tap.model.Fine;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user/borrowings")
public class UserBorrowingsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BorrowDAO borrowDAO;
    private BookDAO bookDAO;
    private FineDAO fineDAO;

    @Override
    public void init() throws ServletException {
        borrowDAO = new BorrowDAOImpl();
        bookDAO = new BookDAOImpl();
        fineDAO = new FineDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        // REDIRECT USERS WHO ARE NOT LOGGED IN
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ALLOW ONLY NORMAL USERS TO ACCESS THIS PAGE
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(
                        request.getContextPath() + "/admin-dashboard");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            return;
        }

        // ALLOW ONLY APPROVED USERS TO ACCESS THEIR BORROWINGS
        if (loggedInUser.getStatus() == null
                || !"APPROVED".equalsIgnoreCase(loggedInUser.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            int userId = loggedInUser.getUserId();

            // LOAD THE LOGGED-IN USER'S ACTIVE BORROWINGS
            List<Borrow> activeBorrowings =
                    borrowDAO.getActiveBorrowsByUser(userId);

            // LOAD THE USER'S COMPLETE BORROWING HISTORY
            List<Borrow> borrowingHistory =
                    borrowDAO.getBorrowHistoryByUser(userId);

            // LOAD BOOK DETAILS FOR DISPLAYING BOOK TITLES
            List<Book> allBooks = bookDAO.getAllBooks();

            // LOAD THE LOGGED-IN USER'S FINES
            List<Fine> userFines = fineDAO.getFinesByUser(userId);

            // LOAD RENEWAL REQUESTS TO IDENTIFY PENDING REQUESTS
            List<Map<String, Object>> renewalRequests =
                    borrowDAO.getRenewalRequestsByUser(userId);

            // PASS DATA TO THE JSP
            request.setAttribute("activeBorrowings", activeBorrowings);
            request.setAttribute("borrowingHistory", borrowingHistory);
            request.setAttribute("allBooks", allBooks);
            request.setAttribute("userFines", userFines);
            request.setAttribute("renewalRequests", renewalRequests);

            // CONFIGURE THE EXISTING USER DASHBOARD LAYOUT
            request.setAttribute("pageTitle", "My Borrowings");
            request.setAttribute(
                    "pageSubtitle",
                    "Track your borrowed books and due dates");
            request.setAttribute("activePage", "borrowings");
            request.setAttribute(
                    "contentPage",
                    "/user/borrowings-content.jsp");

            request.getRequestDispatcher(
                    "/user/user-layout.jsp").forward(request, response);

        } catch (Exception e) {
            getServletContext().log(
                    "ERROR LOADING USER BORROWINGS", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load your borrowings. Please try again.");
        }
    }
}
