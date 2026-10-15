
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.tap.model.Fine" %>

<%!
    private String escapeFineHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String formatFineDate(LocalDateTime dateTime) {
        if (dateTime == null) {
            return "—";
        }

        return dateTime.format(
                DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
    }
%>

<%
    List<Fine> userFines =
            (List<Fine>) request.getAttribute("userFines");

    if (userFines == null) {
        userFines = new ArrayList<Fine>();
    }

    int totalFineCount = userFines.size();
    int pendingFineCount = 0;
    int paidFineCount = 0;

    BigDecimal pendingFineTotal = BigDecimal.ZERO;
    BigDecimal allFineTotal = BigDecimal.ZERO;

    for (Fine fine : userFines) {
        BigDecimal amount = fine.getFineAmount();

        if (amount == null) {
            amount = BigDecimal.ZERO;
        }

        allFineTotal = allFineTotal.add(amount);

        if ("PENDING".equalsIgnoreCase(fine.getStatus())) {
            pendingFineCount++;
            pendingFineTotal = pendingFineTotal.add(amount);
        } else if ("PAID".equalsIgnoreCase(fine.getStatus())) {
            paidFineCount++;
        }
    }
%>

<div class="user-fines-page">

    <section class="user-fines-intro">
        <div>
            <span class="user-fines-eyebrow">
                YOUR LIBRARY ACCOUNT
            </span>

            <h2>My Fines</h2>

            <p>
                Review your overdue charges and keep track of your
                library account.
            </p>
        </div>

        <div class="user-fines-total-badge">
            <span>Total Fine Amount</span>
            <strong>&#8377;<%= allFineTotal.toPlainString() %></strong>
        </div>
    </section>

    <section class="user-fines-stats">

        <article class="user-fine-stat-card">
            <div class="user-fine-stat-icon">
                <i class="fas fa-receipt"></i>
            </div>

            <div>
                <span>Total Fine Records</span>
                <h3><%= totalFineCount %></h3>
            </div>
        </article>

        <article class="user-fine-stat-card">
            <div class="user-fine-stat-icon pending">
                <i class="fas fa-clock"></i>
            </div>

            <div>
                <span>Pending Fines</span>
                <h3><%= pendingFineCount %></h3>
            </div>
        </article>

        <article class="user-fine-stat-card">
            <div class="user-fine-stat-icon paid">
                <i class="fas fa-check-circle"></i>
            </div>

            <div>
                <span>Paid Fine Records</span>
                <h3><%= paidFineCount %></h3>
            </div>
        </article>

        <article class="user-fine-stat-card">
            <div class="user-fine-stat-icon amount">
                <i class="fas fa-wallet"></i>
            </div>

            <div>
                <span>Pending Amount</span>
                <h3>&#8377;<%= pendingFineTotal.toPlainString() %></h3>
            </div>
        </article>

    </section>

    <section class="user-fines-section">

        <div class="user-fines-section-heading">
            <div>
                <h3>Fine History</h3>
                <p>View the details and current status of each fine.</p>
            </div>

            <span class="user-fines-record-count">
                <%= totalFineCount %> records
            </span>
        </div>

        <% if (userFines.isEmpty()) { %>

            <div class="user-fines-empty">
                <div class="user-fines-empty-icon">
                    <i class="fas fa-file-invoice-dollar"></i>
                </div>

                <h3>No Fine Records</h3>

                <p>
                    You currently have no recorded library fines.
                </p>

                <a href="<%= request.getContextPath() %>/user/borrowings"
                   class="user-fines-action-link">
                    View My Borrowings
                    <i class="fas fa-arrow-right"></i>
                </a>
            </div>

        <% } else { %>

            <div class="user-fines-table-wrapper">

                <table class="user-fines-table">

                    <thead>
                        <tr>
                            <th>Fine Details</th>
                            <th>Borrow ID</th>
                            <th>Overdue Days</th>
                            <th>Fine Amount</th>
                            <th>Created On</th>
                            <th>Paid On</th>
                            <th>Status</th>
                        </tr>
                    </thead>

                    <tbody>

                        <% for (Fine fine : userFines) { %>

                            <tr>
                                <td>
                                    <div class="user-fine-title">
                                        <span class="user-fine-row-icon">
                                            <i class="fas fa-file-invoice"></i>
                                        </span>

                                        <div>
                                            <strong>
                                                Fine #<%= fine.getFineId() %>
                                            </strong>

                                            <small>
                                                Library overdue charge
                                            </small>
                                        </div>
                                    </div>
                                </td>

                                <td>
                                    #<%= fine.getBorrowId() %>
                                </td>

                                <td>
                                    <span class="user-fine-days">
                                        <%= fine.getDaysOverdue() %> days
                                    </span>
                                </td>

                                <td>
                                    <strong class="user-fine-amount">
                                        ₹<%= fine.getFineAmount() == null
                                                ? "0.00"
                                                : fine.getFineAmount()
                                                       .toPlainString() %>
                                    </strong>
                                </td>

                                <td>
                                    <%= escapeFineHtml(
                                            formatFineDate(fine.getCreatedAt())) %>
                                </td>

                                <td>
                                    <%= escapeFineHtml(
                                            formatFineDate(fine.getPaidAt())) %>
                                </td>

                                <td>
                                    <% if ("PAID".equalsIgnoreCase(fine.getStatus())) { %>

                                        <span class="user-fine-status paid">
                                            <i class="fas fa-check-circle"></i>
                                            Paid
                                        </span>

                                    <% } else if ("PENDING".equalsIgnoreCase(fine.getStatus())) { %>

                                        <span class="user-fine-status pending">
                                            <i class="fas fa-clock"></i>
                                            Pending
                                        </span>

                                    <% } else { %>

                                        <span class="user-fine-status">
                                            <%= escapeFineHtml(fine.getStatus()) %>
                                        </span>

                                    <% } %>
                                </td>
                            </tr>

                        <% } %>

                    </tbody>

                </table>

            </div>

        <% } %>

    </section>

    <section class="user-fines-info">
        <i class="fas fa-info-circle"></i>

        <p>
            Library fines are calculated at &#8377;10 per overdue day.
            This page displays your recorded fine information and
            payment status.
        </p>
    </section>

</div>
