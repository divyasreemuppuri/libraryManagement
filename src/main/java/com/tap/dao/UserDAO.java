
package com.tap.dao;

import java.util.List;

import com.tap.model.User;

public interface UserDAO {

    // REGISTER A NEW USER
    boolean registerUser(User user);

    // FIND USER BY EMAIL
    User getUserByEmail(String email);

    // LOGIN - ONLY APPROVED USERS SHOULD BE RETURNED
    User login(String email, String password);

    // VERIFY CREDENTIALS REGARDLESS OF ACCOUNT STATUS
    User authenticateForAccountStatus(String email, String password);

    // GET ALL USERS WAITING FOR ADMIN APPROVAL
    List<User> getPendingUsers();

    // APPROVE A PENDING USER
    boolean approveUser(int userId, int approvedBy);

    // REJECT A PENDING USER
    boolean rejectUser(int userId);

    // GET ALL REGISTERED USERS
    List<User> getAllUsers();

    // DELETE A USER BY ID
    boolean deleteUser(int userId);

    // UPDATE THE LOGGED-IN USER'S PERSONAL PROFILE INFORMATION
    boolean updateProfile(User user);
}
