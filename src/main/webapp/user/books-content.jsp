
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeSet" %>
<%@ page import="com.tap.model.Book" %>

<%!
    // ESCAPE TEXT BEFORE DISPLAYING IT IN HTML.
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
    List<Book> allBooks =
            (List<Book>) request.getAttribute("allBooks");

    if (allBooks == null) {
        allBooks = new java.util.ArrayList<Book>();
    }

    // COLLECT DISTINCT CATEGORIES FOR THE FILTER.
    Set<String> categories = new TreeSet<String>(
        String.CASE_INSENSITIVE_ORDER
    );

    for (Book book : allBooks) {
        if (book.getCategory() != null
                && !book.getCategory().trim().isEmpty()) {
            categories.add(book.getCategory().trim());
        }
    }
%>


<!-- BORROW REQUEST FEEDBACK -->
<%
    String borrowResult = request.getParameter("borrowResult");
%>

<% if ("requested".equals(borrowResult)) { %>
    <div class="borrow-feedback borrow-feedback-success" role="status">
        <i class="fas fa-circle-check"></i>
        Borrow request submitted successfully. Waiting for admin approval.
    </div>
<% } else if ("unavailable".equals(borrowResult)) { %>
    <div class="borrow-feedback borrow-feedback-error" role="alert">
        <i class="fas fa-circle-exclamation"></i>
        Unable to submit your request. The book may no longer be available.
    </div>
<% } else if ("invalid".equals(borrowResult)) { %>
    <div class="borrow-feedback borrow-feedback-error" role="alert">
        <i class="fas fa-circle-exclamation"></i>
        Invalid book selection. Please try again.
    </div>
<% } %>

<!-- BROWSE BOOKS INTRODUCTION -->
<section class="user-books-page">

    <div class="user-books-intro">
        <div>
            <span class="user-books-eyebrow">
                <i class="fas fa-book-open"></i>
                EXPLORE YOUR LIBRARY
            </span>

            <h2>Find Your Next Great Read</h2>

            <p>
                Discover books across different categories
                and explore the collection at your own pace.
            </p>
        </div>

        <div class="user-books-total">
            <i class="fas fa-books"></i>
            <div>
                <strong><%= allBooks.size() %></strong>
                <span>Book titles</span>
            </div>
        </div>
    </div>

    <!-- SEARCH AND CATEGORY FILTER -->
    <div class="user-books-toolbar">

        <div class="user-books-search">
            <i class="fas fa-search"></i>

            <input
                type="search"
                id="bookSearchInput"
                placeholder="Search by title or author..."
                aria-label="Search books by title or author">
        </div>

        <div class="user-books-category-filter">
            <i class="fas fa-layer-group"></i>

            <select id="bookCategoryFilter"
                    aria-label="Filter books by category">

                <option value="">All Categories</option>

                <% for (String category : categories) { %>
                    <option value="<%= escapeHtml(category) %>">
                        <%= escapeHtml(category) %>
                    </option>
                <% } %>

            </select>
        </div>

    </div>

    <!-- RESULTS SUMMARY -->
    <div class="user-books-results-heading">
        <div>
            <h3>Library Collection</h3>
            <p id="bookResultsCount">
                Showing <%= allBooks.size() %> book(s)
            </p>
        </div>
    </div>

    <!-- BOOK COLLECTION -->
    <% if (allBooks.isEmpty()) { %>

        <div class="user-books-empty">
            <i class="fas fa-book-open"></i>
            <h3>No Books Available</h3>
            <p>Books added to the library will appear here.</p>
        </div>

    <% } else { %>

        <div class="user-recent-books-grid" id="userBooksGrid">

            <% for (Book book : allBooks) {
                String title = book.getTitle() == null
                        ? "" : book.getTitle();

                String author = book.getAuthor() == null
                        ? "" : book.getAuthor();

                String category = book.getCategory() == null
                        ? "" : book.getCategory();

                String image = book.getImage() == null
                        ? "" : book.getImage().trim();
            %>

                <article class="user-book-card"
                         data-title="<%= escapeHtml(title.toLowerCase()) %>"
                         data-author="<%= escapeHtml(author.toLowerCase()) %>"
                         data-category="<%= escapeHtml(category.toLowerCase()) %>">

                    <!-- BOOK COVER -->
                    <div class="user-book-image">

                        <% if (!image.isEmpty()) { %>

                            <img
                                src="<%= escapeHtml(image) %>"
                                alt="<%= escapeHtml(title) %>"
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
                            <%= escapeHtml(category) %>
                        </span>

                        <h3><%= escapeHtml(title) %></h3>

                        <p class="user-book-author">
                            By <%= escapeHtml(author) %>
                        </p>

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

        <!-- SHOWN WHEN SEARCH/FILTER HAS NO MATCHES -->
        <div class="user-books-empty"
             id="userBooksNoResults"
             style="display:none;">

            <i class="fas fa-search"></i>
            <h3>No Matching Books</h3>
            <p>Try another title, author, or category.</p>

        </div>

    <% } %>

</section>

<!-- CLIENT-SIDE SEARCH AND CATEGORY FILTER -->
<script>
document.addEventListener("DOMContentLoaded", function () {

    const searchInput = document.getElementById("bookSearchInput");
    const categoryFilter = document.getElementById("bookCategoryFilter");
    const booksGrid = document.getElementById("userBooksGrid");
    const resultsCount = document.getElementById("bookResultsCount");
    const noResults = document.getElementById("userBooksNoResults");

    if (!searchInput || !categoryFilter || !booksGrid) {
        return;
    }

    const bookCards = Array.from(
        booksGrid.querySelectorAll(".user-book-card")
    );

    function filterBooks() {

        const searchText = searchInput.value.trim().toLowerCase();
        const selectedCategory = categoryFilter.value.trim().toLowerCase();

        let visibleCount = 0;

        bookCards.forEach(function (card) {

            const title = card.dataset.title || "";
            const author = card.dataset.author || "";
            const category = card.dataset.category || "";

            const matchesSearch =
                title.includes(searchText) ||
                author.includes(searchText);

            const matchesCategory =
                selectedCategory === "" ||
                category === selectedCategory;

            const isVisible = matchesSearch && matchesCategory;

            card.style.display = isVisible ? "" : "none";

            if (isVisible) {
                visibleCount++;
            }
        });

        if (resultsCount) {
            resultsCount.textContent =
                "Showing " + visibleCount + " of " +
                bookCards.length + " book(s)";
        }

        if (noResults) {
            noResults.style.display =
                visibleCount === 0 ? "" : "none";
        }
    }

    searchInput.addEventListener("input", filterBooks);
    categoryFilter.addEventListener("change", filterBooks);

});
</script>
