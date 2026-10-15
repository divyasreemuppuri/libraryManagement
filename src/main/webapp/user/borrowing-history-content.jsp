
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.tap.model.Borrow" %>
<%@ page import="com.tap.model.Book" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.sql.Timestamp" %>

<%!
    // ESCAPE HTML BEFORE DISPLAYING USER-VISIBLE TEXT
    private String escapeHistoryHtml(String value) {
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
    private String formatHistoryDate(LocalDateTime date) {
        if (date == null) {
            return "N/A";
        }

        return date.format(
            DateTimeFormatter.ofPattern("dd MMM yyyy")
        );
    }

    // FORMAT REQUEST TIMESTAMPS
    private String formatHistoryTimestamp(Object value) {
        if (value == null) {
            return "N/A";
        }

        if (value instanceof Timestamp) {
            return ((Timestamp) value).toLocalDateTime().format(
                DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")
            );
        }

        if (value instanceof LocalDateTime) {
            return ((LocalDateTime) value).format(
                DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")
            );
        }

        return escapeHistoryHtml(String.valueOf(value));
    }
%>

<%
    List<Borrow> borrowingHistory =
        (List<Borrow>) request.getAttribute("borrowingHistory");

    List<Book> allBooks =
        (List<Book>) request.getAttribute("allBooks");

    List<Map<String, Object>> borrowRequestHistory =
        (List<Map<String, Object>>) request.getAttribute("borrowRequestHistory");

    if (borrowingHistory == null) {
        borrowingHistory = new ArrayList<>();
    }

    if (allBooks == null) {
        allBooks = new ArrayList<>();
    }

    if (borrowRequestHistory == null) {
        borrowRequestHistory = new ArrayList<>();
    }

    Map<Integer, Book> bookMap = new HashMap<>();

    for (Book book : allBooks) {
        bookMap.put(book.getBookId(), book);
    }

    int historyCount = borrowingHistory.size();
    int requestCount = borrowRequestHistory.size();
%>

<div class="user-borrowings-page">

    <div class="user-borrowings-intro">
        <div>
            <span class="user-borrowings-eyebrow">
                YOUR LIBRARY ACTIVITY
            </span>

            <h2>Borrowing History</h2>

            <p>
                Review your borrowing records, due dates, returned books
                and the status of your book requests.
            </p>
        </div>
    </div>

    <div class="user-borrowings-stats">

        <div class="user-borrowing-stat-card">
            <div class="user-borrowing-stat-icon">
                <i class="fas fa-history"></i>
            </div>

            <div>
                <span>Total Borrowing Records</span>
                <h3><%= historyCount %></h3>
            </div>
        </div>

        <div class="user-borrowing-stat-card">
            <div class="user-borrowing-stat-icon">
                <i class="fas fa-clipboard-list"></i>
            </div>

            <div>
                <span>Total Book Requests</span>
                <h3><%= requestCount %></h3>
            </div>
        </div>

    </div>

    <!-- BORROWING RECORDS SECTION -->
    <section class="user-borrowing-section">

        <div class="user-borrowing-section-heading">
            <div>
                <h3>All Borrowing Records</h3>
                <p>Your borrowing activity, including active loans.</p>
            </div>

            <span class="user-borrowing-count">
                <%= historyCount %> records
            </span>
        </div>

        <% if (borrowingHistory.isEmpty()) { %>

            <div class="user-borrowing-empty">
                <i class="fas fa-history"></i>
                <h4>No Borrowing History</h4>
                <p>Your actual borrowing records will appear here.</p>

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
                            <th>Return Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>

                    <tbody>

                    <% for (Borrow borrow : borrowingHistory) {
                        Book book = bookMap.get(borrow.getBookId());

                        String status = borrow.getStatus() == null
                            ? "UNKNOWN"
                            : borrow.getStatus();

                        String statusClass =
                            "RETURNED".equalsIgnoreCase(status)
                                ? "status-returned"
                                : "OVERDUE".equalsIgnoreCase(status)
                                    ? "status-overdue"
                                    : "status-borrowed";
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
                                                <%= escapeHistoryHtml(book.getTitle()) %>
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
                                <%= formatHistoryDate(borrow.getBorrowDate()) %>
                            </td>

                            <td>
                                <%= formatHistoryDate(borrow.getDueDate()) %>
                            </td>

                            <td>
                                <%= formatHistoryDate(borrow.getReturnDate()) %>
                            </td>

                            <td>
                                <span class="user-borrowing-status <%= statusClass %>">
                                    <%= escapeHistoryHtml(status) %>
                                </span>
                            </td>
                        </tr>

                    <% } %>

                    </tbody>
                </table>
            </div>

        <% } %>

    </section>

    <!-- BORROW REQUEST HISTORY SECTION -->
    <section class="user-borrowing-section">

        <div class="user-borrowing-section-heading">
            <div>
                <h3>Borrow Requests</h3>
                <p>
                    Track your requests and see why a request was rejected.
                </p>
            </div>

            <span class="user-borrowing-count">
                <%= requestCount %> requests
            </span>
        </div>

        <% if (borrowRequestHistory.isEmpty()) { %>

            <div class="user-borrowing-empty">
                <i class="fas fa-clipboard-list"></i>
                <h4>No Borrow Requests</h4>
                <p>
                    Your book requests will appear here after you request a book.
                </p>

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
                            <th>Request Date</th>
                            <th>Status</th>
                            <th>Decision Date</th>
                            <th>Rejection Reason</th>
                        </tr>
                    </thead>

                    <tbody>

                    <% for (Map<String, Object> borrowRequest : borrowRequestHistory) {

                        String bookTitle = borrowRequest.get("bookTitle") == null
                            ? "Unknown Book"
                            : String.valueOf(borrowRequest.get("bookTitle"));

                        String requestStatus = borrowRequest.get("status") == null
                            ? "UNKNOWN"
                            : String.valueOf(borrowRequest.get("status"));

                        String rejectionReason =
                            borrowRequest.get("rejectionReason") == null
                                ? ""
                                : String.valueOf(borrowRequest.get("rejectionReason"));

                        String requestStatusClass =
                            "REJECTED".equalsIgnoreCase(requestStatus)
                                ? "request-status-rejected"
                                : "APPROVED".equalsIgnoreCase(requestStatus)
                                    ? "request-status-approved"
                                    : "request-status-pending";
                    %>

                        <tr>
                            <td>
                                <div class="user-borrowing-book">
                                    <div class="user-borrowing-book-icon">
                                        <i class="fas fa-book"></i>
                                    </div>

                                    <div>
                                        <strong>
                                            <%= escapeHistoryHtml(bookTitle) %>
                                        </strong>

                                        <small>
                                            Request ID:
                                            <%= borrowRequest.get("requestId") %>
                                        </small>
                                    </div>
                                </div>
                            </td>

                            <td>
                                <%= formatHistoryTimestamp(
                                    borrowRequest.get("requestDate")) %>
                            </td>

                            <td>
                                <span class="user-borrowing-status <%= requestStatusClass %>">
                                    <%= escapeHistoryHtml(requestStatus) %>
                                </span>
                            </td>

                            <td>
                                <%= formatHistoryTimestamp(
                                    borrowRequest.get("decidedAt")) %>
                            </td>

                            <td>
                                <% if ("REJECTED".equalsIgnoreCase(requestStatus)) { %>

                                    <span class="request-rejection-reason">
                                        <%= rejectionReason.trim().isEmpty()
                                            ? "No reason provided"
                                            : escapeHistoryHtml(rejectionReason) %>
                                    </span>

                                <% } else { %>

                                    <span class="request-no-reason">—</span>

                                <% } %>
                            </td>
                        </tr>

                    <% } %>

                    </tbody>
                </table>
            </div>

        <% } %>

    </section>

</div>
