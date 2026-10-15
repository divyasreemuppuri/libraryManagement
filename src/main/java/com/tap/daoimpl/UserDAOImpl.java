
package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.dao.UserDAO;
import com.tap.model.User;
import com.tap.utility.DBConnection;

public class UserDAOImpl implements UserDAO {

    // REGISTER A NEW USER WITH A HASHED PASSWORD
    @Override
    public boolean registerUser(User user) {

        String sql = "INSERT INTO user "
                + "(name, email, password, phone, address, role, status) "
                + "VALUES (?, ?, ?, ?, ?, 'USER', 'PENDING')";

        String hashedPassword = BCrypt.hashpw(
                user.getPassword(),
                BCrypt.gensalt(12)
        );

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, hashedPassword);
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        user.setUserId(keys.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // GET A USER BY EMAIL
    @Override
    public User getUserByEmail(String email) {

        String sql = "SELECT * FROM user WHERE email = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // AUTHENTICATE APPROVED USERS
    @Override
    public User login(String email, String password) {

        User user = getUserByEmail(email);

        if (user == null) {
            return null;
        }

        if (!"APPROVED".equalsIgnoreCase(user.getStatus())) {
            return null;
        }

        String storedPassword = user.getPassword();

        if (storedPassword == null || password == null) {
            return null;
        }

        boolean passwordMatches;

        if (isBCryptHash(storedPassword)) {
            passwordMatches = BCrypt.checkpw(password, storedPassword);
        } else {
            // VERIFY LEGACY PLAINTEXT PASSWORDS AND UPGRADE THEM
            passwordMatches = storedPassword.equals(password);

            if (passwordMatches) {
                upgradeLegacyPassword(user.getUserId(), password);
            }
        }

        return passwordMatches ? user : null;
    }

    // AUTHENTICATE A USER TO DETERMINE ACCOUNT STATUS
    @Override
    public User authenticateForAccountStatus(String email, String password) {

        User user = getUserByEmail(email);

        if (user == null) {
            return null;
        }

        String storedPassword = user.getPassword();

        if (storedPassword == null || password == null) {
            return null;
        }

        boolean passwordMatches;

        if (isBCryptHash(storedPassword)) {
            passwordMatches = BCrypt.checkpw(password, storedPassword);
        } else {
            // VERIFY LEGACY PLAINTEXT PASSWORDS AND UPGRADE THEM
            passwordMatches = storedPassword.equals(password);

            if (passwordMatches) {
                upgradeLegacyPassword(user.getUserId(), password);
            }
        }

        return passwordMatches ? user : null;
    }


    // CHECK WHETHER A PASSWORD IS A BCRYPT HASH
    private boolean isBCryptHash(String password) {

        return password != null
                && (password.startsWith("$2a$")
                || password.startsWith("$2b$")
                || password.startsWith("$2y$"));
    }

    // UPGRADE A LEGACY PASSWORD TO BCRYPT
    private void upgradeLegacyPassword(int userId, String password) {

        String sql = "UPDATE user SET password = ? WHERE userId = ?";

        String hashedPassword = BCrypt.hashpw(
                password,
                BCrypt.gensalt(12)
        );

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // GET USERS WAITING FOR ADMIN APPROVAL
    @Override
    public List<User> getPendingUsers() {

        List<User> users = new ArrayList<>();

        String sql = "SELECT * FROM user "
                + "WHERE status = 'PENDING' "
                + "ORDER BY registeredAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    // APPROVE A USER
    @Override
    public boolean approveUser(int userId, int approvedBy) {

        String sql = "UPDATE user "
                + "SET status = 'APPROVED', "
                + "approvedAt = CURRENT_TIMESTAMP, "
                + "approvedBy = ? "
                + "WHERE userId = ? AND role = 'USER' "
                + "AND status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, approvedBy);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // REJECT A PENDING USER
    @Override
    public boolean rejectUser(int userId) {

        String sql = "UPDATE user "
                + "SET status = 'REJECTED' "
                + "WHERE userId = ? AND role = 'USER' "
                + "AND status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // GET ALL REGISTERED USERS WITHOUT RETRIEVING PASSWORDS
    @Override
    public List<User> getAllUsers() {

        List<User> users = new ArrayList<>();

        String sql = "SELECT userId, name, email, phone, address, "
                + "role, status, registeredAt, approvedAt, approvedBy "
                + "FROM user ORDER BY registeredAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                User user = new User();

                user.setUserId(rs.getInt("userId"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setAddress(rs.getString("address"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));

                Timestamp registeredAt =
                        rs.getTimestamp("registeredAt");

                if (registeredAt != null) {
                    user.setRegisteredAt(
                            registeredAt.toLocalDateTime()
                    );
                }

                Timestamp approvedAt =
                        rs.getTimestamp("approvedAt");

                if (approvedAt != null) {
                    user.setApprovedAt(
                            approvedAt.toLocalDateTime()
                    );
                }

                int approvedBy = rs.getInt("approvedBy");

                if (!rs.wasNull()) {
                    user.setApprovedBy(approvedBy);
                }

                users.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    // DELETE A NORMAL USER ACCOUNT
    @Override
    public boolean deleteUser(int userId) {

        String sql = "DELETE FROM user "
                + "WHERE userId = ? AND role = 'USER'";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, userId);

                int rows = ps.executeUpdate();

                if (rows > 0) {
                    con.commit();
                    return true;
                }

                con.rollback();
                return false;
            }

        } catch (SQLException e) {
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackException) {
                    rollbackException.printStackTrace();
                }
            }

            return false;

        } finally {
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

    // MAP A RESULT SET CONTAINING ALL USER COLUMNS TO THE USER MODEL
    private User mapResultSetToUser(ResultSet rs)
            throws SQLException {

        User user = new User();

        user.setUserId(rs.getInt("userId"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));

        Timestamp registeredAt =
                rs.getTimestamp("registeredAt");

        if (registeredAt != null) {
            user.setRegisteredAt(
                    registeredAt.toLocalDateTime()
            );
        }

        Timestamp approvedAt =
                rs.getTimestamp("approvedAt");

        if (approvedAt != null) {
            user.setApprovedAt(
                    approvedAt.toLocalDateTime()
            );
        }

        int approvedBy = rs.getInt("approvedBy");

        if (!rs.wasNull()) {
            user.setApprovedBy(approvedBy);
        }

        return user;
    }

    // UPDATE A USER'S PERSONAL PROFILE INFORMATION
    @Override
    public boolean updateProfile(User user) {

        String sql = "UPDATE user "
                + "SET name = ?, email = ?, phone = ?, address = ? "
                + "WHERE userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getAddress());
            ps.setInt(5, user.getUserId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            // HANDLE DUPLICATE EMAIL OR PHONE CONSTRAINT VIOLATIONS
            if (e.getErrorCode() == 1062) {
                return false;
            }

            e.printStackTrace();
            return false;
        }
    }

}
