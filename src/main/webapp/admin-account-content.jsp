
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tap.model.User" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%!
    private String escapeAdminAccountHtml(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "Not provided";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String escapeAdminFormValue(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String formatAdminAccountDate(LocalDateTime date) {
        if (date == null) {
            return "Not available";
        }

        return date.format(
            DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")
        );
    }
%>

<%
    User accountUser = (User) request.getAttribute("accountUser");

    if (accountUser == null
            || !"ADMIN".equalsIgnoreCase(accountUser.getRole())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    String contextPath = request.getContextPath();

    String adminName = accountUser.getName() == null
            ? "Administrator"
            : accountUser.getName().trim();

    String adminInitial = adminName.isEmpty()
            ? "A"
            : adminName.substring(0, 1).toUpperCase();

    String accountStatus = accountUser.getStatus() == null
            ? "UNKNOWN"
            : accountUser.getStatus().toUpperCase();

    String profileMessage =
            (String) request.getAttribute("profileMessage");

    String profileMessageType =
            (String) request.getAttribute("profileMessageType");

    boolean showEditMode = "error".equalsIgnoreCase(profileMessageType);
%>

<div class="admin-account-page">

    <section class="admin-account-hero">

        <div class="admin-account-avatar">
            <%= escapeAdminAccountHtml(adminInitial) %>
        </div>

        <div class="admin-account-hero-info">
            <span class="admin-account-eyebrow">
                ADMINISTRATOR PROFILE
            </span>

            <h2>
                <%= escapeAdminAccountHtml(adminName) %>
            </h2>

            <p>
                <%= escapeAdminAccountHtml(accountUser.getEmail()) %>
            </p>

            <div class="admin-account-badges">
                <span class="admin-account-role-badge">
                    <i class="fa-solid fa-shield-halved"></i>
                    Administrator
                </span>

                <span class="admin-account-status-badge">
                    <i class="fa-solid fa-circle-check"></i>
                    <%= escapeAdminAccountHtml(accountStatus) %>
                </span>
            </div>
        </div>

        <div class="admin-account-hero-action">
            <button type="button"
                    class="admin-account-btn admin-account-btn-primary"
                    id="editProfileButton"
                    onclick="toggleAdminProfileEdit(true)">
                <i class="fa-solid fa-pen-to-square"></i>
                Edit Profile
            </button>
        </div>

    </section>

    <% if (profileMessage != null && !profileMessage.trim().isEmpty()) { %>
        <div class="admin-account-message <%= "success".equalsIgnoreCase(profileMessageType) ? "success" : "error" %>">
            <i class="fa-solid <%= "success".equalsIgnoreCase(profileMessageType) ? "fa-circle-check" : "fa-circle-exclamation" %>"></i>
            <span><%= escapeAdminAccountHtml(profileMessage) %></span>
        </div>
    <% } %>

    <section class="admin-account-section">

        <div class="admin-account-section-heading">
            <div>
                <h3>Personal Information</h3>
                <p>View and manage your administrator contact details.</p>
            </div>

            <span class="admin-account-section-icon">
                <i class="fa-solid fa-user-gear"></i>
            </span>
        </div>

        <div id="adminProfileReadMode"
             class="admin-account-details-grid"
             style="<%= showEditMode ? "display:none;" : "" %>">

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-user"></i>
                    Full Name
                </span>

                <p>
                    <%= escapeAdminAccountHtml(accountUser.getName()) %>
                </p>
            </div>

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-envelope"></i>
                    Email Address
                </span>

                <p>
                    <%= escapeAdminAccountHtml(accountUser.getEmail()) %>
                </p>
            </div>

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-phone"></i>
                    Phone Number
                </span>

                <p>
                    <%= escapeAdminAccountHtml(accountUser.getPhone()) %>
                </p>
            </div>

            <div class="admin-account-detail-card admin-account-address-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-location-dot"></i>
                    Address
                </span>

                <p>
                    <%= escapeAdminAccountHtml(accountUser.getAddress()) %>
                </p>
            </div>

        </div>

        <form id="adminProfileEditMode"
              class="admin-account-edit-form"
              action="<%= contextPath %>/admin/account"
              method="post"
              style="<%= showEditMode ? "" : "display:none;" %>">

            <div class="admin-account-form-grid">

                <div class="admin-account-form-group">
                    <label for="adminName">Full Name</label>

                    <input type="text"
                           id="adminName"
                           name="name"
                           maxlength="100"
                           value="<%= escapeAdminFormValue(accountUser.getName()) %>"
                           required>
                </div>

                <div class="admin-account-form-group">
                    <label for="adminEmail">Email Address</label>

                    <input type="email"
                           id="adminEmail"
                           name="email"
                           maxlength="255"
                           value="<%= escapeAdminFormValue(accountUser.getEmail()) %>"
                           required>
                </div>

                <div class="admin-account-form-group">
                    <label for="adminPhone">Phone Number</label>

                    <input type="tel"
                           id="adminPhone"
                           name="phone"
                           maxlength="10"
                           pattern="[0-9]{10}"
                           title="Enter a valid 10-digit phone number"
                           value="<%= escapeAdminFormValue(accountUser.getPhone()) %>"
                           required>
                </div>

                <div class="admin-account-form-group admin-account-address-field">
                    <label for="adminAddress">Address</label>

                    <textarea id="adminAddress"
                              name="address"
                              rows="3"
                              maxlength="500"
                              required><%= escapeAdminFormValue(accountUser.getAddress()) %></textarea>
                </div>

            </div>

            <div class="admin-account-form-actions">

                <button type="submit"
                        class="admin-account-btn admin-account-btn-primary">
                    <i class="fa-solid fa-floppy-disk"></i>
                    Save Changes
                </button>

                <button type="button"
                        class="admin-account-btn admin-account-btn-secondary"
                        onclick="toggleAdminProfileEdit(false)">
                    Cancel
                </button>

            </div>

        </form>

    </section>

    <section class="admin-account-section">

        <div class="admin-account-section-heading">
            <div>
                <h3>Account Information</h3>
                <p>Your library administrator account details.</p>
            </div>

            <span class="admin-account-section-icon">
                <i class="fa-solid fa-id-card"></i>
            </span>
        </div>

        <div class="admin-account-details-grid">

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-hashtag"></i>
                    Administrator ID
                </span>

                <p>#<%= accountUser.getUserId() %></p>
            </div>

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-user-shield"></i>
                    Account Role
                </span>

                <p>Administrator</p>
            </div>

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-calendar-plus"></i>
                    Registered On
                </span>

                <p>
                    <%= formatAdminAccountDate(accountUser.getRegisteredAt()) %>
                </p>
            </div>

            <div class="admin-account-detail-card">
                <span class="admin-account-detail-label">
                    <i class="fa-solid fa-calendar-check"></i>
                    Approved On
                </span>

                <p>
                    <%= formatAdminAccountDate(accountUser.getApprovedAt()) %>
                </p>
            </div>

        </div>

    </section>

    <div class="admin-account-security-note">
        <i class="fa-solid fa-lock"></i>

        <div>
            <strong>Account Security</strong>
            <p>
                This page allows you to update personal profile information.
                Your administrator role and account status cannot be changed here.
            </p>
        </div>
    </div>

</div>

<script>
    function toggleAdminProfileEdit(showEdit) {
        const readMode = document.getElementById("adminProfileReadMode");
        const editMode = document.getElementById("adminProfileEditMode");
        const editButton = document.getElementById("editProfileButton");

        if (!readMode || !editMode) {
            return;
        }

        readMode.style.display = showEdit ? "none" : "grid";
        editMode.style.display = showEdit ? "block" : "none";

        if (editButton) {
            editButton.style.display = showEdit ? "none" : "inline-flex";
        }
    }

    <% if (showEditMode) { %>
        toggleAdminProfileEdit(true);
    <% } %>
</script>

