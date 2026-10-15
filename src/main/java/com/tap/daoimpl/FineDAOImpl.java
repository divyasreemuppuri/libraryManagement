
package com.tap.daoimpl;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.FineDAO;
import com.tap.model.Fine;
import com.tap.utility.DBConnection;

public class FineDAOImpl implements FineDAO {

    @Override
    public boolean createFine(Fine fine) {

        String sql = "INSERT INTO fine "
                   + "(borrowId, userId, daysOverdue, fineAmount, status) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, fine.getBorrowId());
            ps.setInt(2, fine.getUserId());
            ps.setInt(3, fine.getDaysOverdue());

            BigDecimal amount =
                    BigDecimal.valueOf(fine.getDaysOverdue())
                              .multiply(BigDecimal.TEN);

            ps.setBigDecimal(4, amount);
            ps.setString(5, "PENDING");

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // ADDED: GENERATE OR UPDATE A FINE FOR AN OVERDUE BORROWING
    @Override
    public boolean generateOrUpdateFine(int borrowId) {

        String borrowSql = "SELECT userId, dueDate, returnDate, status "
                         + "FROM borrow WHERE borrowId = ?";

        String fineSql = "SELECT fineId, status FROM fine "
                       + "WHERE borrowId = ? FOR UPDATE";

        String insertFineSql = "INSERT INTO fine "
                             + "(borrowId, userId, daysOverdue, fineAmount, status) "
                             + "VALUES (?, ?, ?, ?, 'PENDING')";

        String updateFineSql = "UPDATE fine "
                             + "SET daysOverdue = ?, fineAmount = ? "
                             + "WHERE borrowId = ? AND status = 'PENDING'";

        Connection con = null;

        try {
            con = DBConnection.getConnection();

            // ADDED: USE A TRANSACTION TO KEEP FINE OPERATIONS CONSISTENT
            con.setAutoCommit(false);

            int userId;
            LocalDateTime dueDate;
            LocalDateTime returnDate;
            String borrowStatus;

            // ADDED: READ THE BORROWING DETAILS
            try (PreparedStatement ps = con.prepareStatement(borrowSql)) {

                ps.setInt(1, borrowId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    userId = rs.getInt("userId");

                    Timestamp dueTimestamp = rs.getTimestamp("dueDate");
                    Timestamp returnTimestamp = rs.getTimestamp("returnDate");

                    dueDate = dueTimestamp.toLocalDateTime();

                    returnDate = returnTimestamp == null
                               ? null
                               : returnTimestamp.toLocalDateTime();

                    borrowStatus = rs.getString("status");
                }
            }

            // ADDED: DO NOT GENERATE FINES FOR INVALID OR NOT-YET-OVERDUE BORROWS
            if (returnDate == null
                    && !("BORROWED".equals(borrowStatus)
                      || "OVERDUE".equals(borrowStatus))) {

                con.rollback();
                return false;
            }

            // ADDED: USE RETURN DATE FOR RETURNED BOOKS, OTHERWISE USE CURRENT TIME
            LocalDateTime referenceDate = (returnDate != null)
                                        ? returnDate
                                        : LocalDateTime.now();

            // ADDED: CALCULATE OVERDUE DAYS USING CALENDAR DATES
            long overdueDays = ChronoUnit.DAYS.between(
                    dueDate.toLocalDate(),
                    referenceDate.toLocalDate()
            );

            // ADDED: NO FINE IS REQUIRED WHEN THE BOOK IS NOT OVERDUE
            if (overdueDays <= 0) {
                con.rollback();
                return false;
            }

            // ADDED: CALCULATE FINE AT ₹10 PER OVERDUE DAY
            int days = Math.toIntExact(overdueDays);

            BigDecimal amount = BigDecimal.valueOf(days)
                                          .multiply(BigDecimal.TEN);

            boolean fineExists = false;
            String existingFineStatus = null;

            // ADDED: CHECK WHETHER A FINE ALREADY EXISTS FOR THIS BORROW
            try (PreparedStatement ps = con.prepareStatement(fineSql)) {

                ps.setInt(1, borrowId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        fineExists = true;
                        existingFineStatus = rs.getString("status");
                    }
                }
            }

            // ADDED: NEVER MODIFY A FINE THAT HAS ALREADY BEEN PAID
            if (fineExists && "PAID".equals(existingFineStatus)) {
                con.rollback();
                return false;
            }

            if (fineExists) {

                // ADDED: UPDATE THE EXISTING PENDING FINE INSTEAD OF DUPLICATING IT
                try (PreparedStatement ps = con.prepareStatement(updateFineSql)) {

                    ps.setInt(1, days);
                    ps.setBigDecimal(2, amount);
                    ps.setInt(3, borrowId);

                    int updated = ps.executeUpdate();

                    con.commit();
                    return updated > 0;
                }

            } else {

                // ADDED: CREATE A FINE ONLY WHEN ONE DOES NOT ALREADY EXIST
                try (PreparedStatement ps = con.prepareStatement(insertFineSql)) {

                    ps.setInt(1, borrowId);
                    ps.setInt(2, userId);
                    ps.setInt(3, days);
                    ps.setBigDecimal(4, amount);

                    int inserted = ps.executeUpdate();

                    con.commit();
                    return inserted > 0;
                }
            }

        } catch (SQLException | ArithmeticException e) {

            // ADDED: ROLL BACK IF FINE GENERATION FAILS
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackException) {
                    rollbackException.printStackTrace();
                }
            }

            e.printStackTrace();

        } finally {

            // ADDED: CLOSE THE CONNECTION SAFELY
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return false;
    }

    @Override
    public Fine getFineById(int fineId) {

        String sql = "SELECT * FROM fine WHERE fineId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, fineId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapResultSetToFine(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Fine> getFinesByUser(int userId) {

        List<Fine> fines = new ArrayList<>();

        String sql = "SELECT * FROM fine "
                   + "WHERE userId = ? "
                   + "ORDER BY createdAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    fines.add(mapResultSetToFine(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return fines;
    }

    @Override
    public List<Fine> getPendingFines() {

        List<Fine> fines = new ArrayList<>();

        String sql = "SELECT * FROM fine "
                   + "WHERE status = 'PENDING' "
                   + "ORDER BY createdAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                fines.add(mapResultSetToFine(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return fines;
    }

    @Override
    public List<Fine> getAllFines() {

        List<Fine> fines = new ArrayList<>();

        String sql = "SELECT * FROM fine ORDER BY createdAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                fines.add(mapResultSetToFine(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return fines;
    }

    @Override
    public boolean payFine(int fineId) {

        String sql = "UPDATE fine "
                   + "SET status = 'PAID', paidAt = CURRENT_TIMESTAMP "
                   + "WHERE fineId = ? AND status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, fineId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private Fine mapResultSetToFine(ResultSet rs) throws SQLException {

        Fine fine = new Fine();

        fine.setFineId(rs.getInt("fineId"));
        fine.setBorrowId(rs.getInt("borrowId"));
        fine.setUserId(rs.getInt("userId"));
        fine.setDaysOverdue(rs.getInt("daysOverdue"));
        fine.setFineAmount(rs.getBigDecimal("fineAmount"));
        fine.setStatus(rs.getString("status"));

        Timestamp createdTimestamp = rs.getTimestamp("createdAt");

        if (createdTimestamp != null) {
            fine.setCreatedAt(createdTimestamp.toLocalDateTime());
        }

        Timestamp paidTimestamp = rs.getTimestamp("paidAt");

        if (paidTimestamp != null) {
            fine.setPaidAt(paidTimestamp.toLocalDateTime());
        }

        return fine;
    }
}
