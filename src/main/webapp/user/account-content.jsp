
<%@ page pageEncoding="UTF-8"
         contentType="text/html; charset=UTF-8" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%!
    // ESCAPE HTML TO PREVENT HTML INJECTION
    private String escapeAccountHtml(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "Not provided";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    // FORMAT ACCOUNT DATES
    private String formatAccountDate(LocalDateTime dateTime) {
        if (dateTime == null) {
            return "Not available";
        }

        return dateTime.format(
                DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
    }
%>

<%
    User accountUser =
            (User) request.getAttribute("accountUser");

    if (accountUser == null) {
        response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "User profile information is unavailable.");
        return;
    }

    String displayName = accountUser.getName() == null
            ? "U"
            : accountUser.getName().trim();

    String initial = displayName.isEmpty()
            ? "U"
            : displayName.substring(0, 1).toUpperCase();

    String accountStatus = accountUser.getStatus() == null
            ? "UNKNOWN"
            : accountUser.getStatus().toUpperCase();

    String role = accountUser.getRole() == null
            ? "USER"
            : accountUser.getRole();

    String profileMessage =
            (String) request.getAttribute("profileMessage");

    String profileMessageType =
            (String) request.getAttribute("profileMessageType");
%>

<div class="user-account-page">

    <!-- PROFILE INTRODUCTION -->
    <section class="user-account-hero">

        <div class="user-account-avatar">
            <%= escapeAccountHtml(initial) %>
        </div>

        <div class="user-account-hero-details">

            <span class="user-account-eyebrow">YOUR PROFILE</span>

            <h2><%= escapeAccountHtml(accountUser.getName()) %></h2>

            <p><%= escapeAccountHtml(accountUser.getEmail()) %></p>

            <div class="user-account-badges">

                <span class="user-account-role">
                    <i class="fas fa-user"></i>
                    <%= escapeAccountHtml(role) %>
                </span>

                <span class="user-account-status <%= "APPROVED".equals(accountStatus) ? "approved" : "other" %>">
                    <i class="fas <%= "APPROVED".equals(accountStatus) ? "fa-check-circle" : "fa-info-circle" %>"></i>
                    <%= escapeAccountHtml(accountStatus) %>
                </span>

            </div>
        </div>

    </section>

    <!-- PROFILE FEEDBACK MESSAGE -->
    <% if (profileMessage != null && !profileMessage.trim().isEmpty()) { %>
        <div class="user-account-message <%= "success".equals(profileMessageType) ? "success" : "error" %>"
             role="status">
            <i class="fas <%= "success".equals(profileMessageType) ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
            <span><%= escapeAccountHtml(profileMessage) %></span>
        </div>
    <% } %>

    <!-- PERSONAL INFORMATION -->
    <section class="user-account-section">

        <div class="user-account-section-heading">

            <div class="user-account-heading-icon">
                <i class="fas fa-user-circle"></i>
            </div>

            <div>
                <h3>Personal Information</h3>
                <p>Your registered contact information.</p>
            </div>

            <button type="button"
                    class="user-account-edit-btn"
                    id="editProfileBtn"
                    onclick="toggleProfileEdit(true)">
                <i class="fas fa-pen"></i>
                Edit Profile
            </button>

        </div>

        <!-- READ-ONLY PROFILE DETAILS -->
        <div id="profileDetailsView">

            <div class="user-account-details-grid">

                <article class="user-account-detail-card">
                    <span class="user-account-detail-label">
                        <i class="fas fa-user"></i>
                        Full Name
                    </span>
                    <strong><%= escapeAccountHtml(accountUser.getName()) %></strong>
                </article>

                <article class="user-account-detail-card">
                    <span class="user-account-detail-label">
                        <i class="fas fa-envelope"></i>
                        Email Address
                    </span>
                    <strong><%= escapeAccountHtml(accountUser.getEmail()) %></strong>
                </article>

                <article class="user-account-detail-card">
                    <span class="user-account-detail-label">
                        <i class="fas fa-phone"></i>
                        Phone Number
                    </span>
                    <strong><%= escapeAccountHtml(accountUser.getPhone()) %></strong>
                </article>

                <article class="user-account-detail-card">
                    <span class="user-account-detail-label">
                        <i class="fas fa-map-marker-alt"></i>
                        Address
                    </span>
                    <strong><%= escapeAccountHtml(accountUser.getAddress()) %></strong>
                </article>

            </div>
        </div>

        <!-- EDITABLE PROFILE FORM -->
        <div id="profileEditView" hidden>

            <form action="<%= request.getContextPath() %>/user/account"
                  method="post"
                  class="user-account-edit-form">

                <div class="user-account-form-grid">

                    <div class="user-account-form-group">
                        <label for="profileName">Full Name</label>
                        <input type="text"
                               id="profileName"
                               name="name"
                               value="<%= escapeAccountHtml(accountUser.getName()) %>"
                               maxlength="100"
                               autocomplete="name"
                               required>
                    </div>

                    <div class="user-account-form-group">
                        <label for="profileEmail">Email Address</label>
                        <input type="email"
                               id="profileEmail"
                               name="email"
                               value="<%= escapeAccountHtml(accountUser.getEmail()) %>"
                               maxlength="255"
                               autocomplete="email"
                               required>
                    </div>

                    <div class="user-account-form-group">
                        <label for="profilePhone">Phone Number</label>
                        <input type="tel"
                               id="profilePhone"
                               name="phone"
                               value="<%= escapeAccountHtml(accountUser.getPhone()) %>"
                               maxlength="10"
                               minlength="10"
                               pattern="[0-9]{10}"
                               inputmode="numeric"
                               autocomplete="tel"
                               title="Enter a 10-digit phone number"
                               required>
                    </div>

                    <div class="user-account-form-group full-width">
                        <label for="profileAddress">Address</label>
                        <textarea id="profileAddress"
                                  name="address"
                                  maxlength="500"
                                  rows="3"
                                  autocomplete="street-address"
                                  required><%= escapeAccountHtml(accountUser.getAddress()) %></textarea>
                    </div>

                </div>

                <div class="user-account-form-actions">

                    <button type="submit"
                            class="user-account-save-btn">
                        <i class="fas fa-save"></i>
                        Save Changes
                    </button>

                    <button type="button"
                            class="user-account-cancel-btn"
                            onclick="toggleProfileEdit(false)">
                        Cancel
                    </button>

                </div>

            </form>
        </div>

    </section>

    <!-- LIBRARY ACCOUNT INFORMATION -->
    <section class="user-account-section">

        <div class="user-account-section-heading">

            <div class="user-account-heading-icon library">
                <i class="fas fa-book-reader"></i>
            </div>

            <div>
                <h3>Library Account</h3>
                <p>Your membership and registration details.</p>
            </div>

        </div>

        <div class="user-account-details-grid">

            <article class="user-account-detail-card">
                <span class="user-account-detail-label">
                    <i class="fas fa-id-card"></i>
                    Member ID
                </span>
                <strong>#<%= accountUser.getUserId() %></strong>
            </article>

            <article class="user-account-detail-card">
                <span class="user-account-detail-label">
                    <i class="fas fa-shield-alt"></i>
                    Account Role
                </span>
                <strong><%= escapeAccountHtml(role) %></strong>
            </article>

            <article class="user-account-detail-card">
                <span class="user-account-detail-label">
                    <i class="fas fa-calendar-alt"></i>
                    Registered On
                </span>
                <strong><%= escapeAccountHtml(formatAccountDate(accountUser.getRegisteredAt())) %></strong>
            </article>

            <article class="user-account-detail-card">
                <span class="user-account-detail-label">
                    <i class="fas fa-user-check"></i>
                    Approved On
                </span>
                <strong><%= escapeAccountHtml(formatAccountDate(accountUser.getApprovedAt())) %></strong>
            </article>

        </div>

    </section>

    <!-- ACCOUNT INFORMATION NOTE -->
    <section class="user-account-note">
        <i class="fas fa-info-circle"></i>
        <p>
            You can update your name, email, phone number, and address.
            Your password, account role, approval status, and library
            membership details cannot be changed from this form.
        </p>
    </section>

</div>

<script>
    // SWITCH BETWEEN PROFILE VIEW AND EDIT MODE
    function toggleProfileEdit(showEdit) {
        const detailsView = document.getElementById("profileDetailsView");
        const editView = document.getElementById("profileEditView");
        const editButton = document.getElementById("editProfileBtn");

        detailsView.hidden = showEdit;
        editView.hidden = !showEdit;
        editButton.hidden = showEdit;
    }

    // OPEN EDIT MODE WHEN THE SERVER RETURNS A VALIDATION ERROR
    <% if ("error".equals(profileMessageType)) { %>
        toggleProfileEdit(true);
    <% } %>
</script>
