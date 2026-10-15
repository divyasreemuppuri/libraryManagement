package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.BookDAO;
import com.tap.model.Book;
import com.tap.utility.DBConnection;

public class BookDAOImpl implements BookDAO {

    @Override
    public boolean addBook(Book book) {

        String sql = "INSERT INTO book "
                + "(title, author, category, isbn, publisher, publishedYear, "
                + "totalCopies, availableCopies, description, image) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, book.getTitle());
            ps.setString(2, book.getAuthor());
            ps.setString(3, book.getCategory());
            ps.setString(4, book.getIsbn());
            ps.setString(5, book.getPublisher());
            ps.setInt(6, book.getPublishedYear());
            ps.setInt(7, book.getTotalCopies());
            ps.setInt(8, book.getAvailableCopies());
            ps.setString(9, book.getDescription());
            ps.setString(10, book.getImage());

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Book getBookById(int bookId) {

        String sql = "SELECT * FROM book WHERE bookId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapResultSetToBook(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Book> getAllBooks() {

        List<Book> books = new ArrayList<>();

        String sql = "SELECT * FROM book ORDER BY bookId DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return books;
    }

    @Override
    public boolean updateBook(Book book) {

        String sql = "UPDATE book SET "
                + "title = ?, "
                + "author = ?, "
                + "category = ?, "
                + "isbn = ?, "
                + "publisher = ?, "
                + "publishedYear = ?, "
                + "totalCopies = ?, "
                + "availableCopies = ?, "
                + "description = ?, "
                + "image = ? "
                + "WHERE bookId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, book.getTitle());
            ps.setString(2, book.getAuthor());
            ps.setString(3, book.getCategory());
            ps.setString(4, book.getIsbn());
            ps.setString(5, book.getPublisher());
            ps.setInt(6, book.getPublishedYear());
            ps.setInt(7, book.getTotalCopies());
            ps.setInt(8, book.getAvailableCopies());
            ps.setString(9, book.getDescription());
            ps.setString(10, book.getImage());
            ps.setInt(11, book.getBookId());

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteBook(int bookId) {

        String sql = "DELETE FROM book WHERE bookId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookId);

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Book> searchBooksByTitle(String title) {

        List<Book> books = new ArrayList<>();

        String sql = "SELECT * FROM book "
                + "WHERE title LIKE ? "
                + "ORDER BY title";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + title + "%");

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    books.add(mapResultSetToBook(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return books;
    }

    @Override
    public List<Book> searchBooksByCategory(String category) {

        List<Book> books = new ArrayList<>();

        String sql = "SELECT * FROM book "
                + "WHERE category LIKE ? "
                + "ORDER BY title";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + category + "%");

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    books.add(mapResultSetToBook(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return books;
    }

    private Book mapResultSetToBook(ResultSet rs) throws SQLException {

        Book book = new Book();

        book.setBookId(rs.getInt("bookId"));
        book.setTitle(rs.getString("title"));
        book.setAuthor(rs.getString("author"));
        book.setCategory(rs.getString("category"));
        book.setIsbn(rs.getString("isbn"));
        book.setPublisher(rs.getString("publisher"));
        book.setPublishedYear(rs.getInt("publishedYear"));
        book.setTotalCopies(rs.getInt("totalCopies"));
        book.setAvailableCopies(rs.getInt("availableCopies"));
        book.setDescription(rs.getString("description"));
        book.setImage(rs.getString("image"));

        if (rs.getTimestamp("createdAt") != null) {
            book.setCreatedAt(
                rs.getTimestamp("createdAt").toLocalDateTime()
            );
        }

        return book;
    }
}