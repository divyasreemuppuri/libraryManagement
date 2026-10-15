
package com.tap.dao;

import java.util.List;
import java.util.Map;

import com.tap.model.Borrow;

public interface BorrowDAO {

    // EXISTING BORROWING METHODS
    boolean borrowBook(Borrow borrow);

    Borrow getBorrowById(int borrowId);

    List<Borrow> getActiveBorrowsByUser(int userId);

    List<Borrow> getBorrowHistoryByUser(int userId);

    boolean renewBook(int borrowId, int userId);

    boolean returnBook(int borrowId);

    List<Borrow> getAllBorrows();

    List<Borrow> getOverdueBorrows();

    // BORROW REQUEST METHODS
    boolean submitBorrowRequest(int userId, int bookId);

    List<Map<String, Object>> getPendingBorrowRequests();
    

    List<Map<String, Object>> getRejectedBorrowRequests();


    List<Map<String, Object>> getBorrowRequestsByUser(int userId);

    boolean approveBorrowRequest(int requestId, int adminId);

    boolean rejectBorrowRequest(
        int requestId,
        int adminId,
        String rejectionReason
    );

    // RENEWAL REQUEST METHODS
    boolean submitRenewalRequest(int borrowId, int userId);

    List<Map<String, Object>> getPendingRenewalRequests();

    List<Map<String, Object>> getRenewalRequestsByUser(int userId);

    boolean approveRenewalRequest(int requestId, int adminId);

    boolean rejectRenewalRequest(
        int requestId,
        int adminId,
        String rejectionReason
    );
}
