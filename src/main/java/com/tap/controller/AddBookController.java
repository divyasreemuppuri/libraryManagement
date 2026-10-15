
package com.tap.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.UUID;

import com.tap.dao.BookDAO;
import com.tap.daoimpl.BookDAOImpl;
import com.tap.model.Book;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/admin/add-book")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 6 * 1024 * 1024
)
public class AddBookController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // CREATE THE BOOK DAO USING THE EXISTING IMPLEMENTATION
    private final BookDAO bookDAO = new BookDAOImpl();

    // DISPLAY THE ADD BOOK FORM INSIDE THE SHARED ADMIN LAYOUT
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        if (!isAdmin(request, response)) {
            return;
        }

        // CONFIGURE THE SHARED ADMIN LAYOUT
        setAddBookPageAttributes(request);

        // DISPLAY THE ADD BOOK CONTENT INSIDE THE COMMON LAYOUT
        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }

    // PROCESS THE ADD BOOK FORM
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // CHECK WHETHER AN ADMIN IS LOGGED IN
        if (!isAdmin(request, response)) {
            return;
        }

        String contextPath = request.getContextPath();
        Path savedFile = null;

        try {
            // READ AND VALIDATE THE BASIC BOOK DETAILS
            String title = getParameter(request, "title");
            String author = getParameter(request, "author");
            String category = getParameter(request, "category");
            String isbn = getParameter(request, "isbn");
            String publisher = getParameter(request, "publisher");
            String yearText = getParameter(request, "publishedYear");
            String copiesText = getParameter(request, "totalCopies");
            String description = getParameter(request, "description");

            if (title.isEmpty() || author.isEmpty()
                    || category.isEmpty() || isbn.isEmpty()
                    || copiesText.isEmpty()) {

                showError(request, response,
                        "Please fill in all required book details.");
                return;
            }

            if (title.length() > 200 || author.length() > 150
                    || category.length() > 100 || isbn.length() > 20
                    || publisher.length() > 150) {

                showError(request, response,
                        "One or more book details exceed the allowed length.");
                return;
            }

            // VALIDATE THE PUBLICATION YEAR
            int publishedYear = 0;

            if (!yearText.isEmpty()) {
                publishedYear = Integer.parseInt(yearText);

                if (publishedYear < 1 || publishedYear > 9999) {
                    showError(request, response,
                            "Please enter a valid publication year.");
                    return;
                }
            }

            // VALIDATE THE TOTAL NUMBER OF COPIES
            int totalCopies = Integer.parseInt(copiesText);

            if (totalCopies < 1 || totalCopies > 10000) {
                showError(request, response,
                        "Total copies must be between 1 and 10000.");
                return;
            }

            // IDENTIFY THE SELECTED IMAGE SOURCE
            String imageMethod = getParameter(request, "imageMethod");
            String image = "";

            if ("url".equals(imageMethod)) {

                // USE THE URL OR EXISTING IMAGE PATH
                image = getParameter(request, "imageUrl");

                if (image.length() > 1000) {
                    showError(request, response,
                            "The image URL or path is too long.");
                    return;
                }

                // ACCEPT HTTP/HTTPS URLS OR RELATIVE IMAGE PATHS
                if (!image.isEmpty()
                        && !isAllowedImageReference(image)) {

                    showError(request, response,
                            "Enter a valid HTTP/HTTPS image URL or image path.");
                    return;
                }

            } else if ("upload".equals(imageMethod)) {

                // GET THE UPLOADED IMAGE
                Part imagePart = request.getPart("imageFile");

                if (imagePart == null || imagePart.getSize() == 0) {
                    showError(request, response,
                            "Please select an image file to upload.");
                    return;
                }

                // LIMIT THE UPLOAD SIZE TO 5 MB
                if (imagePart.getSize() > 5L * 1024 * 1024) {
                    showError(request, response,
                            "The image file must not exceed 5 MB.");
                    return;
                }

                // VALIDATE THE IMAGE CONTENT TYPE
                String contentType = imagePart.getContentType();

                if (!isAllowedImageType(contentType)) {
                    showError(request, response,
                            "Only JPG, PNG, WEBP and GIF images are allowed.");
                    return;
                }

                // VALIDATE THE FILE EXTENSION
                String submittedName = imagePart.getSubmittedFileName();

                String originalName = Paths.get(
                        submittedName == null ? "" : submittedName
                ).getFileName().toString();

                String extension = getImageExtension(originalName);

                if (extension == null) {
                    showError(request, response,
                            "The uploaded file must have a JPG, PNG, WEBP or GIF extension.");
                    return;
                }

                // CREATE THE IMAGE STORAGE DIRECTORY
                String uploadDirectory =
                        getServletContext().getRealPath("/uploads/books");

                if (uploadDirectory == null) {
                    showError(request, response,
                            "Image storage is unavailable. Please configure the application upload directory.");
                    return;
                }

                Path directory = Paths.get(uploadDirectory);
                Files.createDirectories(directory);

                // GENERATE A SAFE, UNIQUE FILE NAME
                String fileName = UUID.randomUUID().toString()
                        + "." + extension;

                savedFile = directory.resolve(fileName);

                // SAVE THE IMAGE FILE
                imagePart.write(savedFile.toAbsolutePath().toString());

                // STORE A RELATIVE PATH IN THE DATABASE
                image = "uploads/books/" + fileName;

            } else {
                showError(request, response,
                        "Please select either an image URL/path or an uploaded image.");
                return;
            }

            // CREATE THE BOOK MODEL OBJECT
            Book book = new Book();

            book.setTitle(title);
            book.setAuthor(author);
            book.setCategory(category);
            book.setIsbn(isbn);
            book.setPublisher(publisher);
            book.setPublishedYear(publishedYear);
            book.setTotalCopies(totalCopies);

            // NEW BOOKS START WITH ALL COPIES AVAILABLE
            book.setAvailableCopies(totalCopies);

            book.setDescription(description);
            book.setImage(image);

            // SAVE THE BOOK USING THE EXISTING DAO METHOD
            boolean added = bookDAO.addBook(book);

            if (added) {
                // REDIRECT AFTER SUCCESSFUL INSERTION
                response.sendRedirect(
                        contextPath + "/admin/books?result=added");
                return;
            }

            // REMOVE AN UPLOADED FILE IF THE DATABASE INSERT FAILS
            deleteSavedFile(savedFile);
            savedFile = null;

            showError(request, response,
                    "The book could not be added. Check whether the ISBN already exists.");

        } catch (NumberFormatException e) {

            // HANDLE INVALID NUMERIC INPUTS
            deleteSavedFile(savedFile);

            showError(request, response,
                    "Enter valid numbers for the publication year and total copies.");

        } catch (IllegalStateException e) {

            // HANDLE REQUESTS THAT EXCEED THE UPLOAD LIMIT
            deleteSavedFile(savedFile);

            showError(request, response,
                    "The upload exceeds the allowed size. Please use an image smaller than 5 MB.");

        } catch (ServletException e) {

            // HANDLE MULTIPART REQUEST ERRORS
            deleteSavedFile(savedFile);

            showError(request, response,
                    "The image upload could not be processed. Check the selected file and try again.");

        } catch (IOException e) {

            // HANDLE IMAGE STORAGE OR REQUEST ERRORS
            deleteSavedFile(savedFile);

            throw e;
        }
    }

    // CONFIGURE THE PAGE ATTRIBUTES USED BY THE SHARED ADMIN LAYOUT
    private void setAddBookPageAttributes(HttpServletRequest request) {

        request.setAttribute("pageTitle", "Add New Book");
        request.setAttribute("pageSubtitle",
                "Add a new book to the library collection");
        request.setAttribute("activePage", "add-book");
        request.setAttribute("adminContent", "/add-book.jsp");
    }

    // VERIFY THAT THE SESSION BELONGS TO AN ADMIN
    private boolean isAdmin(HttpServletRequest request,
                            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = (session == null)
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return false;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Admin privileges are required.");
            return false;
        }

        return true;
    }

    // SAFELY READ A FORM PARAMETER
    private String getParameter(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    // VALIDATE AN IMAGE URL OR PATH
    private boolean isAllowedImageReference(String image) {

        String lowerImage = image.toLowerCase(Locale.ROOT);

        if (lowerImage.startsWith("https://")
                || lowerImage.startsWith("http://")) {

            try {
                java.net.URI uri = java.net.URI.create(image);

                return uri.getHost() != null
                        && uri.getUserInfo() == null;

            } catch (IllegalArgumentException e) {
                return false;
            }
        }

        // REJECT SCRIPT SCHEMES, PROTOCOL-RELATIVE URLS AND PATH TRAVERSAL
        if (lowerImage.startsWith("//")
                || image.contains("\\")
                || image.contains("..")) {
            return false;
        }

        return image.matches("[a-zA-Z0-9_./-]+");
    }

    // ALLOW ONLY THE SUPPORTED IMAGE CONTENT TYPES
    private boolean isAllowedImageType(String contentType) {

        if (contentType == null) {
            return false;
        }

        return contentType.equalsIgnoreCase("image/jpeg")
                || contentType.equalsIgnoreCase("image/png")
                || contentType.equalsIgnoreCase("image/webp")
                || contentType.equalsIgnoreCase("image/gif");
    }

    // GET A SUPPORTED FILE EXTENSION
    private String getImageExtension(String fileName) {

        int dotIndex = fileName.lastIndexOf('.');

        if (dotIndex < 0) {
            return null;
        }

        String extension = fileName.substring(dotIndex + 1)
                .toLowerCase(Locale.ROOT);

        if (extension.equals("jpg") || extension.equals("jpeg")
                || extension.equals("png") || extension.equals("webp")
                || extension.equals("gif")) {
            return extension;
        }

        return null;
    }

    // DELETE AN UPLOADED FILE WHEN BOOK INSERTION FAILS
    private void deleteSavedFile(Path savedFile) {

        if (savedFile != null) {
            try {
                Files.deleteIfExists(savedFile);
            } catch (IOException e) {
                getServletContext().log(
                        "Could not remove an unused uploaded book image.", e);
            }
        }
    }

    // RETURN TO THE ADD BOOK FORM WITH AN ERROR MESSAGE
    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        // RESTORE THE SHARED ADMIN LAYOUT ATTRIBUTES
        setAddBookPageAttributes(request);

        // DISPLAY THE FORM AND ERROR INSIDE THE SHARED LAYOUT
        request.getRequestDispatcher("/admin-layout.jsp")
               .forward(request, response);
    }
}