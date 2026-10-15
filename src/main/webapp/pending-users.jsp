
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.tap.model.User" %>

<%
    // GET THE LOGGED-IN ADMIN AND APPLICATION CONTEXT
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    String contextPath = request.getContextPath();

    // ALLOW ONLY ADMIN USERS TO ACCESS THIS PAGE
    if (loggedInUser == null
            || !"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    // GET PENDING USERS FROM THE CONTROLLER
    List<User> pendingUsers =
            (List<User>) request.getAttribute("pendingUsers");

    // FORMAT THE REGISTRATION DATE
    DateTimeFormatter dateFormat =
            DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    // PREPARE THE ACTION RESULT MESSAGE
    String result = request.getParameter("result");
    String resultMessage = "";
    String resultClass = "";

    if ("approved".equals(result)) {
        resultMessage = "User approved successfully.";
        resultClass = "success";
    } else if ("rejected".equals(result)) {
        resultMessage = "User registration rejected successfully.";
        resultClass = "success";
    } else if ("failed".equals(result)) {
        resultMessage = "Unable to complete the requested action.";
        resultClass = "error";
    } else if ("invalid".equals(result)) {
        resultMessage = "Invalid action or user selection.";
        resultClass = "error";
    }
%>

<div class="approval-page">

    <!-- BACK TO THE ADMIN DASHBOARD -->
    <a href="<%= contextPath %>/admin-dashboard" class="back-link">
        <i class="fa-solid fa-arrow-left"></i>
        Back to Dashboard
    </a>

    <!-- PAGE HEADING -->
    <section class="approval-heading">
        <div>
            <h1>Pending Registrations</h1>
            <p>Review each registration before granting library access.</p>
        </div>

        <div class="approval-count">
            <i class="fa-solid fa-user-clock"></i>
            Pending:
            <%= pendingUsers == null ? 0 : pendingUsers.size() %>
        </div>
    </section>

    <!-- DISPLAY CONTROLLER ACTION RESULTS -->
    <% if (!resultMessage.isEmpty()) { %>
        <div class="result-message <%= resultClass %>" role="status">
            <i class="fa-solid <%= "success".equals(resultClass)
                    ? "fa-circle-check"
                    : "fa-circle-exclamation" %>"></i>
            <span><%= resultMessage %></span>
        </div>
    <% } %>

    <!-- PENDING USERS TABLE -->
    <section class="approval-table-container">

        <% if (pendingUsers == null || pendingUsers.isEmpty()) { %>

            <!-- EMPTY STATE -->
            <div class="empty-approvals">
                <i class="fa-solid fa-circle-check"></i>
                <h2>All caught up!</h2>
                <p>There are no pending registrations to review.</p>
            </div>

        <% } else { %>

            <div class="pending-table-wrapper">
                <table class="approval-table">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Phone</th>
                            <th>Address</th>
                            <th>Registered</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>

                    <tbody>
                        <% for (User pendingUser : pendingUsers) { %>
                            <tr>
                                <td>
                                    <div class="applicant-name">
                                        <%= pendingUser.getName() == null
                                                ? ""
                                                : pendingUser.getName()
                                                    .replace("&", "&amp;")
                                                    .replace("<", "&lt;")
                                                    .replace(">", "&gt;")
                                                    .replace("\"", "&quot;")
                                                    .replace("'", "&#x27;") %>
                                    </div>

                                    <div class="applicant-email">
                                        <%= pendingUser.getEmail() == null
                                                ? ""
                                                : pendingUser.getEmail()
                                                    .replace("&", "&amp;")
                                                    .replace("<", "&lt;")
                                                    .replace(">", "&gt;")
                                                    .replace("\"", "&quot;")
                                                    .replace("'", "&#x27;") %>
                                    </div>
                                </td>

                                <td>
                                    <%= pendingUser.getPhone() == null
                                            ? "—"
                                            : pendingUser.getPhone()
                                                .replace("&", "&amp;")
                                                .replace("<", "&lt;")
                                                .replace(">", "&gt;")
                                                .replace("\"", "&quot;")
                                                .replace("'", "&#x27;") %>
                                </td>

                                <td>
                                    <div class="applicant-address">
                                        <%= pendingUser.getAddress() == null
                                                || pendingUser.getAddress()
                                                    .trim().isEmpty()
                                                ? "—"
                                                : pendingUser.getAddress()
                                                    .replace("&", "&amp;")
                                                    .replace("<", "&lt;")
                                                    .replace(">", "&gt;")
                                                    .replace("\"", "&quot;")
                                                    .replace("'", "&#x27;") %>
                                    </div>
                                </td>

                                <td class="registration-date">
                                    <%= pendingUser.getRegisteredAt() == null
                                            ? "—"
                                            : pendingUser.getRegisteredAt()
                                                .format(dateFormat) %>
                                </td>

                                <td>
                                    <span class="pending-badge">
                                        <i class="fa-solid fa-clock"></i>
                                        PENDING
                                    </span>
                                </td>

                                <td>
                                    <!-- APPROVE AND REJECT ACTIONS -->
                                    <div class="approval-actions">

                                        <form method="post"
                                              action="<%= contextPath %>/admin/pending-users"
                                              onsubmit="return confirm('Approve this user registration?');">

                                            <input type="hidden" name="action"
                                                   value="approve">

                                            <input type="hidden" name="userId"
                                                   value="<%= pendingUser.getUserId() %>">

                                            <button type="submit"
                                                    class="approval-button approve-button">
                                                <i class="fa-solid fa-check"></i>
                                                Approve
                                            </button>
                                        </form>

                                        <form method="post"
                                              action="<%= contextPath %>/admin/pending-users"
                                              onsubmit="return confirm('Reject this user registration?');">

                                            <input type="hidden" name="action"
                                                   value="reject">

                                            <input type="hidden" name="userId"
                                                   value="<%= pendingUser.getUserId() %>">

                                            <button type="submit"
                                                    class="approval-button reject-button">
                                                <i class="fa-solid fa-xmark"></i>
                                                Reject
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