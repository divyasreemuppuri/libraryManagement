
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    // ESCAPE HTML CHARACTERS BEFORE DISPLAYING DATABASE TEXT
    private String escapeHtml(String value) {
        if (value == null) {
            return "N/A";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    // RETRIEVE EXISTING BORROWING RECORDS
    List<Map<String, Object>> borrowingList =
        (List<Map<String, Object>>) request.getAttribute("borrowingList");

    if (borrowingList == null) {
        borrowingList = java.util.Collections.emptyList();
    }

    // RETRIEVE REJECTED BORROW REQUESTS
    List<Map<String, Object>> rejectedBorrowRequests =
        (List<Map<String, Object>>) request.getAttribute("rejectedBorrowRequests");

    if (rejectedBorrowRequests == null) {
        rejectedBorrowRequests = java.util.Collections.emptyList();
    }

    DateTimeFormatter dateFormatter =
        DateTimeFormatter.ofPattern("dd MMM yyyy");
%>

<section class="management-section borrowing-management">

    <!-- EXISTING BORROWING RECORDS -->
    <div class="section-heading borrowing-records-heading">
        <div>
            <h2>Borrowing Records</h2>
            <p class="section-description">
                Monitor borrowed, overdue, and returned books.
            </p>
        </div>
    </div>

    <div class="borrowing-table-wrapper">
        <table class="borrowing-table">
            <thead>
                <tr>
                    <th>User Name</th>
                    <th>Book Name</th>
                    <th>Borrow Date</th>
                    <th>Due Date</th>
                    <th>Return Date</th>
                    <th>Status</th>
                </tr>
            </thead>

            <tbody>
                <% if (borrowingList.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="empty-borrowings">
                            <i class="fa-solid fa-book-open"></i>
                            <p>No borrowing records found.</p>
                        </td>
                    </tr>
                <% } else {
                    for (Map<String, Object> borrow : borrowingList) {

                        String userName =
                            (String) borrow.get("userName");

                        String bookTitle =
                            (String) borrow.get("bookTitle");

                        Timestamp borrowDate =
                            (Timestamp) borrow.get("borrowDate");

                        Timestamp dueDate =
                            (Timestamp) borrow.get("dueDate");

                        Timestamp returnDate =
                            (Timestamp) borrow.get("returnDate");

                        String status =
                            (String) borrow.get("status");

                        String statusClass = "borrowed";

                        if ("OVERDUE".equalsIgnoreCase(status)) {
                            statusClass = "overdue";
                        } else if ("RETURNED".equalsIgnoreCase(status)) {
                            statusClass = "returned";
                        }
                %>
                    <tr>
                        <td class="borrow-user">
                            <i class="fa-solid fa-user"></i>
                            <%= escapeHtml(userName) %>
                        </td>

                        <td class="borrow-book">
                            <%= escapeHtml(bookTitle) %>
                        </td>

                        <td>
                            <%= borrowDate == null ? "N/A" :
                                borrowDate.toLocalDateTime().format(dateFormatter) %>
                        </td>

                        <td>
                            <%= dueDate == null ? "N/A" :
                                dueDate.toLocalDateTime().format(dateFormatter) %>
                        </td>

                        <td>
                            <%= returnDate == null ? "N/A" :
                                returnDate.toLocalDateTime().format(dateFormatter) %>
                        </td>

                        <td>
                            <span class="borrow-status <%= statusClass %>">
                                <%= escapeHtml(
                                    status == null ? "Unknown" : status) %>
                            </span>
                        </td>
                    </tr>
                <%  }
                   } %>
            </tbody>
        </table>
    </div>

    <div class="borrowing-table-footer">
        Showing <strong><%= borrowingList.size() %></strong>
        borrowing records
    </div>

    <!-- REJECTED BORROW REQUESTS -->
    <div class="section-heading borrowing-records-heading"
         style="margin-top: 35px;">
        <div>
            <h2>Rejected Borrow Requests</h2>
            <p class="section-description">
                Review rejected requests and the reasons provided by the administrator.
            </p>
        </div>
    </div>

    <div class="borrowing-table-wrapper">
        <table class="borrowing-table">
            <thead>
                <tr>
                    <th>User Name</th>
                    <th>Book Name</th>
                    <th>Request Date</th>
                    <th>Decision Date</th>
                    <th>Status</th>
                    <th>Rejection Reason</th>
                </tr>
            </thead>

            <tbody>
                <% if (rejectedBorrowRequests.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="empty-borrowings">
                            <i class="fa-solid fa-circle-info"></i>
                            <p>No rejected borrow requests found.</p>
                        </td>
                    </tr>
                <% } else {
                    for (Map<String, Object> rejected :
                            rejectedBorrowRequests) {

                        String userName =
                            (String) rejected.get("userName");

                        String bookTitle =
                            (String) rejected.get("bookTitle");

                        Timestamp requestDate =
                            (Timestamp) rejected.get("requestDate");

                        Timestamp decidedAt =
                            (Timestamp) rejected.get("decidedAt");

                        String rejectionReason =
                            (String) rejected.get("rejectionReason");
                %>
                    <tr>
                        <td class="borrow-user">
                            <i class="fa-solid fa-user"></i>
                            <%= escapeHtml(userName) %>
                        </td>

                        <td class="borrow-book">
                            <%= escapeHtml(bookTitle) %>
                        </td>

                        <td>
                            <%= requestDate == null ? "N/A" :
                                requestDate.toLocalDateTime()
                                           .format(dateFormatter) %>
                        </td>

                        <td>
                            <%= decidedAt == null ? "N/A" :
                                decidedAt.toLocalDateTime()
                                         .format(dateFormatter) %>
                        </td>

                        <td>
                            <span class="borrow-status rejected">
                                REJECTED
                            </span>
                        </td>

                        <td>
                            <%= escapeHtml(rejectionReason) %>
                        </td>
                    </tr>
                <%  }
                   } %>
            </tbody>
        </table>
    </div>

    <div class="borrowing-table-footer">
        Showing <strong><%= rejectedBorrowRequests.size() %></strong>
        rejected requests
    </div>

</section>
