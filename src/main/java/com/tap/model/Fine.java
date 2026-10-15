package com.tap.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Fine {

    private int fineId;
    private int borrowId;
    private int userId;
    private int daysOverdue;
    private BigDecimal fineAmount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime paidAt;

    // No-argument constructor
    public Fine() {
    }

    // Parameterized constructor
    public Fine(int fineId, int borrowId, int userId, int daysOverdue,
                BigDecimal fineAmount, String status,
                LocalDateTime createdAt, LocalDateTime paidAt) {

        this.fineId = fineId;
        this.borrowId = borrowId;
        this.userId = userId;
        this.daysOverdue = daysOverdue;
        this.fineAmount = fineAmount;
        this.status = status;
        this.createdAt = createdAt;
        this.paidAt = paidAt;
    }

    public int getFineId() {
        return fineId;
    }

    public void setFineId(int fineId) {
        this.fineId = fineId;
    }

    public int getBorrowId() {
        return borrowId;
    }

    public void setBorrowId(int borrowId) {
        this.borrowId = borrowId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getDaysOverdue() {
        return daysOverdue;
    }

    public void setDaysOverdue(int daysOverdue) {
        this.daysOverdue = daysOverdue;
    }

    public BigDecimal getFineAmount() {
        return fineAmount;
    }

    public void setFineAmount(BigDecimal fineAmount) {
        this.fineAmount = fineAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }

    @Override
    public String toString() {
        return "Fine [fineId=" + fineId
                + ", borrowId=" + borrowId
                + ", userId=" + userId
                + ", daysOverdue=" + daysOverdue
                + ", fineAmount=" + fineAmount
                + ", status=" + status
                + ", createdAt=" + createdAt
                + ", paidAt=" + paidAt
                + "]";
    }
}