
<%@ page import="com.tap.model.User" language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // RETRIEVE THE LOGGED-IN USER OBJECT FROM THE SESSION
   User loggedInUser =
            (User) session.getAttribute("loggedInUser");

    // ALLOW ONLY AUTHENTICATED ADMIN USERS TO VIEW THIS PAGE
    if (loggedInUser == null
            || !"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // GET ADMIN DETAILS FROM THE USER OBJECT
    String contextPath = request.getContextPath();
    String userName = loggedInUser.getName();
    String userRole = loggedInUser.getRole();

    // GET THE FIRST LETTER FOR THE PROFILE AVATAR
    String adminInitial = (userName == null || userName.trim().isEmpty())
            ? "A"
            : userName.trim().substring(0, 1).toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Admin Dashboard | Library Management System</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <link rel="stylesheet"
          href="<%= contextPath %>/css/admin-dashboard.css">
</head>

<body>

    <!-- MOBILE SIDEBAR OVERLAY -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- ADMIN SIDEBAR -->
    <aside class="admin-sidebar" id="adminSidebar">

        <a href="<%= contextPath %>/admin-dashboard.jsp"
           class="sidebar-brand">

            <span class="brand-icon">
                <i class="fa-solid fa-book-open-reader"></i>
            </span>

            <span>
                <span class="brand-name">LibraryMS</span>
                <span class="brand-caption" style="display: block;">
                    Admin Portal
                </span>
            </span>
        </a>

        <div class="sidebar-section-label">Main Menu</div>

        <nav class="sidebar-navigation">

            <a href="${pageContext.request.contextPath}/admin-dashboard"
               class="sidebar-link active">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Overview</span>
            </a>

            <a href="<%= contextPath %>/admin/pending-users"
               class="sidebar-link">
                <i class="fa-solid fa-user-check"></i>
                <span>User Approvals</span>
            </a>

            <a href="<%= contextPath %>/admin/books"
               class="sidebar-link">
                <i class="fa-solid fa-book"></i>
                <span>Book Management</span>
            </a>

            <a href="<%= contextPath %>/admin/borrowings"
               class="sidebar-link">
                <i class="fa-solid fa-book-open"></i>
                <span>Borrowing Records</span>
            </a>

            <a href="<%= contextPath %>/admin/fines"
               class="sidebar-link">
                <i class="fa-solid fa-indian-rupee-sign"></i>
                <span>Fine Management</span>
            </a>

        </nav>

        <div class="sidebar-section-label">System</div>

        <nav class="sidebar-navigation">

            <a href="<%= contextPath %>/home"
               class="sidebar-link">
                <i class="fa-solid fa-globe"></i>
                <span>View Public Website</span>
            </a>

        </nav>

        <div class="sidebar-spacer"></div>

        <div class="sidebar-help">
            <i class="fa-solid fa-circle-info"></i>
            <h4>Library Administration</h4>
            <p>
                Manage library resources, user accounts,
                borrowings, and fines from this portal.
            </p>
        </div>

        <div class="sidebar-bottom">

            <a href="<%= contextPath %>/logout"
               class="sidebar-link logout-link">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Logout</span>
            </a>

        </div>

    </aside>

    <!-- MAIN DASHBOARD -->
    <main class="admin-main">

        <!-- TOP BAR -->
        <header class="admin-topbar">

            <div class="topbar-left">

                <button type="button"
                        class="mobile-menu-button"
                        id="mobileMenuButton"
                        aria-label="Open navigation menu"
                        aria-controls="adminSidebar"
                        aria-expanded="false">
                    <i class="fa-solid fa-bars"></i>
                </button>

                <div>
                    <div class="topbar-title">Dashboard Overview</div>
                    <div class="topbar-subtitle">
                        Monitor and manage your library
                    </div>
                </div>

            </div>

            <div class="admin-profile">

                <div class="profile-avatar">
                    <%= adminInitial %>
                </div>

                <div class="profile-details">

                    <div class="profile-name">
                        <%= userName == null ? "Administrator" : userName %>
                    </div>

                    <div class="profile-role">Administrator</div>

                </div>

            </div>

        </header>

        <div class="dashboard-content">

            <!-- WELCOME SECTION -->
            <section class="welcome-section">

                <div>
                    <h1>
                        Welcome back,
                        <%= userName == null ? "Administrator" : userName %>
                        👋
                    </h1>

                    <p>
                        Here's what's happening in your library.
                        Manage your resources from one place.
                    </p>
                </div>

                <div class="admin-status">
                    <span class="status-dot"></span>
                    Admin session active
                </div>

            </section>

            <!-- LIBRARY STATISTICS -->
            <section>

                <div class="section-heading">
                    <div>
                        <h2>Library Overview</h2>
                        <p class="section-description">
                            Key metrics across your library
                        </p>
                    </div>
                </div>

                <div class="stats-grid">

                    <article class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Total Books</span>
                            <span class="stat-icon">
                                <i class="fa-solid fa-book"></i>
                            </span>
                        </div>
                        <div class="stat-value">—</div>
                        <div class="stat-note">Catalogue inventory</div>
                    </article>

                    <article class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Available Copies</span>
                            <span class="stat-icon">
                                <i class="fa-solid fa-book-open"></i>
                            </span>
                        </div>
                        <div class="stat-value">—</div>
                        <div class="stat-note">Ready to be borrowed</div>
                    </article>

                    <article class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Pending Registrations</span>
                            <span class="stat-icon">
                                <i class="fa-solid fa-user-clock"></i>
                            </span>
                        </div>
                        <div class="stat-value">—</div>
                        <div class="stat-note">Awaiting admin review</div>
                    </article>

                    <article class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Active Borrowings</span>
                            <span class="stat-icon">
                                <i class="fa-solid fa-book-reader"></i>
                            </span>
                        </div>
                        <div class="stat-value">—</div>
                        <div class="stat-note">Currently borrowed books</div>
                    </article>

                </div>

            </section>

            <!-- QUICK MANAGEMENT LINKS -->
            <section class="management-section">

                <div class="section-heading">
                    <div>
                        <h2>Quick Actions</h2>
                        <p class="section-description">
                            Jump directly to a management section
                        </p>
                    </div>
                </div>

                <div class="management-grid">

                    <a href="<%= contextPath %>/admin/pending-users"
                       class="management-card">

                        <span class="management-icon">
                            <i class="fa-solid fa-user-check"></i>
                        </span>

                        <span class="management-info">
                            <h3>User Approvals</h3>
                            <p>
                                Review new registrations and approve
                                or reject user accounts.
                            </p>
                            <span class="management-action">
                                Review registrations
                                <i class="fa-solid fa-arrow-right"></i>
                            </span>
                        </span>

                    </a>

                    <a href="<%= contextPath %>/admin/books"
                       class="management-card">

                        <span class="management-icon">
                            <i class="fa-solid fa-book"></i>
                        </span>

                        <span class="management-info">
                            <h3>Book Management</h3>
                            <p>
                                Manage catalogue records and book
                                availability.
                            </p>
                            <span class="management-action">
                                Manage books
                                <i class="fa-solid fa-arrow-right"></i>
                            </span>
                        </span>

                    </a>

                    <a href="<%= contextPath %>/admin/borrowings"
                       class="management-card">

                        <span class="management-icon">
                            <i class="fa-solid fa-book-open"></i>
                        </span>

                        <span class="management-info">
                            <h3>Borrowing Records</h3>
                            <p>
                                Review borrowing activity, returns,
                                and overdue books.
                            </p>
                            <span class="management-action">
                                View borrowings
                                <i class="fa-solid fa-arrow-right"></i>
                            </span>
                        </span>

                    </a>

                    <a href="<%= contextPath %>/admin/fines"
                       class="management-card">

                        <span class="management-icon">
                            <i class="fa-solid fa-indian-rupee-sign"></i>
                        </span>

                        <span class="management-info">
                            <h3>Fine Management</h3>
                            <p>
                                Review pending fines and recorded
                                payment statuses.
                            </p>
                            <span class="management-action">
                                Manage fines
                                <i class="fa-solid fa-arrow-right"></i>
                            </span>
                        </span>

                    </a>

                </div>

            </section>

            <!-- DASHBOARD FOOTER -->
            <footer class="dashboard-footer">
                <span>Library Management System</span>
                <span>Administration Portal</span>
            </footer>

        </div>

    </main>

    <!-- RESPONSIVE SIDEBAR BEHAVIOR -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {

            const sidebar = document.getElementById("adminSidebar");
            const menuButton = document.getElementById("mobileMenuButton");
            const overlay = document.getElementById("sidebarOverlay");

            // OPEN OR CLOSE THE MOBILE SIDEBAR
            function toggleSidebar() {

                const isOpen =
                    sidebar.classList.toggle("sidebar-open");

                overlay.classList.toggle("overlay-visible", isOpen);

                menuButton.setAttribute(
                    "aria-expanded",
                    String(isOpen)
                );

                menuButton.innerHTML = isOpen
                    ? '<i class="fa-solid fa-xmark"></i>'
                    : '<i class="fa-solid fa-bars"></i>';
            }

            // CLOSE THE SIDEBAR
            function closeSidebar() {

                sidebar.classList.remove("sidebar-open");
                overlay.classList.remove("overlay-visible");

                menuButton.setAttribute("aria-expanded", "false");

                menuButton.innerHTML =
                    '<i class="fa-solid fa-bars"></i>';
            }

            menuButton.addEventListener("click", toggleSidebar);
            overlay.addEventListener("click", closeSidebar);

            // CLOSE MOBILE SIDEBAR AFTER NAVIGATION
            sidebar.querySelectorAll("a").forEach(function (link) {

                link.addEventListener("click", function () {

                    if (window.innerWidth <= 760) {
                        closeSidebar();
                    }

                });

            });

            // KEEP SIDEBAR STATE CORRECT WHEN RESIZING
            window.addEventListener("resize", function () {

                if (window.innerWidth > 760) {
                    closeSidebar();
                }

            });

        });
    </script>

</body>
</html>