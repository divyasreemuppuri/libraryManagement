
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.tap.model.Borrow" %>
<%@ page import="com.tap.model.Book" %>
<%@ page import="com.tap.model.Fine" %>

<%!
    // ESCAPE HTML TO PREVENT UNTRUSTED TEXT FROM BEING RENDERED AS HTML
    private String escapeBorrowingHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    // FORMAT BORROWING DATES
    private String formatBorrowingDate(LocalDateTime date) {
        if (date == null) {
            return "—";
        }

        return date.format(
            DateTimeFormatter.ofPattern("dd MMM yyyy")
        );
    }
%>

<%
    List<Borrow> activeBorrowings =
        (List<Borrow>) request.getAttribute("activeBorrowings");

    List<Book> allBooks =
        (List<Book>) request.getAttribute("allBooks");

    List<Fine> userFines =
        (List<Fine>) request.getAttribute("userFines");

    List<Map<String, Object>> renewalRequests =
        (List<Map<String, Object>>) request.getAttribute("renewalRequests");

    if (activeBorrowings == null) {
        activeBorrowings = new ArrayList<>();
    }

    if (allBooks == null) {
        allBooks = new ArrayList<>();
    }

    if (userFines == null) {
        userFines = new ArrayList<>();
    }

    if (renewalRequests == null) {
        renewalRequests = new ArrayList<>();
    }

    Map<Integer, Book> bookMap = new HashMap<>();

    for (Book book : allBooks) {
        bookMap.put(book.getBookId(), book);
    }

    // COLLECT BORROWING IDS THAT HAVE PENDING RENEWAL REQUESTS
    Set<Integer> pendingRenewalBorrowIds = new HashSet<>();

    for (Map<String, Object> renewalRequest : renewalRequests) {
        Object requestStatus = renewalRequest.get("status");
        Object requestBorrowId = renewalRequest.get("borrowId");

        if (requestStatus != null
                && "PENDING".equalsIgnoreCase(requestStatus.toString())
                && requestBorrowId != null) {
            try {
                pendingRenewalBorrowIds.add(
                    Integer.parseInt(requestBorrowId.toString())
                );
            } catch (NumberFormatException ignored) {
                // IGNORE INVALID BORROWING IDS
            }
        }
    }

    int activeCount = activeBorrowings.size();

    long pendingFineCount = 0;
    java.math.BigDecimal pendingFineTotal =
        java.math.BigDecimal.ZERO;

    for (Fine fine : userFines) {
        if ("PENDING".equalsIgnoreCase(fine.getStatus())) {
            pendingFineCount++;

            if (fine.getFineAmount() != null) {
                pendingFineTotal =
                    pendingFineTotal.add(fine.getFineAmount());
            }
        }
    }

    String returnResult = request.getParameter("returnResult");
    String renewResult = request.getParameter("renewResult");
%>

<div class="user-borrowings-page">

    <div class="user-borrowings-intro">
        <div>
            <span class="user-borrowings-eyebrow">
                YOUR LIBRARY ACTIVITY
            </span>

            <h2>My Borrowings</h2>

            <p>
                Track your currently borrowed books and due dates.
            </p>
        </div>
    </div>

    <!-- SHOW RETURN ACTION FEEDBACK -->
    <% if ("success".equals(returnResult)) { %>
        <div class="borrowing-alert borrowing-alert-success" role="status">
            Your book has been returned successfully.
        </div>
    <% } else if ("invalid".equals(returnResult)) { %>
        <div class="borrowing-alert borrowing-alert-error" role="alert">
            The borrowing record could not be found.
        </div>
    <% } else if ("unavailable".equals(returnResult)) { %>
        <div class="borrowing-alert borrowing-alert-error" role="alert">
            This book cannot be returned again.
        </div>
    <% } else if ("error".equals(returnResult)) { %>
        <div class="borrowing-alert borrowing-alert-error" role="alert">
            Unable to return the book. Please try again.
        </div>
    <% } %>

    <!-- SHOW RENEWAL REQUEST FEEDBACK -->
    <% if ("requested".equals(renewResult)) { %>
        <div class="borrowing-alert borrowing-alert-success" role="status">
            Your renewal request has been sent to the administrator.
            Your due date will change only after approval.
        </div>
    <% } else if ("success".equals(renewResult)) { %>
        <div class="borrowing-alert borrowing-alert-success" role="status">
            Your book has been renewed for another 15 days.
        </div>
    <% } else if ("invalid".equals(renewResult)) { %>
        <div class="borrowing-alert borrowing-alert-error" role="alert">
            The borrowing record could not be found.
        </div>
    <% } else if ("unavailable".equals(renewResult)) { %>
        <div class="borrowing-alert borrowing-alert-error" role="alert">
            A renewal request cannot be submitted for this borrowing right now.
            Requests are allowed within five days of the due date or after it,
            provided no other renewal request is pending.
        </div>
    <% } else if ("error".equals(renewResult)) { %>
        <div class="borrowing-alert borrowing-alert-error" role="alert">
            Unable to submit the renewal request. Please try again.
        </div>
    <% } %>

    <!-- BORROWING SUMMARY CARDS -->
    <div class="user-borrowings-stats">

        <div class="user-borrowing-stat-card">
            <div class="user-borrowing-stat-icon">
                <i class="fas fa-book-reader"></i>
            </div>

            <div>
                <span>Active Borrowings</span>
                <h3><%= activeCount %></h3>
            </div>
        </div>

        <div class="user-borrowing-stat-card">
            <div class="user-borrowing-stat-icon">
                <i class="fas fa-receipt"></i>
            </div>

            <div>
                <span>Pending Fines</span>
                <h3><%= pendingFineCount %></h3>
                <small>₹<%= pendingFineTotal.toPlainString() %></small>
            </div>
        </div>

    </div>

    <!-- CURRENT BORROWINGS -->
    <section class="user-borrowing-section">

        <div class="user-borrowing-section-heading">
            <div>
                <h3>Currently Borrowed</h3>
                <p>Return or request a renewal for your borrowed books.</p>
            </div>

            <span class="user-borrowing-count">
                <%= activeCount %> books
            </span>
        </div>

        <% if (activeBorrowings.isEmpty()) { %>

            <div class="user-borrowing-empty">
                <i class="fas fa-book-open"></i>
                <h4>No Active Borrowings</h4>
                <p>You don't have any currently borrowed books.</p>

                <a href="<%= request.getContextPath() %>/user/books">
                    Browse Books
                </a>
            </div>

        <% } else { %>

            <div class="user-borrowing-table-wrapper">
                <table class="user-borrowing-table">

                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>Borrow Date</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>

                    <tbody>

                    <%
                        for (Borrow borrow : activeBorrowings) {
                            Book book = bookMap.get(borrow.getBookId());

                            String status = borrow.getStatus() == null
                                ? "UNKNOWN"
                                : borrow.getStatus();

                            LocalDateTime now = LocalDateTime.now();
                            LocalDateTime dueDate = borrow.getDueDate();

                            boolean overdue =
                                "OVERDUE".equalsIgnoreCase(status)
                                || (dueDate != null
                                    && dueDate.isBefore(now));

                            // ALLOW RENEWAL WITHIN FIVE DAYS OF THE DUE DATE
                            // INCLUDING THE DUE DATE AND OVERDUE PERIOD
                            boolean renewalEligible =
                                ("BORROWED".equalsIgnoreCase(status)
                                    || "OVERDUE".equalsIgnoreCase(status))
                                && dueDate != null
                                && !dueDate.isAfter(now.plusDays(5));

                            boolean renewalPending =
                                pendingRenewalBorrowIds.contains(
                                    borrow.getBorrowId()
                                );

                            boolean canSubmitRenewal =
                                renewalEligible && !renewalPending;
                    %>

                        <tr>
                            <td>
                                <div class="user-borrowing-book">
                                    <div class="user-borrowing-book-icon">
                                        <i class="fas fa-book"></i>
                                    </div>

                                    <div>
                                        <strong>
                                            <% if (book != null) { %>
                                                <%= escapeBorrowingHtml(
                                                    book.getTitle()) %>
                                            <% } else { %>
                                                Book #<%= borrow.getBookId() %>
                                            <% } %>
                                        </strong>

                                        <small>
                                            Borrow ID: <%= borrow.getBorrowId() %>
                                        </small>
                                    </div>
                                </div>
                            </td>

                            <td>
                                <%= formatBorrowingDate(
                                    borrow.getBorrowDate()) %>
                            </td>

                            <td>
                                <span class="<%= overdue
                                    ? "user-borrowing-overdue-date"
                                    : "user-borrowing-date" %>">
                                    <%= formatBorrowingDate(dueDate) %>
                                </span>
                            </td>

                            <td>
                                <span class="user-borrowing-status <%= overdue
                                    ? "status-overdue"
                                    : "status-borrowed" %>">
                                    <%= overdue ? "OVERDUE" : "BORROWED" %>
                                </span>
                            </td>

                            <td>
                                <div class="borrowing-action-buttons">

                                    <% if (renewalPending) { %>

                                        <button type="button"
                                                class="borrowing-renew-button"
                                                disabled
                                                aria-disabled="true">
                                            <i class="fas fa-clock"></i>
                                            Renewal Pending
                                        </button>

                                    <% } else if (canSubmitRenewal) { %>

                                        <form method="post"
                                              action="<%= request.getContextPath() %>/renew-book">

                                            <input type="hidden"
                                                   name="borrowId"
                                                   value="<%= borrow.getBorrowId() %>">

                                            <button type="submit"
                                                    class="borrowing-renew-button">
                                                <i class="fas fa-sync-alt"></i>
                                                Request Renewal
                                            </button>
                                        </form>

                                    <% } %>

                                    <!-- KEEP THE EXISTING RETURN FUNCTIONALITY -->
                                    <form method="post"
                                          action="<%= request.getContextPath() %>/return-book"
                                          onsubmit="return confirm('Are you sure you want to return this book?');">

                                        <input type="hidden"
                                               name="borrowId"
                                               value="<%= borrow.getBorrowId() %>">

                                        <button type="submit"
                                                class="borrowing-return-button">
                                            <i class="fas fa-undo"></i>
                                            Return
                                        </button>
                                    </form>

                                </div>
                            </td>
                        </tr>

                    <% } %>

                    </tbody>
                </table>
            </div>

        <% } %>

    </section>

</div>
