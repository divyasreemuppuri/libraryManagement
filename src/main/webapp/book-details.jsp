
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="com.tap.model.Book" %>
<%@ page import="com.tap.model.User" %>

<%!
    // ESCAPE HTML TO DISPLAY BOOK DATA SAFELY
    public String escapeBookHtml(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    // GET THE BOOK AND APPLICATION CONTEXT
    Book book = (Book) request.getAttribute("book");
    String contextPath = request.getContextPath();

    // CHECK WHETHER AN APPROVED NORMAL USER IS LOGGED IN
    User loggedInUser =
            (User) session.getAttribute("loggedInUser");

    boolean isLoggedInUser =
            loggedInUser != null
            && "USER".equalsIgnoreCase(loggedInUser.getRole())
            && "APPROVED".equalsIgnoreCase(loggedInUser.getStatus());

    // SELECT THE CORRECT BOOKS PAGE
    String booksBackUrl = isLoggedInUser
            ? contextPath + "/user/books"
            : contextPath + "/home#featured-books";

    // CHECK WHETHER THE BOOK CAN BE BORROWED
    boolean isBookAvailable = book.getAvailableCopies() > 0;

    // PROVIDE A FALLBACK BOOK COVER
    String bookImage = book.getImage();

    if (bookImage == null || bookImage.trim().isEmpty()) {
        bookImage = "https://placehold.co/400x600/121d31/c4a7ff?text=Book+Cover";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title><%= escapeBookHtml(book.getTitle()) %> | LibrarySpace</title>

    <!-- LOAD ICONS AND PAGE FONTS -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@500;600;700&display=swap">

    <!-- REUSE THE EXISTING LIBRARY DESIGN -->
    <link rel="stylesheet"
          href="<%= contextPath %>/css/landing.css">

    <!-- BOOK DETAILS PAGE STYLES -->
    <link rel="stylesheet"
          href="<%= contextPath %>/css/book-details.css">
</head>

<body>

    <!-- REUSE THE SHARED NAVBAR -->
    <jsp:include page="/components/navbar.jsp" />

    <main class="book-details-page">

        <!-- RETURN TO THE CORRECT BOOKS PAGE -->
        <a href="<%= booksBackUrl %>" class="details-back">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Books
        </a>

        <section class="details-card">

            <!-- BOOK COVER -->
            <div class="details-cover">
                <img
                    src="<%= escapeBookHtml(bookImage) %>"
                    alt="Cover of <%= escapeBookHtml(book.getTitle()) %>"
                    onerror="this.onerror=null;this.src='https://placehold.co/400x600/121d31/c4a7ff?text=Book+Cover';">
            </div>

            <!-- BOOK INFORMATION -->
            <div class="details-info">

                <span class="details-category">
                    <%= escapeBookHtml(book.getCategory()) %>
                </span>

                <h1><%= escapeBookHtml(book.getTitle()) %></h1>

                <p class="details-author">
                    <i class="fa-solid fa-user-pen"></i>
                    <%= escapeBookHtml(book.getAuthor()) %>
                </p>

                <p class="details-description">
                    <%
                        String description = book.getDescription();

                        if (description == null || description.trim().isEmpty()) {
                            description = "No description is available for this book yet.";
                        }
                    %>
                    <%= escapeBookHtml(description) %>
                </p>

                <div class="details-meta">

                    <div class="meta-item">
                        <span>Publisher</span>
                        <strong><%= escapeBookHtml(book.getPublisher()) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Published Year</span>
                        <strong><%= book.getPublishedYear() %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Total Copies</span>
                        <strong><%= book.getTotalCopies() %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Available Copies</span>
                        <strong><%= book.getAvailableCopies() %></strong>
                    </div>

                </div>

                <!-- DISPLAY BOOK AVAILABILITY -->
                <% if (isBookAvailable) { %>

                    <p class="details-availability available">
                        <i class="fa-solid fa-circle-check"></i>
                        Available in the library
                    </p>

                <% } else { %>

                    <p class="details-availability unavailable">
                        <i class="fa-solid fa-circle-xmark"></i>
                        Currently unavailable
                    </p>

                <% } %>

                <!-- SHOW BORROW BOOK ONLY TO APPROVED USERS WHEN COPIES ARE AVAILABLE -->
                
<!-- SUBMIT A BORROW REQUEST FOR ADMIN APPROVAL -->
<% if (isLoggedInUser && isBookAvailable) { %>

    <form action="<%= contextPath %>/borrow-book"
          method="post"
          class="borrow-book-form">

        <input type="hidden"
               name="bookId"
               value="<%= book.getBookId() %>">

        <button type="submit" class="btn btn-primary">
            <i class="fa-solid fa-book-bookmark"></i>
            Borrow Book
        </button>

    </form>

<% } %>
                

                <!-- EXPLORE MORE BOOKS USING THE CORRECT DESTINATION -->
                <a href="<%= booksBackUrl %>" class="btn btn-primary">
                    <i class="fa-solid fa-book-open"></i>
                    Explore More Books
                </a>

            </div>

        </section>

    </main>

    <!-- REUSE THE SHARED FOOTER -->
    <jsp:include page="/components/footer.jsp" />

</body>
</html>
