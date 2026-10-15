
<%@ page import="com.tap.model.Book" %>
<%@ page import="java.util.Objects" %>

<%
    // GET THE BOOK DETAILS AND ERROR MESSAGE FROM THE CONTROLLER
    Book book = (Book) request.getAttribute("book");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String contextPath = request.getContextPath();

    // PREVENT THE FORM FROM DISPLAYING WITHOUT A VALID BOOK
    if (book == null) {
        response.sendRedirect(contextPath + "/admin/books?result=notfound");
        return;
    }

    // PREPARE VALUES FOR SAFE HTML DISPLAY
    String title = book.getTitle() == null ? "" : book.getTitle();
    String author = book.getAuthor() == null ? "" : book.getAuthor();
    String category = book.getCategory() == null ? "" : book.getCategory();
    String isbn = book.getIsbn() == null ? "" : book.getIsbn();
    String publisher = book.getPublisher() == null ? "" : book.getPublisher();
    String description = book.getDescription() == null ? "" : book.getDescription();
    String image = book.getImage() == null ? "" : book.getImage();

    // ESCAPE SPECIAL CHARACTERS BEFORE DISPLAYING DATABASE VALUES IN HTML
    java.util.function.Function<String, String> escapeHtml = value -> value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
%>

<section class="add-book-page">

    <!-- PAGE HEADING -->
    <div class="add-book-heading">
        <div>
            <p class="add-book-eyebrow">BOOK MANAGEMENT</p>
            <h2>Edit Book Details</h2>
            <p>Update the information for this book in your library collection.</p>
        </div>

        <a href="<%= contextPath %>/admin/books" class="back-to-books-button">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Books
        </a>
    </div>

    <!-- DISPLAY VALIDATION OR DATABASE ERRORS -->
    <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
        <div class="form-error-message" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= escapeHtml.apply(errorMessage) %></span>
        </div>
    <% } %>

    <!-- EDIT BOOK FORM -->
    <div class="add-book-form-card">

        <div class="form-card-heading">
            <div class="form-heading-icon">
                <i class="fa-solid fa-pen-to-square"></i>
            </div>

            <div>
                <h3>Book Information</h3>
                <p>Book ID: <%= book.getBookId() %></p>
            </div>
        </div>

        <form action="<%= contextPath %>/admin/edit-book"
              method="post"
              id="editBookForm">

            <!-- SEND THE BOOK ID TO THE CONTROLLER -->
            <input type="hidden"
                   name="bookId"
                   value="<%= book.getBookId() %>">

            <div class="book-form-grid">

                <!-- BOOK TITLE -->
                <div class="form-group full-width">
                    <label for="title">Book Title <span>*</span></label>
                    <input type="text"
                           id="title"
                           name="title"
                           maxlength="200"
                           value="<%= escapeHtml.apply(title) %>"
                           placeholder="Enter book title"
                           required>
                </div>

                <!-- AUTHOR -->
                <div class="form-group">
                    <label for="author">Author <span>*</span></label>
                    <input type="text"
                           id="author"
                           name="author"
                           maxlength="150"
                           value="<%= escapeHtml.apply(author) %>"
                           placeholder="Enter author name"
                           required>
                </div>

                <!-- CATEGORY -->
                <div class="form-group">
                    <label for="category">Category <span>*</span></label>
                    <input type="text"
                           id="category"
                           name="category"
                           maxlength="100"
                           value="<%= escapeHtml.apply(category) %>"
                           placeholder="Enter book category"
                           required>
                </div>

                <!-- ISBN -->
                <div class="form-group">
                    <label for="isbn">ISBN <span>*</span></label>
                    <input type="text"
                           id="isbn"
                           name="isbn"
                           maxlength="20"
                           value="<%= escapeHtml.apply(isbn) %>"
                           placeholder="Enter ISBN"
                           required>
                </div>

                <!-- PUBLISHER -->
                <div class="form-group">
                    <label for="publisher">Publisher</label>
                    <input type="text"
                           id="publisher"
                           name="publisher"
                           maxlength="150"
                           value="<%= escapeHtml.apply(publisher) %>"
                           placeholder="Enter publisher name">
                </div>

                <!-- PUBLICATION YEAR -->
                <div class="form-group">
                    <label for="publishedYear">Publication Year</label>
                    <input type="number"
                           id="publishedYear"
                           name="publishedYear"
                           min="1"
                           max="9999"
                           value="<%= book.getPublishedYear() == 0 ? "" : book.getPublishedYear() %>"
                           placeholder="Enter publication year">
                </div>

                <!-- TOTAL COPIES -->
                <div class="form-group">
                    <label for="totalCopies">Total Copies <span>*</span></label>
                    <input type="number"
                           id="totalCopies"
                           name="totalCopies"
                           min="1"
                           max="10000"
                           value="<%= book.getTotalCopies() %>"
                           required>

                    <small>
                        Currently available:
                        <strong><%= book.getAvailableCopies() %></strong>
                        copies
                    </small>
                </div>

                <!-- BOOK IMAGE URL OR PATH -->
                <div class="form-group full-width">
                    <label for="image">Book Image URL or Path</label>
                    <input type="text"
                           id="image"
                           name="image"
                           maxlength="1000"
                           value="<%= escapeHtml.apply(image) %>"
                           placeholder="Enter an image URL or relative path">

                    <small>
                        Enter an image URL or a relative image path.
                        Leave unchanged if you want to keep the current image.
                    </small>
                </div>

                <!-- IMAGE PREVIEW -->
                <% if (!image.trim().isEmpty()) { %>
                    <div class="form-group full-width">
                        <label>Current Image Preview</label>
                        <div class="edit-book-image-preview">
                            <img src="<%= escapeHtml.apply(image) %>"
                                 alt="Current book cover"
                                 onerror="this.style.display='none';">
                        </div>
                    </div>
                <% } %>

                <!-- DESCRIPTION -->
                <div class="form-group full-width">
                    <label for="description">Description</label>
                    <textarea id="description"
                              name="description"
                              rows="5"
                              placeholder="Enter a short description"><%= escapeHtml.apply(description) %></textarea>
                </div>

            </div>

            <!-- FORM ACTIONS -->
            <div class="book-form-actions">
                <a href="<%= contextPath %>/admin/books"
                   class="cancel-form-button">
                    Cancel
                </a>

                <button type="submit" class="submit-book-button">
                    <i class="fa-solid fa-floppy-disk"></i>
                    Save Changes
                </button>
            </div>

        </form>
    </div>

</section>
