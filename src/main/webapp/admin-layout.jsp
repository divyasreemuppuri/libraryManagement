
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.tap.model.User" %>

<%
    // CHECK THAT AN ADMIN IS LOGGED IN
    User loggedInUser = (User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendError(403, "Access denied.");
        return;
    }

    // PREPARE SHARED LAYOUT VALUES
    String contextPath = request.getContextPath();
    String adminName = loggedInUser.getName();

    if (adminName == null || adminName.trim().isEmpty()) {
        adminName = "Administrator";
    } else {
        adminName = adminName.trim();
    }

    String adminInitial = adminName.substring(0, 1).toUpperCase();

    String pageTitle = (String) request.getAttribute("pageTitle");
    String pageSubtitle = (String) request.getAttribute("pageSubtitle");
    String activePage = (String) request.getAttribute("activePage");
    String adminContent = (String) request.getAttribute("adminContent");

    if (pageTitle == null) pageTitle = "Overview";
    if (pageSubtitle == null) pageSubtitle = "Library Management System";
    if (activePage == null) activePage = "overview";

    // SELECT PAGE-SPECIFIC STYLESHEET
    String pageCss = null;

    if ("books".equals(activePage)) {
        pageCss = "admin-books.css";
    } else if ("add-book".equals(activePage)) {
        pageCss = "admin-books.css";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> | Library Admin</title>

    <!-- LOAD THE SHARED ADMIN STYLES -->
    <link rel="stylesheet"
          href="<%= contextPath %>/css/admin-dashboard.css">

    <!-- LOAD FONT AWESOME ICONS -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <!-- LOAD PAGE-SPECIFIC STYLES -->
    <% if (pageCss != null) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/<%= pageCss %>">
    <% } %>

    <% if ("books".equals(activePage)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/admin-books.css">
    <% } %>

    <% if ("add-book".equals(activePage)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/add-book.css">
    <% } %>

    <% if ("pending-users".equals(activePage)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/pending-users.css">
    <% } %>

    <% if ("/edit-book.jsp".equals(adminContent)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/add-book.css">
        <link rel="stylesheet"
              href="<%= contextPath %>/css/edit-book.css">
    <% } %>

    <% if ("borrowings".equals(activePage)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/admin-borrowings.css">
    <% } %>

    <% if ("borrow-requests".equals(activePage)
            || "renewal-requests".equals(activePage)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/admin-borrowings.css">
    <% } %>

    <% if ("fines".equals(activePage)) { %>
        <link rel="stylesheet"
              href="<%= contextPath %>/css/admin-fines.css">
    <% } %>
    <% if ("users".equals(activePage)) { %>
	    <link rel="stylesheet"
	          href="<%= contextPath %>/css/admin-users.css">
	<% } %>
   
	<% if ("account".equals(activePage)) { %>
	    <link rel="stylesheet"
	          href="<%= contextPath %>/css/admin-account.css">
	<% } %>
	   
</head>

<body>
    <!-- MOBILE SIDEBAR OVERLAY -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- SHARED ADMIN SIDEBAR -->
    <aside class="admin-sidebar" id="adminSidebar">

        <a href="<%= contextPath %>/admin-dashboard"
           class="sidebar-brand">
            <span class="brand-icon">
                <i class="fa-solid fa-book-open-reader"></i>
            </span>
            <span>
                <span class="brand-name">LibraryMS</span>
                <span class="brand-caption">Management Portal</span>
            </span>
        </a>

        <div class="sidebar-section-label">MAIN MENU</div>

        <nav class="sidebar-navigation">

            <a href="<%= contextPath %>/admin-dashboard"
               class="sidebar-link <%= "overview".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Overview</span>
            </a>

            <a href="<%= contextPath %>/admin/pending-users"
               class="sidebar-link <%= "pending-users".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-user-check"></i>
                <span>Pending Users</span>
            </a>

            <a href="<%= contextPath %>/admin/books"
               class="sidebar-link <%= "books".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-book"></i>
                <span>Manage Books</span>
            </a>

            <!-- EXISTING BORROWING RECORDS -->
            <a href="<%= contextPath %>/admin/borrowings"
               class="sidebar-link <%= "borrowings".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-book-reader"></i>
                <span>Borrowings</span>
            </a>

            <!-- NEW SEPARATE BORROW REQUESTS SECTION -->
            <a href="<%= contextPath %>/admin/borrow-requests"
               class="sidebar-link <%= "borrow-requests".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-book-circle-arrow-right"></i>
                <span>Borrow Requests</span>
            </a>

            <!-- NEW SEPARATE RENEWAL REQUESTS SECTION -->
            <a href="<%= contextPath %>/admin/renewal-requests"
               class="sidebar-link <%= "renewal-requests".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-calendar-plus"></i>
                <span>Renewal Requests</span>
            </a>

            <a href="<%= contextPath %>/admin/fines"
               class="sidebar-link <%= "fines".equals(activePage) ? "active" : "" %>">
                <i class="fa-solid fa-wallet"></i>
                <span>Manage Fines</span>
            </a>
            <!-- REGISTERED USERS MANAGEMENT -->
			<a href="<%= contextPath %>/admin/users"
			   class="sidebar-link <%= "users".equals(activePage) ? "active" : "" %>">
			    <i class="fa-solid fa-users"></i>
			    <span>Users</span>
			</a>

        </nav>

        <div class="sidebar-section-label">SYSTEM</div>

        <nav class="sidebar-navigation">
            <a href="<%= contextPath %>/home" class="sidebar-link">
                <i class="fa-solid fa-globe"></i>
                <span>View Website</span>
            </a>
        </nav>

        <div class="sidebar-spacer"></div>

        <div class="sidebar-help">
            <i class="fa-solid fa-circle-info"></i>
            <h4>Library Administration</h4>
            <p>Manage books, user approvals, borrowings, requests and fines from one place.</p>
        </div>

        <div class="sidebar-bottom">
        	<a href="<%= contextPath %>/admin/account"
		       class="sidebar-link <%= "account".equals(activePage) ? "active" : "" %>">
		        <i class="fa-solid fa-circle-user"></i>
		        <span>MyAccount</span>
		    </a>
            <a href="<%= contextPath %>/logout"
               class="sidebar-link logout-link">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Logout</span>
            </a>
        </div>

    </aside>

    <!-- SHARED MAIN PANEL -->
    <main class="admin-main">

        <!-- SHARED TOPBAR -->
        <header class="admin-topbar">
            <div class="topbar-left">
                <button type="button"
                        class="mobile-menu-button"
                        id="mobileMenuButton"
                        aria-label="Toggle navigation"
                        aria-controls="adminSidebar"
                        aria-expanded="false">
                    <i class="fa-solid fa-bars"></i>
                </button>

                <div>
                    <h1 class="topbar-title"><%= pageTitle %></h1>
                    <p class="topbar-subtitle"><%= pageSubtitle %></p>
                </div>
            </div>

            <div class="admin-profile">
                <div class="profile-avatar"><%= adminInitial %></div>
                <div class="profile-details">
                    <p class="profile-name"><%= adminName %></p>
                    <p class="profile-role">Administrator</p>
                </div>
            </div>
        </header>

        <!-- INCLUDE ONLY THE SELECTED PAGE CONTENT -->
        <section class="dashboard-content">
            <% if (adminContent != null && !adminContent.trim().isEmpty()) { %>
                <jsp:include page="<%= adminContent %>" />
            <% } else { %>
                <section class="welcome-section">
                    <div>
                        <h2>Welcome to Library Admin</h2>
                        <p>Select a section from the sidebar to manage your library.</p>
                    </div>
                </section>
            <% } %>
        </section>

    </main>

    <!-- SHARED RESPONSIVE SIDEBAR BEHAVIOR -->
    <script>
        // GET THE SIDEBAR CONTROLS
        const menuButton = document.getElementById("mobileMenuButton");
        const sidebar = document.getElementById("adminSidebar");
        const overlay = document.getElementById("sidebarOverlay");

        // OPEN OR CLOSE THE MOBILE SIDEBAR
        function toggleAdminSidebar() {
            const isOpen = sidebar.classList.toggle("sidebar-open");

            overlay.classList.toggle("overlay-visible", isOpen);
            menuButton.setAttribute("aria-expanded", String(isOpen));

            menuButton.innerHTML = isOpen
                ? '<i class="fa-solid fa-xmark"></i>'
                : '<i class="fa-solid fa-bars"></i>';
        }

        // CLOSE THE MOBILE SIDEBAR
        function closeAdminSidebar() {
            sidebar.classList.remove("sidebar-open");
            overlay.classList.remove("overlay-visible");
            menuButton.setAttribute("aria-expanded", "false");
            menuButton.innerHTML = '<i class="fa-solid fa-bars"></i>';
        }

        menuButton.addEventListener("click", toggleAdminSidebar);
        overlay.addEventListener("click", closeAdminSidebar);

        sidebar.querySelectorAll("a").forEach(function(link) {
            link.addEventListener("click", function() {
                if (window.innerWidth <= 760) {
                    closeAdminSidebar();
                }
            });
        });

        // RESET MOBILE NAVIGATION AFTER RESIZING TO DESKTOP
        window.addEventListener("resize", function() {
            if (window.innerWidth > 760) {
                closeAdminSidebar();
            }
        });
    </script>
</body>
</html>
