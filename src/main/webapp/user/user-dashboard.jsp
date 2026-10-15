
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Book" %>
<%@ page import="java.util.List" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%!
    // ESCAPE HTML CHARACTERS BEFORE DISPLAYING USER DATA
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
    // GET THE LOGGED-IN USER FROM THE SESSION
    User loggedInUser = (User) session.getAttribute("loggedInUser");

    // PROTECT THE USER DASHBOARD
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // PREVENT ADMINS AND OTHER ROLES FROM ACCESSING THE USER DASHBOARD
    if (!"USER".equalsIgnoreCase(loggedInUser.getRole())) {
        if ("ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect(
                request.getContextPath() + "/admin-dashboard");
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
        return;
    }

    // PREPARE PERSONALIZED USER DETAILS
    String userName = loggedInUser.getName() == null
            ? "Reader"
            : loggedInUser.getName();

    String trimmedName = userName.trim();

    String userInitial = trimmedName.isEmpty()
            ? "R"
            : trimmedName.substring(0, 1).toUpperCase();

    String contextPath = request.getContextPath();

    // GET DASHBOARD DATA FROM THE CONTROLLER
    Object totalBooksValue = request.getAttribute("totalBooks");
    Object availableBooksValue = request.getAttribute("availableBooks");
    Object activeBorrowingCountValue =
            request.getAttribute("activeBorrowingCount");
    Object pendingFineTotalValue =
            request.getAttribute("pendingFineTotal");
    Object pendingFineCountValue =
            request.getAttribute("pendingFineCount");

    int totalBooks = totalBooksValue instanceof Number
            ? ((Number) totalBooksValue).intValue() : 0;

    int availableBooks = availableBooksValue instanceof Number
            ? ((Number) availableBooksValue).intValue() : 0;

    int activeBorrowingCount =
            activeBorrowingCountValue instanceof Number
            ? ((Number) activeBorrowingCountValue).intValue() : 0;

    String pendingFineTotal = pendingFineTotalValue == null
            ? "0.00"
            : pendingFineTotalValue.toString();

    int pendingFineCount = pendingFineCountValue instanceof Number
            ? ((Number) pendingFineCountValue).intValue() : 0;

    List<Book> recentBooks =
            (List<Book>) request.getAttribute("recentBooks");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Dashboard | LibraryHub</title>

    <!-- LOAD FONT AWESOME ICONS -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <!-- LOAD SHARED USER DASHBOARD STYLES -->
    <link rel="stylesheet"
          href="<%= contextPath %>/css/user-dashboard.css">
</head>

<body>

    <!-- MOBILE SIDEBAR OVERLAY -->
    <div class="user-sidebar-overlay"
         id="userSidebarOverlay"></div>

    <!-- PERSISTENT USER SIDEBAR -->
    <aside class="user-sidebar" id="userSidebar">

        <a href="<%= contextPath %>/user-dashboard"
           class="user-brand">

            <span class="user-brand-icon">
                <i class="fas fa-book-open"></i>
            </span>

            <span class="user-brand-text">
                <strong>LibraryHub</strong>
                <small>YOUR PERSONAL LIBRARY</small>
            </span>
        </a>

        <div class="user-sidebar-label">MAIN MENU</div>

        <!-- ALL USER PAGES WILL USE THIS SAME SIDEBAR -->
        <nav class="user-navigation">

            <a href="<%= contextPath %>/user-dashboard"
               class="user-nav-link active">
                <i class="fas fa-house"></i>
                <span>Dashboard</span>
            </a>

            <a href="<%= contextPath %>/user/books"
               class="user-nav-link">
                <i class="fas fa-book"></i>
                <span>Browse Books</span>
            </a>

            <a href="<%= contextPath %>/user/borrowings"
               class="user-nav-link">
                <i class="fas fa-book-reader"></i>
                <span>My Borrowings</span>
            </a>

            <a href="<%= contextPath %>/user/fines"
               class="user-nav-link">
                <i class="fas fa-receipt"></i>
                <span>My Fines</span>
            </a>

            <a href="<%= contextPath %>/user/account"
               class="user-nav-link">
                <i class="fas fa-user-circle"></i>
                <span>My Account</span>
            </a>

        </nav>

        <div class="user-sidebar-spacer"></div>

        <div class="user-sidebar-help">
            <div class="user-help-icon">
                <i class="fas fa-circle-question"></i>
            </div>

            <strong>Need assistance?</strong>
            <p>Contact your library administrator for help.</p>
        </div>

        <div class="user-sidebar-bottom">

            <a href="<%= contextPath %>/home"
               class="user-nav-link">
                <i class="fas fa-arrow-left"></i>
                <span>Public Library</span>
            </a>

            <a href="<%= contextPath %>/logout"
               class="user-nav-link user-logout-link">
                <i class="fas fa-right-from-bracket"></i>
                <span>Logout</span>
            </a>

        </div>

    </aside>

    <!-- RIGHT-SIDE CONTENT AREA -->
    <main class="user-main">

        <!-- SHARED TOP BAR -->
        <header class="user-topbar">

            <div class="user-topbar-left">

                <button type="button"
                        class="user-mobile-menu-button"
                        id="userMobileMenuButton"
                        aria-label="Open navigation menu"
                        aria-controls="userSidebar"
                        aria-expanded="false">
                    <i class="fas fa-bars"></i>
                </button>

                <div>
                    <h1>My Dashboard</h1>
                    <p>Your personal library at a glance</p>
                </div>

            </div>

            <div class="user-profile">

                <div class="user-profile-avatar">
                    <%= escapeHtml(userInitial) %>
                </div>

                <div class="user-profile-details">
                    <strong><%= escapeHtml(userName) %></strong>
                    <span>Library Member</span>
                </div>

            </div>

        </header>

        <!-- DASHBOARD PAGE CONTENT -->
        <section class="user-dashboard-content">

            <!-- WELCOME BANNER -->
            <div class="user-welcome-section">

                <div>
                    <span class="user-welcome-eyebrow">
                        YOUR READING SPACE
                    </span>

                    <h2>
                        Welcome back, <%= escapeHtml(userName) %>!
                    </h2>

                    <p>
                        Discover your next favorite book and keep track
                        of your library activity in one place.
                    </p>
                </div>

                <div class="user-welcome-icon">
                    <i class="fas fa-book-open-reader"></i>
                </div>

            </div>

            <!-- DASHBOARD STATISTICS -->
            <div class="user-stats-grid">

                <div class="user-stat-card">
                    <div class="user-stat-icon books-icon">
                        <i class="fas fa-book"></i>
                    </div>

                    <div class="user-stat-details">
                        <span>Total Book Titles</span>
                        <h3><%= totalBooks %></h3>
                        <p>Titles in the catalog</p>
                    </div>
                </div>

                <div class="user-stat-card">
                    <div class="user-stat-icon available-icon">
                        <i class="fas fa-book-open"></i>
                    </div>

                    <div class="user-stat-details">
                        <span>Available Copies</span>
                        <h3><%= availableBooks %></h3>
                        <p>Copies available to borrow</p>
                    </div>
                </div>

                <div class="user-stat-card">
                    <div class="user-stat-icon borrowing-icon">
                        <i class="fas fa-book-reader"></i>
                    </div>

                    <div class="user-stat-details">
                        <span>My Borrowings</span>
                        <h3><%= activeBorrowingCount %></h3>
                        <p>Active borrowing records</p>
                    </div>
                </div>

                <div class="user-stat-card">
                    <div class="user-stat-icon fines-icon">
                        <i class="fas fa-receipt"></i>
                    </div>

                    <div class="user-stat-details">
                        <span>Pending Fines</span>
                        <h3>&#8377;<%= escapeHtml(pendingFineTotal) %></h3>
                        <p><%= pendingFineCount %> pending record(s)</p>
                    </div>
                </div>

            </div>

            <!-- RECENTLY ADDED BOOKS -->
            <section class="user-recent-books">

                <div class="user-section-heading">
                    <div>
                        <span class="user-section-eyebrow">
                            EXPLORE THE COLLECTION
                        </span>

                        <h3>Recently Added Books</h3>

                        <p>
                            Discover books recently added to your library.
                        </p>
                    </div>

                    <a href="<%= contextPath %>/user/books"
                       class="user-view-all-link">
                        Browse All Books
                        <i class="fas fa-arrow-right"></i>
                    </a>
                </div>

                <div class="user-recent-books-grid">

                    <%
                        if (recentBooks != null && !recentBooks.isEmpty()) {
                            for (Book book : recentBooks) {
                    %>

                        <article class="user-book-card">

                            <div class="user-book-image">

                                <%
                                    String imagePath = book.getImage();

                                    if (imagePath != null
                                            && !imagePath.trim().isEmpty()) {
                                %>

                                    <img
                                        src="<%= escapeHtml(imagePath) %>"
                                        alt="<%= escapeHtml(book.getTitle()) %>"
                                        loading="lazy"
                                        onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">

                                    <div class="user-book-image-fallback"
                                         style="display:none;">
                                        <i class="fas fa-book-open"></i>
                                    </div>

                                <%
                                    } else {
                                %>

                                    <div class="user-book-image-fallback">
                                        <i class="fas fa-book-open"></i>
                                    </div>

                                <%
                                    }
                                %>

                            </div>

                            <div class="user-book-info">

                                <span class="user-book-category">
                                    <%= book.getCategory() == null
                                            ? "General"
                                            : escapeHtml(book.getCategory()) %>
                                </span>

                                <h4>
                                    <%= book.getTitle() == null
                                            ? "Untitled Book"
                                            : escapeHtml(book.getTitle()) %>
                                </h4>

                                <p class="user-book-author">
                                    By <%= book.getAuthor() == null
                                            ? "Unknown Author"
                                            : escapeHtml(book.getAuthor()) %>
                                </p>

                                <div class="user-book-availability">
                                    <span class="user-availability-dot"></span>
                                    <%= book.getAvailableCopies() %> available
                                </div>

                            </div>

                        </article>

                    <%
                            }
                        } else {
                    %>

                        <div class="user-books-empty">
                            <i class="fas fa-book-open"></i>
                            <h4>No books available yet</h4>
                            <p>
                                Books will appear here when they are
                                added to the catalog.
                            </p>
                        </div>

                    <%
                        }
                    %>

                </div>

            </section>

            <!-- SHARED PAGE FOOTER -->
            <footer class="user-dashboard-footer">
                <span>LibraryHub</span>
                <span>Read. Discover. Grow.</span>
            </footer>

        </section>

    </main>

    <!-- LOAD MOBILE SIDEBAR BEHAVIOR -->
    <script src="<%= contextPath %>/js/user-dashboard.js"></script>

</body>
</html>
