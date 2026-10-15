
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.function.Function" %>

<%!
    // ESCAPE HTML VALUES BEFORE DISPLAYING THEM
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    // GET FINE RECORDS FROM THE CONTROLLER
    List<Map<String, Object>> fineList =
            (List<Map<String, Object>>) request.getAttribute("fineList");

    if (fineList == null) {
        fineList = java.util.Collections.emptyList();
    }

    // PREPARE DATE FORMATTING
    SimpleDateFormat dateFormat =
            new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    // GET ANY ERROR MESSAGE FROM THE CONTROLLER
    String errorMessage =
            (String) request.getAttribute("errorMessage");
%>

<div class="management-section fines-management-section">

    <div class="section-heading">
        <div>
            <h2>Fine Records</h2>
            <p class="section-description">
                View overdue fines and their payment status.
            </p>
        </div>

        <div class="fines-record-count">
            Total Records:
            <strong><%= fineList.size() %></strong>
        </div>
    </div>

    <% if (errorMessage != null) { %>
        <div class="fines-error-message">
            <%= escapeHtml(errorMessage) %>
        </div>
    <% } %>

    <div class="fines-table-container">

        <table class="fines-table">

            <thead>
                <tr>
                    <th>User Name</th>
                    <th>Book Name</th>
                    <th>Days Overdue</th>
                    <th>Fine Amount</th>
                    <th>Created Date</th>
                    <th>Payment Status</th>
                    <th>Paid Date</th>
                </tr>
            </thead>

            <tbody>

                <% if (fineList.isEmpty()) { %>

                    <tr>
                        <td colspan="7" class="fines-empty-state">
                            <div class="fines-empty-icon">
                                <i class="fas fa-receipt"></i>
                            </div>

                            <strong>No fine records found</strong>

                            <p>
                                Fine records will appear here when overdue
                                fines have been generated.
                            </p>
                        </td>
                    </tr>

                <% } else { %>

                    <% for (Map<String, Object> fine : fineList) { %>

                        <%
                            String userName =
                                    (String) fine.get("userName");

                            String bookTitle =
                                    (String) fine.get("bookTitle");

                            Integer daysOverdue =
                                    (Integer) fine.get("daysOverdue");

                            BigDecimal fineAmount =
                                    (BigDecimal) fine.get("fineAmount");

                            Timestamp createdAt =
                                    (Timestamp) fine.get("createdAt");

                            Timestamp paidAt =
                                    (Timestamp) fine.get("paidAt");

                            String status =
                                    (String) fine.get("status");

                            boolean isPaid =
                                    "PAID".equalsIgnoreCase(status);
                        %>

                        <tr>

                            <td>
                                <span class="fines-user-name">
                                    <%= escapeHtml(userName) %>
                                </span>
                            </td>

                            <td>
                                <span class="fines-book-title">
                                    <%= escapeHtml(bookTitle) %>
                                </span>
                            </td>

                            <td>
                                <span class="fines-days">
                                    <%= daysOverdue == null ? 0 : daysOverdue %>
                                    <%= daysOverdue != null
                                            && daysOverdue == 1
                                            ? "day" : "days" %>
                                </span>
                            </td>

                            <td>
                                <span class="fines-amount">
                                    ₹<%= fineAmount == null
                                            ? "0.00"
                                            : fineAmount.toPlainString() %>
                                </span>
                            </td>

                            <td>
                                <span class="fines-date">
                                    <%= createdAt == null
                                            ? "—"
                                            : dateFormat.format(createdAt) %>
                                </span>
                            </td>

                            <td>
                                <span class="fines-status <%= isPaid
                                        ? "paid"
                                        : "pending" %>">

                                    <span class="fines-status-dot"></span>

                                    <%= escapeHtml(status) %>
                                </span>
                            </td>

                            <td>
                                <span class="fines-date">
                                    <%= paidAt == null
                                            ? "—"
                                            : dateFormat.format(paidAt) %>
                                </span>
                            </td>

                        </tr>

                    <% } %>

                <% } %>

            </tbody>

        </table>

    </div>

</div>
