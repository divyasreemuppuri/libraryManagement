package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.dao.BorrowDAO;
import com.tap.model.Borrow;
import com.tap.utility.DBConnection;

public class BorrowDAOImpl implements BorrowDAO {

    // BORROW A BOOK DIRECTLY
    // USER-FACING CONTROLLERS WILL USE THE REQUEST WORKFLOW INSTEAD
    @Override
    public boolean borrowBook(Borrow borrow) {

        String checkBookSql =
                "SELECT availableCopies FROM book WHERE bookId = ? FOR UPDATE";

        String insertBorrowSql =
                "INSERT INTO borrow "
              + "(userId, bookId, borrowDate, dueDate, status) "
              + "VALUES (?, ?, ?, ?, 'BORROWED')";

        String updateBookSql =
                "UPDATE book "
              + "SET availableCopies = availableCopies - 1 "
              + "WHERE bookId = ? AND availableCopies > 0";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(checkBookSql)) {
                ps.setInt(1, borrow.getBookId());

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || rs.getInt("availableCopies") <= 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(updateBookSql)) {
                ps.setInt(1, borrow.getBookId());

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            LocalDateTime borrowDate = borrow.getBorrowDate();

            if (borrowDate == null) {
                borrowDate = LocalDateTime.now();
            }

            LocalDateTime dueDate = borrowDate.plusDays(15);

            borrow.setBorrowDate(borrowDate);
            borrow.setDueDate(dueDate);

            try (PreparedStatement ps = con.prepareStatement(insertBorrowSql)) {
                ps.setInt(1, borrow.getUserId());
                ps.setInt(2, borrow.getBookId());
                ps.setTimestamp(3, Timestamp.valueOf(borrowDate));
                ps.setTimestamp(4, Timestamp.valueOf(dueDate));

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            rollbackTransaction(con);
            e.printStackTrace();
            return false;

        } finally {
            closeTransactionConnection(con);
        }
    }

    // GET A BORROWING RECORD BY ID
    @Override
    public Borrow getBorrowById(int borrowId) {

        String sql = "SELECT * FROM borrow WHERE borrowId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, borrowId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBorrow(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // GET ACTIVE BORROWINGS FOR A USER
    @Override
    public List<Borrow> getActiveBorrowsByUser(int userId) {

        List<Borrow> borrows = new ArrayList<>();

        String sql =
                "SELECT * FROM borrow "
              + "WHERE userId = ? "
              + "AND status IN ('BORROWED', 'OVERDUE') "
              + "ORDER BY borrowDate DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    borrows.add(mapResultSetToBorrow(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return borrows;
    }

    // GET COMPLETE BORROWING HISTORY FOR A USER
    @Override
    public List<Borrow> getBorrowHistoryByUser(int userId) {

        List<Borrow> borrows = new ArrayList<>();

        String sql =
                "SELECT * FROM borrow "
              + "WHERE userId = ? "
              + "ORDER BY borrowDate DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    borrows.add(mapResultSetToBorrow(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return borrows;
    }

    // RENEW A BOOK DIRECTLY
    // USER-FACING CONTROLLERS WILL USE THE REQUEST WORKFLOW INSTEAD
    @Override
    public boolean renewBook(int borrowId, int userId) {

        String sql =
                "UPDATE borrow "
              + "SET dueDate = DATE_ADD(dueDate, INTERVAL 15 DAY) "
              + "WHERE borrowId = ? "
              + "AND userId = ? "
              + "AND status = 'BORROWED' "
              + "AND dueDate > CURRENT_TIMESTAMP";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, borrowId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // RETURN A BORROWED BOOK AND CALCULATE THE OVERDUE FINE
    @Override
    public boolean returnBook(int borrowId) {

        String getBorrowSql =
                "SELECT bookId, status, dueDate, userId "
              + "FROM borrow WHERE borrowId = ? FOR UPDATE";

        String updateBorrowSql =
                "UPDATE borrow "
              + "SET returnDate = ?, status = 'RETURNED' "
              + "WHERE borrowId = ? "
              + "AND status IN ('BORROWED', 'OVERDUE')";

        String updateBookSql =
                "UPDATE book "
              + "SET availableCopies = availableCopies + 1 "
              + "WHERE bookId = ?";

        String fineSql =
                "INSERT INTO fine "
              + "(borrowId, userId, daysOverdue, fineAmount, status) "
              + "VALUES (?, ?, ?, ?, 'PENDING') "
              + "ON DUPLICATE KEY UPDATE "
              + "daysOverdue = IF(status = 'PENDING', "
              + "VALUES(daysOverdue), daysOverdue), "
              + "fineAmount = IF(status = 'PENDING', "
              + "VALUES(fineAmount), fineAmount)";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int bookId;
            int userId;
            LocalDateTime dueDate;

            try (PreparedStatement ps = con.prepareStatement(getBorrowSql)) {
                ps.setInt(1, borrowId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    String status = rs.getString("status");

                    if ("RETURNED".equalsIgnoreCase(status)) {
                        con.rollback();
                        return false;
                    }

                    bookId = rs.getInt("bookId");
                    userId = rs.getInt("userId");

                    Timestamp dueTimestamp = rs.getTimestamp("dueDate");

                    if (dueTimestamp == null) {
                        con.rollback();
                        return false;
                    }

                    dueDate = dueTimestamp.toLocalDateTime();
                }
            }

            LocalDateTime returnDate = LocalDateTime.now();

            try (PreparedStatement ps = con.prepareStatement(updateBorrowSql)) {
                ps.setTimestamp(1, Timestamp.valueOf(returnDate));
                ps.setInt(2, borrowId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            long overdueDays = 0;

            if (returnDate.toLocalDate().isAfter(dueDate.toLocalDate())) {
                overdueDays = ChronoUnit.DAYS.between(
                        dueDate.toLocalDate(),
                        returnDate.toLocalDate()
                );
            }

            if (overdueDays > 0) {
                java.math.BigDecimal fineAmount =
                        java.math.BigDecimal.valueOf(overdueDays)
                                .multiply(java.math.BigDecimal.TEN);

                try (PreparedStatement ps = con.prepareStatement(fineSql)) {
                    ps.setInt(1, borrowId);
                    ps.setInt(2, userId);
                    ps.setLong(3, overdueDays);
                    ps.setBigDecimal(4, fineAmount);

                    if (ps.executeUpdate() == 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(updateBookSql)) {
                ps.setInt(1, bookId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            rollbackTransaction(con);
            e.printStackTrace();
            return false;

        } finally {
            closeTransactionConnection(con);
        }
    }

    // GET ALL BORROWING RECORDS
    @Override
    public List<Borrow> getAllBorrows() {

        List<Borrow> borrows = new ArrayList<>();

        String sql = "SELECT * FROM borrow ORDER BY borrowDate DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                borrows.add(mapResultSetToBorrow(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return borrows;
    }

    // GET OVERDUE BORROWING RECORDS
    @Override
    public List<Borrow> getOverdueBorrows() {

        List<Borrow> borrows = new ArrayList<>();

        String sql =
                "SELECT * FROM borrow "
              + "WHERE status = 'OVERDUE' "
              + "OR (status = 'BORROWED' AND dueDate < CURRENT_TIMESTAMP) "
              + "ORDER BY dueDate ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                borrows.add(mapResultSetToBorrow(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return borrows;
    }

    // SUBMIT A BORROW REQUEST ONLY IF NO DUPLICATE IS ACTIVE
    @Override
    public boolean submitBorrowRequest(int userId, int bookId) {

        String lockBookSql =
                "SELECT bookId FROM book WHERE bookId = ? FOR UPDATE";

        String pendingRequestSql =
                "SELECT requestId FROM borrow_request "
              + "WHERE userId = ? AND bookId = ? "
              + "AND status = 'PENDING' LIMIT 1";

        String activeBorrowSql =
                "SELECT borrowId FROM borrow "
              + "WHERE userId = ? AND bookId = ? "
              + "AND status IN ('BORROWED', 'OVERDUE') LIMIT 1";

        String insertRequestSql =
                "INSERT INTO borrow_request (userId, bookId) "
              + "VALUES (?, ?)";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // LOCK THE BOOK ROW TO SERIALIZE REQUESTS FOR THIS BOOK
            try (PreparedStatement ps = con.prepareStatement(lockBookSql)) {
                ps.setInt(1, bookId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // BLOCK A NEW REQUEST WHILE AN EARLIER REQUEST IS PENDING
            try (PreparedStatement ps = con.prepareStatement(pendingRequestSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // BLOCK A NEW REQUEST UNTIL THE PREVIOUS BOOK IS RETURNED
            try (PreparedStatement ps = con.prepareStatement(activeBorrowSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // INSERT THE NEW REQUEST AFTER ALL CHECKS PASS
            try (PreparedStatement ps = con.prepareStatement(insertRequestSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            rollbackTransaction(con);
            e.printStackTrace();
            return false;

        } finally {
            closeTransactionConnection(con);
        }
    }

    // GET ALL PENDING BORROW REQUESTS FOR THE ADMIN
    @Override
    public List<Map<String, Object>> getPendingBorrowRequests() {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql =
                "SELECT br.requestId, br.userId, br.bookId, "
              + "u.name AS userName, b.title AS bookTitle, "
              + "br.requestDate, br.status "
              + "FROM borrow_request br "
              + "JOIN user u ON br.userId = u.userId "
              + "JOIN book b ON br.bookId = b.bookId "
              + "WHERE br.status = 'PENDING' "
              + "ORDER BY br.requestDate ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();

                row.put("requestId", rs.getInt("requestId"));
                row.put("userId", rs.getInt("userId"));
                row.put("bookId", rs.getInt("bookId"));
                row.put("userName", rs.getString("userName"));
                row.put("bookTitle", rs.getString("bookTitle"));
                row.put("requestDate", rs.getTimestamp("requestDate"));
                row.put("status", rs.getString("status"));

                requests.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return requests;
    }

    // GET ALL REJECTED BORROW REQUESTS FOR THE ADMIN
    @Override
    public List<Map<String, Object>> getRejectedBorrowRequests() {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql =
                "SELECT br.requestId, br.userId, br.bookId, "
              + "u.name AS userName, b.title AS bookTitle, "
              + "br.requestDate, br.status, br.rejectionReason, "
              + "br.decidedAt "
              + "FROM borrow_request br "
              + "JOIN user u ON br.userId = u.userId "
              + "JOIN book b ON br.bookId = b.bookId "
              + "WHERE br.status = 'REJECTED' "
              + "ORDER BY br.decidedAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();

                row.put("requestId", rs.getInt("requestId"));
                row.put("userId", rs.getInt("userId"));
                row.put("bookId", rs.getInt("bookId"));
                row.put("userName", rs.getString("userName"));
                row.put("bookTitle", rs.getString("bookTitle"));
                row.put("requestDate", rs.getTimestamp("requestDate"));
                row.put("status", rs.getString("status"));
                row.put("rejectionReason", rs.getString("rejectionReason"));
                row.put("decidedAt", rs.getTimestamp("decidedAt"));

                requests.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return requests;
    }

    // GET A USER'S BORROW REQUEST HISTORY
    @Override
    public List<Map<String, Object>> getBorrowRequestsByUser(int userId) {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql =
                "SELECT br.requestId, br.bookId, b.title AS bookTitle, "
              + "br.requestDate, br.status, br.rejectionReason, br.decidedAt "
              + "FROM borrow_request br "
              + "JOIN book b ON br.bookId = b.bookId "
              + "WHERE br.userId = ? "
              + "ORDER BY br.requestDate DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();

                    row.put("requestId", rs.getInt("requestId"));
                    row.put("bookId", rs.getInt("bookId"));
                    row.put("bookTitle", rs.getString("bookTitle"));
                    row.put("requestDate", rs.getTimestamp("requestDate"));
                    row.put("status", rs.getString("status"));
                    row.put("rejectionReason", rs.getString("rejectionReason"));
                    row.put("decidedAt", rs.getTimestamp("decidedAt"));

                    requests.add(row);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return requests;
    }

    // APPROVE A BORROW REQUEST AND CREATE THE ACTUAL BORROWING
    @Override
    public boolean approveBorrowRequest(int requestId, int adminId) {

        String lockRequestSql =
                "SELECT userId, bookId FROM borrow_request "
              + "WHERE requestId = ? AND status = 'PENDING' FOR UPDATE";

        String lockBookSql =
                "SELECT availableCopies FROM book "
              + "WHERE bookId = ? FOR UPDATE";

        String updateBookSql =
                "UPDATE book SET availableCopies = availableCopies - 1 "
              + "WHERE bookId = ? AND availableCopies > 0";

        String insertBorrowSql =
                "INSERT INTO borrow "
              + "(userId, bookId, borrowDate, dueDate, status) "
              + "VALUES (?, ?, ?, ?, 'BORROWED')";

        String updateRequestSql =
                "UPDATE borrow_request "
              + "SET status = 'APPROVED', decidedAt = CURRENT_TIMESTAMP, "
              + "decidedBy = ?, rejectionReason = NULL "
              + "WHERE requestId = ? AND status = 'PENDING'";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int userId;
            int bookId;

            try (PreparedStatement ps = con.prepareStatement(lockRequestSql)) {
                ps.setInt(1, requestId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    userId = rs.getInt("userId");
                    bookId = rs.getInt("bookId");
                }
            }

            try (PreparedStatement ps = con.prepareStatement(lockBookSql)) {
                ps.setInt(1, bookId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || rs.getInt("availableCopies") <= 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(updateBookSql)) {
                ps.setInt(1, bookId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            LocalDateTime borrowDate = LocalDateTime.now();
            LocalDateTime dueDate = borrowDate.plusDays(15);

            try (PreparedStatement ps = con.prepareStatement(insertBorrowSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);
                ps.setTimestamp(3, Timestamp.valueOf(borrowDate));
                ps.setTimestamp(4, Timestamp.valueOf(dueDate));

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = con.prepareStatement(updateRequestSql)) {
                ps.setInt(1, adminId);
                ps.setInt(2, requestId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            rollbackTransaction(con);
            e.printStackTrace();
            return false;

        } finally {
            closeTransactionConnection(con);
        }
    }

    // REJECT A BORROW REQUEST AND SAVE THE REJECTION REASON
    @Override
    public boolean rejectBorrowRequest(
            int requestId, int adminId, String rejectionReason) {

        if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
            return false;
        }

        String sql =
                "UPDATE borrow_request "
              + "SET status = 'REJECTED', decidedAt = CURRENT_TIMESTAMP, "
              + "decidedBy = ?, rejectionReason = ? "
              + "WHERE requestId = ? AND status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, adminId);
            ps.setString(2, rejectionReason.trim());
            ps.setInt(3, requestId);

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // SUBMIT A RENEWAL REQUEST ONLY WITHIN THE ELIGIBLE WINDOW
    @Override
    public boolean submitRenewalRequest(int borrowId, int userId) {

        String lockBorrowSql =
                "SELECT userId, status, dueDate FROM borrow "
              + "WHERE borrowId = ? FOR UPDATE";

        String pendingRequestSql =
                "SELECT requestId FROM renewal_request "
              + "WHERE borrowId = ? AND status = 'PENDING' LIMIT 1";

        String insertRequestSql =
                "INSERT INTO renewal_request (borrowId, userId) "
              + "SELECT borrowId, userId FROM borrow "
              + "WHERE borrowId = ? AND userId = ? "
              + "AND status IN ('BORROWED', 'OVERDUE') "
              + "AND dueDate IS NOT NULL "
              + "AND dueDate <= DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 5 DAY)";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // LOCK THE BORROWING RECORD BEFORE VALIDATING IT
            try (PreparedStatement ps = con.prepareStatement(lockBorrowSql)) {
                ps.setInt(1, borrowId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    int actualUserId = rs.getInt("userId");
                    String status = rs.getString("status");
                    Timestamp dueTimestamp = rs.getTimestamp("dueDate");

                    if (actualUserId != userId
                            || !("BORROWED".equalsIgnoreCase(status)
                                || "OVERDUE".equalsIgnoreCase(status))
                            || dueTimestamp == null
                            || dueTimestamp.toLocalDateTime()
                                    .isAfter(LocalDateTime.now().plusDays(5))) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // PREVENT DUPLICATE PENDING RENEWAL REQUESTS
            try (PreparedStatement ps = con.prepareStatement(pendingRequestSql)) {
                ps.setInt(1, borrowId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // INSERT THE REQUEST WITHOUT CHANGING THE DUE DATE
            try (PreparedStatement ps = con.prepareStatement(insertRequestSql)) {
                ps.setInt(1, borrowId);
                ps.setInt(2, userId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            rollbackTransaction(con);
            e.printStackTrace();
            return false;

        } finally {
            closeTransactionConnection(con);
        }
    }

    // GET ALL PENDING RENEWAL REQUESTS FOR THE ADMIN
    @Override
    public List<Map<String, Object>> getPendingRenewalRequests() {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql =
                "SELECT rr.requestId, rr.borrowId, rr.userId, "
              + "u.name AS userName, b.title AS bookTitle, "
              + "br.dueDate, rr.requestDate, rr.status "
              + "FROM renewal_request rr "
              + "JOIN borrow br ON rr.borrowId = br.borrowId "
              + "JOIN user u ON rr.userId = u.userId "
              + "JOIN book b ON br.bookId = b.bookId "
              + "WHERE rr.status = 'PENDING' "
              + "ORDER BY rr.requestDate ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();

                row.put("requestId", rs.getInt("requestId"));
                row.put("borrowId", rs.getInt("borrowId"));
                row.put("userId", rs.getInt("userId"));
                row.put("userName", rs.getString("userName"));
                row.put("bookTitle", rs.getString("bookTitle"));
                row.put("dueDate", rs.getTimestamp("dueDate"));
                row.put("requestDate", rs.getTimestamp("requestDate"));
                row.put("status", rs.getString("status"));

                requests.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return requests;
    }

    // GET A USER'S RENEWAL REQUEST HISTORY
    @Override
    public List<Map<String, Object>> getRenewalRequestsByUser(int userId) {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql =
                "SELECT rr.requestId, rr.borrowId, b.title AS bookTitle, "
              + "rr.requestDate, rr.status, rr.rejectionReason, rr.decidedAt "
              + "FROM renewal_request rr "
              + "JOIN borrow br ON rr.borrowId = br.borrowId "
              + "JOIN book b ON br.bookId = b.bookId "
              + "WHERE rr.userId = ? "
              + "ORDER BY rr.requestDate DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();

                    row.put("requestId", rs.getInt("requestId"));
                    row.put("borrowId", rs.getInt("borrowId"));
                    row.put("bookTitle", rs.getString("bookTitle"));
                    row.put("requestDate", rs.getTimestamp("requestDate"));
                    row.put("status", rs.getString("status"));
                    row.put("rejectionReason", rs.getString("rejectionReason"));
                    row.put("decidedAt", rs.getTimestamp("decidedAt"));

                    requests.add(row);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return requests;
    }

    // APPROVE A RENEWAL REQUEST AND EXTEND THE DUE DATE
    @Override
    public boolean approveRenewalRequest(int requestId, int adminId) {

        String lockRequestSql =
                "SELECT borrowId, userId FROM renewal_request "
              + "WHERE requestId = ? AND status = 'PENDING' FOR UPDATE";

        String lockBorrowSql =
                "SELECT userId, status, dueDate FROM borrow "
              + "WHERE borrowId = ? FOR UPDATE";

        String updateBorrowSql =
                "UPDATE borrow "
              + "SET dueDate = DATE_ADD("
              + "GREATEST(dueDate, CURRENT_TIMESTAMP), INTERVAL 15 DAY), "
              + "status = 'BORROWED' "
              + "WHERE borrowId = ? "
              + "AND status IN ('BORROWED', 'OVERDUE') "
              + "AND dueDate IS NOT NULL";

        String updateRequestSql =
                "UPDATE renewal_request "
              + "SET status = 'APPROVED', decidedAt = CURRENT_TIMESTAMP, "
              + "decidedBy = ?, rejectionReason = NULL "
              + "WHERE requestId = ? AND status = 'PENDING'";

        String closeOtherRequestsSql =
                "UPDATE renewal_request "
              + "SET status = 'REJECTED', decidedAt = CURRENT_TIMESTAMP, "
              + "decidedBy = ?, "
              + "rejectionReason = 'Another renewal request for this "
              + "borrowing was approved.' "
              + "WHERE borrowId = ? AND status = 'PENDING' "
              + "AND requestId <> ?";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int borrowId;
            int requestUserId;

            // LOCK THE PENDING REQUEST
            try (PreparedStatement ps = con.prepareStatement(lockRequestSql)) {
                ps.setInt(1, requestId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    borrowId = rs.getInt("borrowId");
                    requestUserId = rs.getInt("userId");
                }
            }

            // LOCK THE BORROWING AND VERIFY OWNERSHIP AND STATUS
            try (PreparedStatement ps = con.prepareStatement(lockBorrowSql)) {
                ps.setInt(1, borrowId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    int actualUserId = rs.getInt("userId");
                    String status = rs.getString("status");
                    Timestamp dueTimestamp = rs.getTimestamp("dueDate");

                    if (actualUserId != requestUserId
                            || !("BORROWED".equalsIgnoreCase(status)
                                || "OVERDUE".equalsIgnoreCase(status))
                            || dueTimestamp == null) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // EXTEND THE DUE DATE AND RESTORE THE BORROWED STATUS
            try (PreparedStatement ps = con.prepareStatement(updateBorrowSql)) {
                ps.setInt(1, borrowId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            // MARK THE SELECTED REQUEST AS APPROVED
            try (PreparedStatement ps = con.prepareStatement(updateRequestSql)) {
                ps.setInt(1, adminId);
                ps.setInt(2, requestId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }
            }

            // CLOSE OTHER PENDING REQUESTS FOR THIS BORROWING
            try (PreparedStatement ps =
                         con.prepareStatement(closeOtherRequestsSql)) {
                ps.setInt(1, adminId);
                ps.setInt(2, borrowId);
                ps.setInt(3, requestId);
                ps.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            rollbackTransaction(con);
            e.printStackTrace();
            return false;

        } finally {
            closeTransactionConnection(con);
        }
    }

    // REJECT A RENEWAL REQUEST AND SAVE THE REJECTION REASON
    @Override
    public boolean rejectRenewalRequest(
            int requestId, int adminId, String rejectionReason) {

        if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
            return false;
        }

        String sql =
                "UPDATE renewal_request "
              + "SET status = 'REJECTED', decidedAt = CURRENT_TIMESTAMP, "
              + "decidedBy = ?, rejectionReason = ? "
              + "WHERE requestId = ? AND status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, adminId);
            ps.setString(2, rejectionReason.trim());
            ps.setInt(3, requestId);

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // MAP A DATABASE ROW TO THE BORROW MODEL
    private Borrow mapResultSetToBorrow(ResultSet rs)
            throws SQLException {

        Borrow borrow = new Borrow();

        borrow.setBorrowId(rs.getInt("borrowId"));
        borrow.setUserId(rs.getInt("userId"));
        borrow.setBookId(rs.getInt("bookId"));

        Timestamp borrowTimestamp = rs.getTimestamp("borrowDate");
        if (borrowTimestamp != null) {
            borrow.setBorrowDate(borrowTimestamp.toLocalDateTime());
        }

        Timestamp dueTimestamp = rs.getTimestamp("dueDate");
        if (dueTimestamp != null) {
            borrow.setDueDate(dueTimestamp.toLocalDateTime());
        }

        Timestamp returnTimestamp = rs.getTimestamp("returnDate");
        if (returnTimestamp != null) {
            borrow.setReturnDate(returnTimestamp.toLocalDateTime());
        }

        borrow.setStatus(rs.getString("status"));

        return borrow;
    }

    // ROLL BACK A FAILED TRANSACTION
    private void rollbackTransaction(Connection con) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // RESTORE THE CONNECTION AND CLOSE IT
    private void closeTransactionConnection(Connection con) {
        if (con != null) {
            try {
                con.setAutoCommit(true);
                con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}