
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Book" %>
<%@ page import="java.math.BigDecimal" %>

<%!
    // ESCAPE HTML TO PREVENT USER-CONTROLLED TEXT FROM BEING RENDERED AS HTML.
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

    // FORMAT THE BOOK IMAGE PATH FOR SAFE HTML OUTPUT.
    private String escapeAttribute(String value) {
        return escapeHtml(value);
    }
%>

<%
    List<Book> recentBooks =
            (List<Book>) request.getAttribute("recentBooks");

    Integer totalBooksValue =
            (Integer) request.getAttribute("totalBooks");

    Integer availableBooksValue =
            (Integer) request.getAttribute("availableBooks");

    Integer activeBorrowingCountValue =
            (Integer) request.getAttribute("activeBorrowingCount");

    Integer pendingFineCountValue =
            (Integer) request.getAttribute("pendingFineCount");

    BigDecimal pendingFineTotal =
            (BigDecimal) request.getAttribute("pendingFineTotal");

    int totalBooks = totalBooksValue == null ? 0 : totalBooksValue;
    int availableBooks = availableBooksValue == null ? 0 : availableBooksValue;
    int activeBorrowingCount =
            activeBorrowingCountValue == null ? 0 : activeBorrowingCountValue;
    int pendingFineCount =
            pendingFineCountValue == null ? 0 : pendingFineCountValue;

    if (pendingFineTotal == null) {
        pendingFineTotal = BigDecimal.ZERO;
    }
%>

<!-- WELCOME BANNER -->
<section class="user-welcome-banner">
    <div class="user-welcome-content">
        <span class="user-welcome-label">
            <i class="fas fa-sparkles"></i> YOUR PERSONAL LIBRARY
        </span>

        <h2>Discover Your Next Favourite Book</h2>

        <p>
            Explore our collection, keep track of your borrowings,
            and make every reading moment count.
        </p>

        <a href="<%= request.getContextPath() %>/user/books"
           class="user-welcome-button">
            <i class="fas fa-book-open"></i>
            Browse Books
        </a>
    </div>

    <div class="user-welcome-decoration">
        <i class="fas fa-book-open"></i>
    </div>
</section>

<!-- DASHBOARD STATISTICS -->
<section class="user-stats-grid">

    <article class="user-stat-card">
        <div class="user-stat-icon books-icon">
            <i class="fas fa-book"></i>
        </div>

        <div class="user-stat-details">
            <p>Total Books</p>
            <h3><%= totalBooks %></h3>
            <span>Books in the collection</span>
        </div>
    </article>

    <article class="user-stat-card">
        <div class="user-stat-icon available-icon">
            <i class="fas fa-book-open"></i>
        </div>

        <div class="user-stat-details">
            <p>Available Copies</p>
            <h3><%= availableBooks %></h3>
            <span>Copies available to borrow</span>
        </div>
    </article>

    <article class="user-stat-card">
        <div class="user-stat-icon borrowing-icon">
            <i class="fas fa-book-reader"></i>
        </div>

        <div class="user-stat-details">
            <p>My Borrowings</p>
            <h3><%= activeBorrowingCount %></h3>
            <span>Currently borrowed books</span>
        </div>
    </article>

    <article class="user-stat-card">
        <div class="user-stat-icon fines-icon">
            <i class="fas fa-wallet"></i>
        </div>

        <div class="user-stat-details">
            <p>Pending Fine</p>
            <h3>₹<%= pendingFineTotal.toPlainString() %></h3>
            <span><%= pendingFineCount %> pending fine record(s)</span>
        </div>
    </article>

</section>

<!-- RECENTLY ADDED BOOKS -->

<!-- RECENTLY ADDED BOOKS -->
<section class="user-recent-books">

    <div class="user-section-heading">
        <div>
            <h2>Recently Added Books</h2>
            <p>Discover the latest additions to our collection.</p>
        </div>

        <a href="<%= request.getContextPath() %>/user/books"
           class="user-view-all-link">
            View All <i class="fas fa-arrow-right"></i>
        </a>
    </div>

    <% if (recentBooks == null || recentBooks.isEmpty()) { %>

        <div class="user-books-empty">
            <i class="fas fa-book-open"></i>
            <h3>No Books Available</h3>
            <p>New books will appear here when they are added.</p>
        </div>

    <% } else { %>

        <div class="user-recent-books-grid">

            <% for (Book book : recentBooks) { %>

                <article class="user-book-card">

                    <!-- BOOK COVER -->
                    <div class="user-book-image">

                        <% if (book.getImage() != null
                                && !book.getImage().trim().isEmpty()) { %>

                            <img
                                src="<%= escapeAttribute(book.getImage()) %>"
                                alt="<%= escapeAttribute(book.getTitle()) %>"
                                loading="lazy"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">

                            <div class="user-book-image-fallback"
                                 style="display:none;">
                                <i class="fas fa-book"></i>
                            </div>

                        <% } else { %>

                            <div class="user-book-image-fallback">
                                <i class="fas fa-book"></i>
                            </div>

                        <% } %>

                    </div>

                    <!-- BOOK INFORMATION -->
                    <div class="user-book-info">

                        <span class="user-book-category">
                            <%= escapeHtml(book.getCategory()) %>
                        </span>

                        <h3><%= escapeHtml(book.getTitle()) %></h3>

                        <p class="user-book-author">
                            By <%= escapeHtml(book.getAuthor()) %>
                        </p>

                        <!-- AVAILABILITY -->
                        <div class="user-book-availability">

                            <% if (book.getAvailableCopies() > 0) { %>

                                <span class="available-status">
                                    <i class="fas fa-circle-check"></i>
                                    Available
                                </span>

                            <% } else { %>

                                <span class="unavailable-status">
                                    <i class="fas fa-circle-xmark"></i>
                                    Currently unavailable
                                </span>

                            <% } %>

                        </div>

                        <!-- BOOK ACTIONS -->
                        <div class="user-book-actions">

                            <a
                                href="<%= request.getContextPath() %>/book-details?bookId=<%= book.getBookId() %>"
                                class="user-book-details-link">
                                View Details
                                <i class="fas fa-arrow-right"></i>
                            </a>

                            <% if (book.getAvailableCopies() > 0) { %>

                                <form
                                    action="<%= request.getContextPath() %>/borrow-book"
                                    method="post"
                                    class="user-borrow-form">

                                    <input
                                        type="hidden"
                                        name="bookId"
                                        value="<%= book.getBookId() %>">

                                    <button
                                        type="submit"
                                        class="user-borrow-button">
                                        <i class="fas fa-book-reader"></i>
                                        Borrow Book
                                    </button>

                                </form>

                            <% } else { %>

                                <button
                                    type="button"
                                    class="user-borrow-button user-borrow-disabled"
                                    disabled>
                                    <i class="fas fa-ban"></i>
                                    Unavailable
                                </button>

                            <% } %>

                        </div>

                    </div>

                </article>

            <% } %>

        </div>

    <% } %>

</section>
