package com.tap.model;

import java.time.LocalDateTime;

public class Book {

    private int bookId;
    private String title;
    private String author;
    private String category;
    private String isbn;
    private String publisher;
    private int publishedYear;
    private int totalCopies;
    private int availableCopies;
    private String description;
    private String image;
    private LocalDateTime createdAt;

    // No-argument constructor
    public Book() {
    }

    // Parameterized constructor
    public Book(int bookId, String title, String author, String category,
                String isbn, String publisher, int publishedYear,
                int totalCopies, int availableCopies, String description,
                String image, LocalDateTime createdAt) {

        this.bookId = bookId;
        this.title = title;
        this.author = author;
        this.category = category;
        this.isbn = isbn;
        this.publisher = publisher;
        this.publishedYear = publishedYear;
        this.totalCopies = totalCopies;
        this.availableCopies = availableCopies;
        this.description = description;
        this.image = image;
        this.createdAt = createdAt;
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public int getPublishedYear() {
        return publishedYear;
    }

    public void setPublishedYear(int publishedYear) {
        this.publishedYear = publishedYear;
    }

    public int getTotalCopies() {
        return totalCopies;
    }

    public void setTotalCopies(int totalCopies) {
        this.totalCopies = totalCopies;
    }

    public int getAvailableCopies() {
        return availableCopies;
    }

    public void setAvailableCopies(int availableCopies) {
        this.availableCopies = availableCopies;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Book [bookId=" + bookId
                + ", title=" + title
                + ", author=" + author
                + ", category=" + category
                + ", isbn=" + isbn
                + ", publisher=" + publisher
                + ", publishedYear=" + publishedYear
                + ", totalCopies=" + totalCopies
                + ", availableCopies=" + availableCopies
                + ", description=" + description
                + ", image=" + image
                + ", createdAt=" + createdAt
                + "]";
    }
}