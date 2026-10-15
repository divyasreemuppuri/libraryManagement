
package com.tap.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.tap.dao.BookDAO;
import com.tap.dao.BorrowDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.daoimpl.BorrowDAOImpl;
import com.tap.model.Book;
import com.tap.model.Borrow;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user/borrowing-history")
public class UserBorrowingHistoryController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BorrowDAO borrowDAO;
    private BookDAO bookDAO;

    @Override
    public void init() throws ServletException {
        borrowDAO = new BorrowDAOImpl();
        bookDAO = new BookDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        // CHECK WHETHER THE USER IS LOGGED IN
        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // ALLOW ONLY NORMAL USERS TO VIEW THEIR BORROWING HISTORY
        if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
            if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
                response.sendRedirect(contextPath + "/admin-dashboard");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            return;
        }

        try {
            int userId = loggedInUser.getUserId();

            // LOAD THIS USER'S ACTUAL BORROWING RECORDS
            List<Borrow> borrowingHistory =
                    borrowDAO.getBorrowHistoryByUser(userId);

            // LOAD BOOK DETAILS FOR DISPLAYING TITLES
            List<Book> allBooks = bookDAO.getAllBooks();

            // LOAD THIS USER'S BORROW REQUEST HISTORY
            List<Map<String, Object>> borrowRequestHistory =
                    borrowDAO.getBorrowRequestsByUser(userId);

            // PASS THE DATA TO THE BORROWING HISTORY JSP
            request.setAttribute("borrowingHistory", borrowingHistory);
            request.setAttribute("allBooks", allBooks);
            request.setAttribute(
                    "borrowRequestHistory",
                    borrowRequestHistory
            );

            // USE THE EXISTING USER DASHBOARD LAYOUT
            request.setAttribute("pageTitle", "Borrowing History");
            request.setAttribute(
                    "pageSubtitle",
                    "Review your borrowing records and book requests"
            );
            request.setAttribute("activePage", "history");
            request.setAttribute(
                    "contentPage",
                    "/user/borrowing-history-content.jsp"
            );

            request.getRequestDispatcher(
                    "/user/user-layout.jsp"
            ).forward(request, response);

        } catch (Exception e) {
            getServletContext().log(
                    "ERROR LOADING USER BORROWING HISTORY", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load your borrowing history. Please try again."
            );
        }
    }
}
