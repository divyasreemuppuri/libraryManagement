
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    // GET VALIDATION OR DATABASE ERRORS FROM THE CONTROLLER
    String errorMessage = (String) request.getAttribute("errorMessage");
    String contextPath = request.getContextPath();

    // ESCAPE HTML CHARACTERS TO DISPLAY ERROR MESSAGES SAFELY
    String safeErrorMessage = null;

    if (errorMessage != null && !errorMessage.trim().isEmpty()) {
        safeErrorMessage = errorMessage
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
%>

<div class="add-book-page">

    <!-- PAGE HEADING -->
    <section class="add-book-heading">
        <div>
            <h2>Book Information</h2>
            <p>Enter the details below to add a new book record.</p>
        </div>

        <a href="<%= contextPath %>/admin/books" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Books
        </a>
    </section>

    <!-- DISPLAY VALIDATION OR DATABASE ERRORS SAFELY -->
    <% if (safeErrorMessage != null) { %>
        <div class="form-message error-message" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span><%= safeErrorMessage %></span>
        </div>
    <% } %>

    <!-- ADD BOOK FORM -->
    <form id="addBookForm"
          action="<%= contextPath %>/admin/add-book"
          method="post"
          enctype="multipart/form-data">

        <!-- BASIC BOOK DETAILS -->
        <section class="book-form-card">
            <h3><i class="fa-solid fa-book"></i> Basic Details</h3>

            <div class="book-form-grid">

                <div class="form-group">
                    <label for="title">Book Title *</label>
                    <input type="text" id="title" name="title"
                           maxlength="200" required>
                </div>

                <div class="form-group">
                    <label for="author">Author *</label>
                    <input type="text" id="author" name="author"
                           maxlength="150" required>
                </div>

                <div class="form-group">
                    <label for="category">Category *</label>
                    <input type="text" id="category" name="category"
                           maxlength="100"
                           placeholder="e.g. Programming, Fiction" required>
                </div>

                <div class="form-group">
                    <label for="isbn">ISBN *</label>
                    <input type="text" id="isbn" name="isbn"
                           maxlength="20" required>
                </div>

                <div class="form-group">
                    <label for="publisher">Publisher</label>
                    <input type="text" id="publisher" name="publisher"
                           maxlength="150">
                </div>

                <div class="form-group">
                    <label for="publishedYear">Publication Year</label>
                    <input type="number" id="publishedYear"
                           name="publishedYear" min="1" max="9999">
                </div>

                <div class="form-group">
                    <label for="totalCopies">Total Copies *</label>
                    <input type="number" id="totalCopies"
                           name="totalCopies" min="1" max="10000"
                           value="1" required>
                </div>

                <div class="form-group full-width">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="4"
                              placeholder="Enter a short description of the book"></textarea>
                </div>

            </div>
        </section>

        <!-- BOOK COVER IMAGE -->
        <section class="book-form-card">
            <h3><i class="fa-solid fa-image"></i> Book Cover Image</h3>
            <p class="form-help">
                Choose an image URL/path or upload an image file.
            </p>

            <div class="image-source-options">

                <label class="image-source-option">
                    <input type="radio" name="imageMethod"
                           value="url" checked>
                    <span>
                        <i class="fa-solid fa-link"></i>
                        Image URL / Path
                    </span>
                </label>

                <label class="image-source-option">
                    <input type="radio" name="imageMethod"
                           value="upload">
                    <span>
                        <i class="fa-solid fa-cloud-arrow-up"></i>
                        Upload Image
                    </span>
                </label>

            </div>

            <div class="form-group" id="imageUrlGroup">
                <label for="imageUrl">Image URL or Existing Image Path</label>
                <input type="text" id="imageUrl" name="imageUrl"
                       maxlength="1000"
                       placeholder="https://example.com/book-cover.jpg">
                <small>
                    Enter a valid image URL or an existing application image path.
                </small>
            </div>

            <div class="form-group" id="imageFileGroup" hidden>
                <label for="imageFile">Choose Image File</label>
                <input type="file" id="imageFile" name="imageFile"
                       accept="image/jpeg,image/png,image/webp,image/gif"
                       disabled>
                <small>Supported formats: JPG, PNG, WEBP and GIF.</small>
            </div>

        </section>

        <!-- FORM ACTIONS -->
        <div class="book-form-actions">

            <a href="<%= contextPath %>/admin/books"
               class="cancel-button">
                Cancel
            </a>

            <button type="submit" class="save-book-button">
                <i class="fa-solid fa-plus"></i>
                Add Book
            </button>

        </div>

    </form>

</div>

<script>
    // GET THE IMAGE SOURCE CONTROLS
    const imageMethodInputs =
        document.querySelectorAll('input[name="imageMethod"]');

    const imageUrlGroup = document.getElementById("imageUrlGroup");
    const imageFileGroup = document.getElementById("imageFileGroup");
    const imageUrlInput = document.getElementById("imageUrl");
    const imageFileInput = document.getElementById("imageFile");

    // ENABLE ONLY THE SELECTED IMAGE SOURCE
    function updateImageSource() {
        const selectedInput =
            document.querySelector('input[name="imageMethod"]:checked');

        if (!selectedInput) {
            return;
        }

        const useUrl = selectedInput.value === "url";

        imageUrlGroup.hidden = !useUrl;
        imageFileGroup.hidden = useUrl;

        imageUrlInput.disabled = !useUrl;
        imageFileInput.disabled = useUrl;

        // CLEAR THE INACTIVE IMAGE INPUT
        if (useUrl) {
            imageFileInput.value = "";
        } else {
            imageUrlInput.value = "";
        }
    }

    // LISTEN FOR IMAGE SOURCE CHANGES
    imageMethodInputs.forEach(function(input) {
        input.addEventListener("change", updateImageSource);
    });

    // SET THE INITIAL IMAGE SOURCE STATE
    updateImageSource();
</script>