
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Book" %>

<%!
    // UPDATED: USE AN INTERNET URL FOR THE DEFAULT BOOK COVER
    private String getBookImage(String image) {
        if (image == null || image.trim().isEmpty()) {
            return "https://placehold.net/400x600.png?text=Book+Cover";
        }
        return image.trim();
    }

    // ADDED: ESCAPE TEXT BEFORE PLACING IT INSIDE HTML ATTRIBUTES
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("'", "&#39;");
    }
%>

<%
    // ADDED: READ BOOKS AND STATISTICS FROM BOOKCONTROLLER
    List<Book> featuredBooks =
        (List<Book>) request.getAttribute("featuredBooks");

    Integer totalBooksValue =
        (Integer) request.getAttribute("totalBooks");

    Integer availableCopiesValue =
        (Integer) request.getAttribute("availableCopies");

    int totalBooks = totalBooksValue != null ? totalBooksValue : 0;
    int availableCopies =
        availableCopiesValue != null ? availableCopiesValue : 0;

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>LibrarySpace | Discover Your Next Chapter</title>

    <!-- ADDED: CONNECT THE LANDING PAGE STYLESHEET -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">

    <!-- ADDED: LOAD FONT AWESOME ICONS -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
          
    
</head>

<body data-context-path="<%= contextPath %>">

    <!-- ADDED: NAVIGATION COMPONENT -->
    <jsp:include page="/components/navbar.jsp" />

    <main>

        <!-- ADDED: HERO SECTION -->
        <section class="hero-section" id="home">
            <div class="hero-overlay"></div>

            <div class="hero-content">
                <span class="hero-tag">
                    <i class="fa-solid fa-book-open"></i>
                    YOUR JOURNEY INTO KNOWLEDGE
                </span>

                <h1>
                    Your Next Chapter
                    <span>Starts Here.</span>
                </h1>

                <p>
                    Discover inspiring stories, explore new ideas, and
                    find your next favourite book in our digital library.
                </p>

                <div class="hero-actions">
                    <a href="#featured-books" class="btn btn-primary">
                        Explore Books
                        <i class="fa-solid fa-arrow-right"></i>
                    </a>

                    <a href="<%= contextPath %>/register.jsp"
                       class="btn btn-glass">
                        <i class="fa-solid fa-user-plus"></i>
                        Join the Library
                    </a>
                </div>

                <div class="hero-note">
                    <i class="fa-solid fa-bookmark"></i>
                    A world of knowledge, one book at a time
                </div>
            </div>

            <a href="#featured-books" class="scroll-indicator"
               aria-label="Scroll to featured books">
                <i class="fa-solid fa-chevron-down"></i>
            </a>
        </section>


        <!-- ADDED: REAL LIBRARY STATISTICS -->
        <section class="stats-section" aria-label="Library statistics">
            <div class="stats-grid">

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-book"></i>
                    </div>
                    <div>
                        <h2><%= totalBooks %></h2>
                        <p>Total Book Copies</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-book-open-reader"></i>
                    </div>
                    <div>
                        <h2><%= availableCopies %></h2>
                        <p>Available Copies</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </div>
                    <div>
                        <h2>Discover</h2>
                        <p>Books for Every Interest</p>
                    </div>
                </div>

            </div>
        </section>


        <!-- ADDED: FEATURED BOOKS SECTION -->
        <section class="featured-section section-padding"
                 id="featured-books">

            <div class="section-heading">
                <span class="section-eyebrow">HANDPICKED FOR YOU</span>
                <h2>Explore Our <span>Collection</span></h2>
                <p>
                    Find a new perspective, learn something new,
                    or simply enjoy a great story.
                </p>
            </div>

            <!-- ADDED: SEARCH BOOKS BY TITLE OR CATEGORY -->
            <div class="book-search">
                <i class="fa-solid fa-magnifying-glass"></i>

                <input type="search"
                       id="bookSearch"
                       placeholder="Search by book title or category..."
                       aria-label="Search books by title or category">

                <button type="button" id="clearSearch"
                        aria-label="Clear search">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="book-grid" id="bookGrid">

                <% if (featuredBooks != null && !featuredBooks.isEmpty()) { %>

                    <% for (Book book : featuredBooks) { %>

                        <article class="book-card"
                                 data-title="<%= escapeHtml(book.getTitle()) %>"
                                 data-category="<%= escapeHtml(book.getCategory()) %>">

                            <a class="book-cover-link"
                               href="<%= contextPath %>/book-details?bookId=<%= book.getBookId() %>">

                                <div class="book-cover">
                                    <!-- UPDATED: SUPPORT INTERNET IMAGE URLS AND FALLBACK COVER -->
                                    <img
                                        src="<%= escapeHtml(getBookImage(book.getImage())) %>"
                                        alt="Cover of <%= escapeHtml(book.getTitle()) %>"
                                        loading="lazy"
                                        onerror="this.onerror=null;this.src='https://placehold.net/400x600.png?text=Book+Cover';">

                                    <span class="book-category">
                                        <%= escapeHtml(book.getCategory() != null
                                            ? book.getCategory()
                                            : "General") %>
                                    </span>
                                </div>
                            </a>

                            <div class="book-info">
                                <h3>
                                    <%= escapeHtml(book.getTitle() != null
                                        ? book.getTitle()
                                        : "Untitled Book") %>
                                </h3>

                                <p class="book-author">
                                    <i class="fa-regular fa-user"></i>
                                    <%= escapeHtml(book.getAuthor() != null
                                        ? book.getAuthor()
                                        : "Unknown Author") %>
                                </p>

                                <div class="book-availability">
                                    <% if (book.getAvailableCopies() > 0) { %>
                                        <span class="availability available">
                                            <i class="fa-solid fa-circle-check"></i>
                                            <%= book.getAvailableCopies() %>
                                            available
                                        </span>
                                    <% } else { %>
                                        <span class="availability unavailable">
                                            <i class="fa-solid fa-circle-xmark"></i>
                                            Currently unavailable
                                        </span>
                                    <% } %>
                                </div>

                                <a class="book-details-link"
                                   href="<%= contextPath %>/book-details?bookId=<%= book.getBookId() %>">
                                    View Details
                                    <i class="fa-solid fa-arrow-right"></i>
                                </a>
                            </div>

                        </article>

                    <% } %>

                <% } else { %>

                    <div class="empty-books">
                        <i class="fa-solid fa-book-open"></i>
                        <h3>No Books to Display Yet</h3>
                        <p>
                            Books will appear here once they are available
                            in the library collection.
                        </p>
                    </div>

                <% } %>

            </div>

            <!-- ADDED: MESSAGE SHOWN WHEN SEARCH HAS NO MATCHES -->
            <p class="no-search-results" id="noSearchResults" hidden>
                No featured books match your search.
            </p>

        </section>


        <!-- ADDED: LIBRARY FEATURES SECTION -->
        <section class="features-section section-padding" id="features">

            <div class="section-heading">
                <span class="section-eyebrow">A BETTER READING EXPERIENCE</span>
                <h2>Everything You Need, <span>In One Place</span></h2>
                <p>
                    Manage your reading journey through a simple,
                    organized library experience.
                </p>
            </div>

            <div class="features-grid">

                <article class="feature-card">
                    <div class="feature-icon">
                        <i class="fa-solid fa-compass"></i>
                    </div>
                    <h3>Discover Books</h3>
                    <p>
                        Explore books by title and category to find
                        something that matches your interests.
                    </p>
                </article>

                <article class="feature-card">
                    <div class="feature-icon">
                        <i class="fa-solid fa-book-open-reader"></i>
                    </div>
                    <h3>Manage Borrowing</h3>
                    <p>
                        Track your borrowed books, due dates,
                        returns, and eligible renewals.
                    </p>
                </article>

                <article class="feature-card">
                    <div class="feature-icon">
                        <i class="fa-solid fa-calendar-check"></i>
                    </div>
                    <h3>Track Due Dates</h3>
                    <p>
                        Keep track of your borrowing period and
                        stay informed about overdue books and fines.
                    </p>
                </article>

                <article class="feature-card">
                    <div class="feature-icon">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <h3>Approved Access</h3>
                    <p>
                        Account approval helps the library manage
                        access for registered members.
                    </p>
                </article>

            </div>
        </section>


        <!-- ADDED: HOW IT WORKS SECTION -->
        <section class="how-it-works section-padding" id="how-it-works">

            <div class="section-heading">
                <span class="section-eyebrow">GETTING STARTED</span>
                <h2>Your Library Journey <span>Begins Here</span></h2>
            </div>

            <div class="steps-grid">

                <div class="step-card">
                    <span class="step-number">01</span>
                    <h3>Create an Account</h3>
                    <p>Register with your details to request library access.</p>
                </div>

                <div class="step-card">
                    <span class="step-number">02</span>
                    <h3>Await Approval</h3>
                    <p>An administrator reviews your registration request.</p>
                </div>

                <div class="step-card">
                    <span class="step-number">03</span>
                    <h3>Explore the Library</h3>
                    <p>After approval, log in to access member features.</p>
                </div>

            </div>
        </section>


        <!-- ADDED: FINAL CALL TO ACTION -->
        <section class="cta-section">
            <div class="cta-content">
                <span class="section-eyebrow">YOUR NEXT GREAT READ AWAITS</span>
                <h2>Ready to Turn the Page?</h2>
                <p>
                    Begin your reading journey and discover
                    the possibilities waiting on every shelf.
                </p>

                <a href="<%= contextPath %>/register.jsp"
                   class="btn btn-primary">
                    Join the Library
                    <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>
        </section>

    </main>

    <!-- ADDED: FOOTER COMPONENT -->
    <jsp:include page="/components/footer.jsp" />

    <!-- ADDED: CONNECT THE LANDING PAGE JAVASCRIPT -->
    <script src="<%= contextPath %>/js/landing.js"></script>

</body>
</html>
