package com.tap.model;

import java.time.LocalDateTime;

public class User {

    private int userId;
    private String name;
    private String email;
    private String password;
    private String phone;
    private String address;
    private String role;
    private String status;
    private LocalDateTime registeredAt;
    private LocalDateTime approvedAt;
    private int approvedBy;

    public User() {
    }

    public User(int userId, String name, String email, String password,
                String phone, String address, String role, String status,
                LocalDateTime registeredAt, LocalDateTime approvedAt,
                int approvedBy) {

        this.userId = userId;
        this.name = name;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.address = address;
        this.role = role;
        this.status = status;
        this.registeredAt = registeredAt;
        this.approvedAt = approvedAt;
        this.approvedBy = approvedBy;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getRegisteredAt() {
        return registeredAt;
    }

    public void setRegisteredAt(LocalDateTime registeredAt) {
        this.registeredAt = registeredAt;
    }

    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }

    public int getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(int approvedBy) {
        this.approvedBy = approvedBy;
    }

    @Override
    public String toString() {
        return "User [userId=" + userId
                + ", name=" + name
                + ", email=" + email
                + ", phone=" + phone
                + ", address=" + address
                + ", role=" + role
                + ", status=" + status
                + ", registeredAt=" + registeredAt
                + ", approvedAt=" + approvedAt
                + ", approvedBy=" + approvedBy
                + "]";
    }
}