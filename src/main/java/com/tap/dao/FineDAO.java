package com.tap.dao;

import java.util.List;

import com.tap.model.Fine;

public interface FineDAO {

    // Create a fine for an overdue borrow
    boolean createFine(Fine fine);

    // Get fine by ID
    Fine getFineById(int fineId);
    
    // ADDED: GENERATE OR UPDATE A FINE FOR AN OVERDUE BORROWING
    boolean generateOrUpdateFine(int borrowId);
    
    // Get all fines of a particular user
    List<Fine> getFinesByUser(int userId);

    // Get all pending fines
    List<Fine> getPendingFines();

    // Get all fines - Admin
    List<Fine> getAllFines();

    // Mark a fine as paid
    boolean payFine(int fineId);
}