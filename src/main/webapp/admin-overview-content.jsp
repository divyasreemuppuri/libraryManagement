
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<!-- WELCOME SECTION -->
<section class="welcome-section">
    <div>
        <h2>
            Welcome back,
            <%= ((com.tap.model.User) session.getAttribute("loggedInUser")).getName() %>
            👋
        </h2>
        <p>Here's what's happening in your library. Manage your resources from one place.</p>
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
            <p class="section-description">Key metrics across your library</p>
        </div>
    </div>

    <div class="stats-grid">

        <!-- TOTAL BOOK COPIES -->
        <article class="stat-card">
            <div class="stat-top">
                <span class="stat-label">Total Books</span>
                <span class="stat-icon">
                    <i class="fa-solid fa-book"></i>
                </span>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("totalBooks") != null
                        ? request.getAttribute("totalBooks") : 0 %>
            </div>
            <div class="stat-note">Total copies in the catalogue</div>
        </article>

        <!-- AVAILABLE BOOK COPIES -->
        <article class="stat-card">
            <div class="stat-top">
                <span class="stat-label">Available Copies</span>
                <span class="stat-icon">
                    <i class="fa-solid fa-book-open"></i>
                </span>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("availableCopies") != null
                        ? request.getAttribute("availableCopies") : 0 %>
            </div>
            <div class="stat-note">Ready to be borrowed</div>
        </article>

        <!-- PENDING REGISTRATIONS -->
        <article class="stat-card">
            <div class="stat-top">
                <span class="stat-label">Pending Registrations</span>
                <span class="stat-icon">
                    <i class="fa-solid fa-user-clock"></i>
                </span>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("pendingRegistrations") != null
                        ? request.getAttribute("pendingRegistrations") : 0 %>
            </div>
            <div class="stat-note">Awaiting admin review</div>
        </article>

        <!-- ACTIVE BORROWINGS -->
        <article class="stat-card">
            <div class="stat-top">
                <span class="stat-label">Active Borrowings</span>
                <span class="stat-icon">
                    <i class="fa-solid fa-book-reader"></i>
                </span>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("activeBorrowings") != null
                        ? request.getAttribute("activeBorrowings") : 0 %>
            </div>
            <div class="stat-note">Currently borrowed books, including overdue</div>
        </article>

    </div>
</section>

<!-- QUICK MANAGEMENT LINKS -->
<section class="management-section">
    <div class="section-heading">
        <div>
            <h2>Quick Actions</h2>
            <p class="section-description">Jump directly to a management section</p>
        </div>
    </div>

    <div class="management-grid">

        <!-- USER APPROVALS -->
        <a href="<%= request.getContextPath() %>/admin/pending-users"
           class="management-card">
            <span class="management-icon">
                <i class="fa-solid fa-user-check"></i>
            </span>
            <span class="management-info">
                <h3>User Approvals</h3>
                <p>Review new registrations and approve or reject user accounts.</p>
                <span class="management-action">
                    Review registrations
                    <i class="fa-solid fa-arrow-right"></i>
                </span>
            </span>
        </a>

        <!-- BOOK MANAGEMENT -->
        <a href="<%= request.getContextPath() %>/admin/books"
           class="management-card">
            <span class="management-icon">
                <i class="fa-solid fa-book"></i>
            </span>
            <span class="management-info">
                <h3>Book Management</h3>
                <p>Manage catalogue records and book availability.</p>
                <span class="management-action">
                    Manage books
                    <i class="fa-solid fa-arrow-right"></i>
                </span>
            </span>
        </a>

        <!-- BORROWING RECORDS -->
        <a href="<%= request.getContextPath() %>/admin/borrowings"
           class="management-card">
            <span class="management-icon">
                <i class="fa-solid fa-book-open"></i>
            </span>
            <span class="management-info">
                <h3>Borrowing Records</h3>
                <p>Review borrowing activity, returns and overdue books.</p>
                <span class="management-action">
                    View borrowings
                    <i class="fa-solid fa-arrow-right"></i>
                </span>
            </span>
        </a>

        <!-- BORROW REQUESTS -->
        <a href="<%= request.getContextPath() %>/admin/borrow-requests"
           class="management-card">
            <span class="management-icon">
                <i class="fa-solid fa-book-open-reader"></i>
            </span>
            <span class="management-info">
                <h3>Borrow Requests</h3>
                <p>Review and approve or reject requests to borrow books.</p>
                <span class="management-action">
                    Pending requests:
                    <%= request.getAttribute("pendingBorrowRequests") != null
                            ? request.getAttribute("pendingBorrowRequests") : 0 %>
                    <i class="fa-solid fa-arrow-right"></i>
                </span>
            </span>
        </a>

        <!-- RENEWAL REQUESTS -->
        <a href="<%= request.getContextPath() %>/admin/renewal-requests"
           class="management-card">
            <span class="management-icon">
                <i class="fa-solid fa-calendar-plus"></i>
            </span>
            <span class="management-info">
                <h3>Renewal Requests</h3>
                <p>Review requests to extend book borrowing periods.</p>
                <span class="management-action">
                    Pending requests:
                    <%= request.getAttribute("pendingRenewalRequests") != null
                            ? request.getAttribute("pendingRenewalRequests") : 0 %>
                    <i class="fa-solid fa-arrow-right"></i>
                </span>
            </span>
        </a>

        <!-- FINE MANAGEMENT -->
        <a href="<%= request.getContextPath() %>/admin/fines"
           class="management-card">
            <span class="management-icon">
                <i class="fa-solid fa-indian-rupee-sign"></i>
            </span>
            <span class="management-info">
                <h3>Fine Management</h3>
                <p>Review pending fines and recorded payment statuses.</p>
                <span class="management-action">
                    Manage fines
                    <i class="fa-solid fa-arrow-right"></i>
                </span>
            </span>
        </a>

    </div>
</section>

<!-- OVERVIEW FOOTER -->
<footer class="dashboard-footer">
    <span>Library Management System</span>
    <span>Administration Portal</span>
</footer>
