
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Book" %>

<%
    // GET THE BOOK LIST PROVIDED BY THE CONTROLLER
    List<Book> books = (List<Book>) request.getAttribute("books");

    // READ THE RESULT PARAMETER FOR STATUS MESSAGES
    String result = request.getParameter("result");
    String contextPath = request.getContextPath();
%>

<!-- DISPLAY STATUS MESSAGES -->
<%
    String toastMessage = null;
    String toastClass = "success-toast";
    String toastIcon = "fa-circle-check";

    if ("added".equals(result)) {
        toastMessage = "Book added successfully!";
    } else if ("updated".equals(result)) {
        toastMessage = "Book updated successfully!";
    } else if ("deleted".equals(result)) {
        toastMessage = "Book deleted successfully!";
    } else if ("deletefailed".equals(result)) {
        toastMessage = "Book could not be deleted. It may have borrowing records or may no longer exist.";
        toastClass = "error-toast";
        toastIcon = "fa-circle-exclamation";
    } else if ("invalid".equals(result)) {
        toastMessage = "Invalid book ID.";
        toastClass = "error-toast";
        toastIcon = "fa-circle-exclamation";
    } else if ("notfound".equals(result)) {
        toastMessage = "The requested book was not found.";
        toastClass = "error-toast";
        toastIcon = "fa-circle-exclamation";
    }
%>

<% if (toastMessage != null) { %>
    <div id="statusToast"
         class="<%= toastClass %>"
         role="status">

        <i class="fa-solid <%= toastIcon %>"></i>

        <span><%= toastMessage %></span>

        <button type="button"
                class="toast-close"
                onclick="closeStatusToast()"
                aria-label="Close message">
            &times;
        </button>
    </div>
<% } %>

<!-- MANAGE BOOKS CONTENT -->
<div class="books-page">

    <!-- PAGE HEADING -->
    <section class="books-heading">
        <div>
            <h2>Library Collection</h2>
            <p>View and manage the books available in your library.</p>
        </div>

        <a href="<%= contextPath %>/admin/add-book"
           class="add-book-button">
            <i class="fa-solid fa-plus"></i>
            Add New Book
        </a>
    </section>

    <!-- BOOK COUNT -->
    <section class="books-summary">
        <div class="books-summary-icon">
            <i class="fa-solid fa-book-open"></i>
        </div>

        <div>
            <div class="books-summary-label">Total Book Records</div>
            <div class="books-summary-value">
                <%= books == null ? 0 : books.size() %>
            </div>
        </div>
    </section>

    <!-- BOOKS TABLE -->
    <section class="books-table-container">

        <% if (books == null || books.isEmpty()) { %>

            <div class="empty-books">
                <i class="fa-solid fa-book-open"></i>
                <h3>No books found</h3>
                <p>Your library collection is currently empty.</p>

                <a href="<%= contextPath %>/admin/add-book"
                   class="add-book-button">
                    <i class="fa-solid fa-plus"></i>
                    Add Your First Book
                </a>
            </div>

        <% } else { %>

            <div class="books-table-wrapper">
                <table class="books-table">

                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>Category</th>
                            <th>ISBN</th>
                            <th>Publisher</th>
                            <th>Year</th>
                            <th>Total Copies</th>
                            <th>Available</th>
                            <th>Actions</th>
                        </tr>
                    </thead>

                    <tbody>

                        <% for (Book book : books) { %>

                            <tr>
                                <!-- BOOK DETAILS -->
                                <td>
                                    <div class="managed-book-title">
                                        <%= book.getTitle() == null
                                                ? "Untitled" : book.getTitle() %>
                                    </div>

                                    <div class="managed-book-author">
                                        <%= book.getAuthor() == null
                                                ? "Unknown author" : book.getAuthor() %>
                                    </div>
                                </td>

                                <td>
                                    <%= book.getCategory() == null
                                            ? "—" : book.getCategory() %>
                                </td>

                                <td class="book-isbn">
                                    <%= book.getIsbn() == null
                                            ? "—" : book.getIsbn() %>
                                </td>

                                <td>
                                    <%= book.getPublisher() == null
                                            ? "—" : book.getPublisher() %>
                                </td>

                                <td><%= book.getPublishedYear() %></td>

                                <td><%= book.getTotalCopies() %></td>

                                <!-- AVAILABLE COPIES -->
                                <td>
                                    <span class="available-count <%= book.getAvailableCopies() > 0
                                            ? "in-stock" : "out-of-stock" %>">
                                        <%= book.getAvailableCopies() %>
                                    </span>
                                </td>

                                <!-- BOOK ACTIONS -->
                                <td>
                                    <div class="book-actions">

                                        <!-- EDIT BOOK -->
                                        <a href="<%= contextPath %>/admin/edit-book?bookId=<%= book.getBookId() %>"
                                           class="book-action-button edit-book-button"
                                           title="Edit book"
                                           aria-label="Edit book">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>

                                        <!-- DELETE BOOK -->
                                        <form action="<%= contextPath %>/admin/delete-book"
                                              method="post"
                                              class="delete-book-form"
                                              onsubmit="return confirmDeleteBook('<%= book.getBookId() %>');">

                                            <!-- PASS THE BOOK ID TO THE CONTROLLER -->
                                            <input type="hidden"
                                                   name="bookId"
                                                   value="<%= book.getBookId() %>">

                                            <button type="submit"
                                                    class="book-action-button delete-book-button"
                                                    title="Delete book"
                                                    aria-label="Delete book">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>

                                        </form>

                                    </div>
                                </td>

                            </tr>

                        <% } %>

                    </tbody>
                </table>
            </div>

        <% } %>

    </section>

</div>

<script>
    // ASK FOR CONFIRMATION BEFORE DELETING A BOOK
    function confirmDeleteBook(bookId) {
        return confirm(
            "Are you sure you want to delete book ID " + bookId
            + "?\n\nThis action cannot be undone."
        );
    }

    // AUTOMATICALLY HIDE STATUS MESSAGES
    document.addEventListener("DOMContentLoaded", function() {
        const toast = document.getElementById("statusToast");

        if (toast) {
            setTimeout(function() {
                toast.classList.add("hide");

                setTimeout(function() {
                    toast.remove();
                }, 400);

            }, 4000);
        }
    });

    // ALLOW THE ADMIN TO CLOSE STATUS MESSAGES
    function closeStatusToast() {
        const toast = document.getElementById("statusToast");

        if (toast) {
            toast.classList.add("hide");

            setTimeout(function() {
                toast.remove();
            }, 400);
        }
    }
</script>
