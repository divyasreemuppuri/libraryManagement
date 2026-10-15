
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    // ESCAPE HTML CHARACTERS BEFORE DISPLAYING USER DATA
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
    // RETRIEVE REGISTERED USERS
    List<User> usersList =
        (List<User>) request.getAttribute("usersList");

    if (usersList == null) {
        usersList = java.util.Collections.emptyList();
    }

    DateTimeFormatter dateFormatter =
        DateTimeFormatter.ofPattern("dd MMM yyyy");

    String contextPath = request.getContextPath();

    // RETRIEVE DELETE OPERATION MESSAGES
    String successMessage =
        (String) request.getAttribute("successMessage");

    String errorMessage =
        (String) request.getAttribute("errorMessage");
%>

<section class="management-section borrowing-management">

    <div class="section-heading borrowing-records-heading">
        <div>
            <h2>Registered Users</h2>
            <p class="section-description">
                View registered accounts and manage library users.
            </p>
        </div>
    </div>

    <% if (successMessage != null) { %>
        <div class="user-alert user-alert-success" role="status">
            <i class="fa-solid fa-circle-check"></i>
            <%= escapeHtml(successMessage) %>
        </div>
    <% } %>

    <% if (errorMessage != null) { %>
        <div class="user-alert user-alert-error" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i>
            <%= escapeHtml(errorMessage) %>
        </div>
    <% } %>

    <div class="borrowing-table-wrapper">
        <table class="borrowing-table">
            <thead>
                <tr>
                    <th>User ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Role</th>
                    <th>Registered Date</th>
                    <th>Account Status</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody>
                <% if (usersList.isEmpty()) { %>
                    <tr>
                        <td colspan="8" class="empty-borrowings">
                            <i class="fa-solid fa-users"></i>
                            <p>No registered users found.</p>
                        </td>
                    </tr>
                <% } else {
                    for (User user : usersList) {

                        String role = user.getRole();
                        String status = user.getStatus();

                        String statusClass = "borrowed";

                        if ("APPROVED".equalsIgnoreCase(status)) {
                            statusClass = "returned";
                        } else if ("REJECTED".equalsIgnoreCase(status)) {
                            statusClass = "overdue";
                        }
                %>
                    <tr>
                        <td><%= user.getUserId() %></td>

                        <td class="borrow-user">
                            <i class="fa-solid fa-user"></i>
                            <%= escapeHtml(user.getName()) %>
                        </td>

                        <td><%= escapeHtml(user.getEmail()) %></td>

                        <td><%= escapeHtml(user.getPhone()) %></td>

                        <td><%= escapeHtml(role) %></td>

                        <td>
                            <%= user.getRegisteredAt() == null
                                ? "N/A"
                                : user.getRegisteredAt()
                                      .format(dateFormatter) %>
                        </td>

                        <td>
                            <span class="borrow-status <%= statusClass %>">
                                <%= escapeHtml(status) %>
                            </span>
                        </td>

                        <td>
                            <% if (!"ADMIN".equalsIgnoreCase(role)) { %>
                                <form
                                    action="<%= contextPath %>/admin/delete-user"
                                    method="post"
                                    onsubmit="return confirm('Are you sure you want to delete this user? This action cannot be undone.');">

                                    <input
                                        type="hidden"
                                        name="userId"
                                        value="<%= user.getUserId() %>">

                                    <button
                                        type="submit"
                                        class="delete-user-button">
                                        <i class="fa-solid fa-trash"></i>
                                        Delete
                                    </button>
                                </form>
                            <% } else { %>
                                <span>Protected account</span>
                            <% } %>
                        </td>
                    </tr>
                <%  }
                   } %>
            </tbody>
        </table>
    </div>

    <div class="borrowing-table-footer">
        Total registered users:
        <strong><%= usersList.size() %></strong>
    </div>

</section>
