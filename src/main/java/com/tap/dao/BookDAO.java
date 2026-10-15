package com.tap.dao;

import java.util.List;

import com.tap.model.Book;

public interface BookDAO {

    // Add a new book
    boolean addBook(Book book);

    // Get a book by its ID
    Book getBookById(int bookId);

    // Get all books
    List<Book> getAllBooks();

    // Update book details
    boolean updateBook(Book book);

    // Delete a book
    boolean deleteBook(int bookId);

    // Search books by title
    List<Book> searchBooksByTitle(String title);

    // Search books by category
    List<Book> searchBooksByCategory(String category);
}