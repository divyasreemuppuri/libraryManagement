
package com.tap.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
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

@WebServlet("/user-dashboard")
public class UserDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookDAO bookDAO;
    private BorrowDAO borrowDAO;
    private FineDAO fineDAO;

    // INITIALIZE THE EXISTING DAO IMPLEMENTATIONS
    @Override
    public void init() throws ServletException {
        bookDAO = new BookDAOImpl();
        borrowDAO = new BorrowDAOImpl();
        fineDAO = new FineDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // CHECK THE LOGGED-IN USER SESSION
        HttpSession session = request.getSession(false);

        User loggedInUser = session == null
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ALLOW ONLY NORMAL USERS ON THIS DASHBOARD
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {

            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(
                        request.getContextPath() + "/admin-dashboard");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }

            return;
        }

        try {
            int userId = loggedInUser.getUserId();

            // RETRIEVE BOOKS AND THE LOGGED-IN USER'S RECORDS
            List<Book> allBooks = bookDAO.getAllBooks();
            List<Borrow> activeBorrowings =
                    borrowDAO.getActiveBorrowsByUser(userId);
            List<Borrow> borrowingHistory =
                    borrowDAO.getBorrowHistoryByUser(userId);
            List<Fine> userFines = fineDAO.getFinesByUser(userId);

            // HANDLE EMPTY DAO RESULTS SAFELY
            if (allBooks == null) {
                allBooks = new ArrayList<>();
            }

            if (activeBorrowings == null) {
                activeBorrowings = new ArrayList<>();
            }

            if (borrowingHistory == null) {
                borrowingHistory = new ArrayList<>();
            }

            if (userFines == null) {
                userFines = new ArrayList<>();
            }

            // CREATE A LOOKUP OF BOOK DETAILS USING BOOK ID
            Map<Integer, Book> bookMap = new HashMap<>();

            for (Book book : allBooks) {
                bookMap.put(book.getBookId(), book);
            }

            // PREPARE RECENT BOOKS USING CREATION DATE
            List<Book> recentBooks = new ArrayList<>(allBooks);

            recentBooks.sort(
                Comparator.comparing(
                    Book::getCreatedAt,
                    Comparator.nullsLast(Comparator.reverseOrder())
                )
            );

            if (recentBooks.size() > 6) {
                recentBooks = new ArrayList<>(
                        recentBooks.subList(0, 6));
            }

            // CALCULATE TOTAL AVAILABLE COPIES
            int availableBooks = 0;

            for (Book book : allBooks) {
                availableBooks += Math.max(
                        0, book.getAvailableCopies());
            }

            // CALCULATE THE USER'S PENDING FINES
            BigDecimal pendingFineTotal = BigDecimal.ZERO;
            int pendingFineCount = 0;

            for (Fine fine : userFines) {

                if ("PENDING".equalsIgnoreCase(fine.getStatus())) {
                    pendingFineCount++;

                    if (fine.getFineAmount() != null) {
                        pendingFineTotal =
                                pendingFineTotal.add(
                                        fine.getFineAmount());
                    }
                }
            }

            // MAKE DASHBOARD DATA AVAILABLE TO THE JSP
            request.setAttribute("loggedInUser", loggedInUser);

            request.setAttribute("allBooks", allBooks);
            request.setAttribute("recentBooks", recentBooks);
            request.setAttribute("bookMap", bookMap);

            request.setAttribute(
                    "activeBorrowings", activeBorrowings);
            request.setAttribute(
                    "borrowingHistory", borrowingHistory);
            request.setAttribute("userFines", userFines);

            request.setAttribute(
                    "activeBorrowingCount", activeBorrowings.size());
            request.setAttribute("totalBooks", allBooks.size());
            request.setAttribute("availableBooks", availableBooks);
            request.setAttribute(
                    "borrowingHistoryCount", borrowingHistory.size());

            request.setAttribute(
                    "pendingFineTotal", pendingFineTotal);
            request.setAttribute(
                    "pendingFineCount", pendingFineCount);

         // SET THE SHARED USER LAYOUT AND DASHBOARD CONTENT.
            request.setAttribute("pageTitle", "Dashboard");
            request.setAttribute("pageSubtitle", "Welcome to your personal library");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("contentPage", "/user/dashboard-content.jsp");

            request.getRequestDispatcher("/user/user-layout.jsp")
                   .forward(request, response);

        } catch (Exception e) {

            // LOG THE ERROR AND DISPLAY A SAFE ERROR RESPONSE
            getServletContext().log(
                    "ERROR LOADING USER DASHBOARD", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load your dashboard. Please try again.");
        }
    }
}
