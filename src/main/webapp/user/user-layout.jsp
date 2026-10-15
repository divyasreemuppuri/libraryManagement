
<%@ page import="com.tap.model.User" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
        if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin-dashboard");
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
        return;
    }

    String contextPath = request.getContextPath();

    String pageTitle = (String) request.getAttribute("pageTitle");
    String pageSubtitle = (String) request.getAttribute("pageSubtitle");
    String activePage = (String) request.getAttribute("activePage");
    String contentPage = (String) request.getAttribute("contentPage");

    if (pageTitle == null) pageTitle = "Dashboard";
    if (pageSubtitle == null) pageSubtitle = "Welcome to your personal library";
    if (activePage == null) activePage = "dashboard";
    if (contentPage == null) contentPage = "/user/dashboard-content.jsp";

    String userName = loggedInUser.getName() == null
            ? "User" : loggedInUser.getName().trim();

    String userInitial = userName.isEmpty()
            ? "U" : userName.substring(0, 1).toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title><%= pageTitle %> | Library Management System</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <link rel="stylesheet"
          href="<%= contextPath %>/css/user-dashboard.css">
</head>

<body>

<div class="user-dashboard-container">

    <!-- SHARED SIDEBAR -->
    <aside class="user-sidebar" id="userSidebar">

        <div class="user-sidebar-brand">
            <div class="user-brand-icon">
                <i class="fas fa-book-open"></i>
            </div>
            <div class="user-brand-text">
                <h2>Library</h2>
                <span>Member Portal</span>
            </div>
        </div>

        <div class="user-sidebar-profile">
            <div class="user-profile-avatar">
                <%= userInitial %>
            </div>
            <div class="user-profile-info">
                <h3><%= userName.replace("&", "&amp;")
                                .replace("<", "&lt;")
                                .replace(">", "&gt;")
                                .replace("\"", "&quot;")
                                .replace("'", "&#39;") %></h3>
                <span>Library Member</span>
            </div>
        </div>

        <nav class="user-sidebar-nav">

            <p class="user-nav-heading">MAIN MENU</p>

            <a href="<%= contextPath %>/user-dashboard"
               class="user-nav-link <%= "dashboard".equals(activePage) ? "active" : "" %>">
                <i class="fas fa-house"></i>
                <span>Dashboard</span>
            </a>

            <a href="<%= contextPath %>/user/books"
               class="user-nav-link <%= "books".equals(activePage) ? "active" : "" %>">
                <i class="fas fa-book"></i>
                <span>Browse Books</span>
            </a>

            <a href="<%= contextPath %>/user/borrowings"
               class="user-nav-link <%= "borrowings".equals(activePage) ? "active" : "" %>">
                <i class="fas fa-book-reader"></i>
                <span>My Borrowings</span>
            </a>
			<a href="<%= contextPath %>/user/borrowing-history"
			   class="user-nav-link <%= "history".equals(activePage) ? "active" : "" %>">
			    <i class="fas fa-history"></i>
			    <span>Borrowing History</span>
			</a>
            <a href="<%= contextPath %>/user/fines"
               class="user-nav-link <%= "fines".equals(activePage) ? "active" : "" %>">
                <i class="fas fa-wallet"></i>
                <span>My Fines</span>
            </a>

            <p class="user-nav-heading">ACCOUNT</p>

            <a href="<%= contextPath %>/user/account"
               class="user-nav-link <%= "account".equals(activePage) ? "active" : "" %>">
                <i class="fas fa-user-circle"></i>
                <span>My Account</span>
            </a>

            <a href="<%= contextPath %>/home" class="user-nav-link">
                <i class="fas fa-globe"></i>
                <span>Public Library</span>
            </a>

        </nav>

        <div class="user-sidebar-footer">
            <a href="<%= contextPath %>/logout" class="user-nav-link logout-link">
                <i class="fas fa-right-from-bracket"></i>
                <span>Logout</span>
            </a>
        </div>

    </aside>

    <!-- MOBILE SIDEBAR OVERLAY -->
    <div class="user-sidebar-overlay" id="userSidebarOverlay"></div>

    <!-- RIGHT-SIDE APPLICATION AREA -->
    <main class="user-main-content">

        <!-- SHARED TOPBAR -->
        <header class="user-topbar">

            <div class="user-topbar-left">
                <button type="button"
                        class="user-mobile-menu-button"
                        id="userMobileMenuButton"
                        aria-label="Open navigation menu"
                        aria-expanded="false">
                    <i class="fas fa-bars"></i>
                </button>

                <div class="user-page-heading">
                    <h1><%= pageTitle %></h1>
                    <p><%= pageSubtitle %></p>
                </div>
            </div>

            <div class="user-topbar-right">
                <div class="user-topbar-welcome">
                    <span>Welcome back,</span>
                    <strong><%= userName.replace("&", "&amp;")
                                        .replace("<", "&lt;")
                                        .replace(">", "&gt;")
                                        .replace("\"", "&quot;")
                                        .replace("'", "&#39;") %></strong>
                </div>

                <div class="user-topbar-avatar">
                    <%= userInitial %>
                </div>
            </div>

        </header>

        <!-- ONLY THIS CONTENT CHANGES BETWEEN USER PAGES -->
        <section class="user-page-content">
            <jsp:include page="<%= contentPage %>" />
        </section>

    </main>

</div>

<script src="<%= contextPath %>/js/user-dashboard.js"></script>

</body>
</html>
