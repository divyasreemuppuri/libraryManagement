
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    List<Map<String, Object>> pendingBorrowRequests =
        (List<Map<String, Object>>) request.getAttribute("pendingBorrowRequests");

    String requestResult = request.getParameter("requestResult");
%>

<style>
    .request-page {
        padding: 10px 0;
    }

    .request-page h2 {
        margin-bottom: 8px;
    }

    .request-description {
        color: #94a3b8;
        margin-bottom: 24px;
    }

    .request-alert {
        padding: 14px 18px;
        border-radius: 10px;
        margin-bottom: 20px;
        font-size: 14px;
    }

    .request-alert.success {
        background: rgba(34, 197, 94, 0.12);
        color: #4ade80;
        border: 1px solid rgba(34, 197, 94, 0.25);
    }

    .request-alert.error {
        background: rgba(239, 68, 68, 0.12);
        color: #f87171;
        border: 1px solid rgba(239, 68, 68, 0.25);
    }

    .request-table-wrapper {
        width: 100%;
        overflow-x: auto;
        border-radius: 12px;
    }

    .request-table {
        width: 100%;
        border-collapse: collapse;
        min-width: 750px;
    }

    .request-table th,
    .request-table td {
        padding: 15px;
        text-align: left;
        border-bottom: 1px solid rgba(148, 163, 184, 0.15);
    }

    .request-table th {
        color: #cbd5e1;
        font-size: 13px;
        font-weight: 600;
        background: rgba(148, 163, 184, 0.08);
    }

    .request-table td {
        color: #e2e8f0;
        font-size: 14px;
    }

    .request-actions {
        display: flex;
        flex-direction: column;
        gap: 10px;
        min-width: 160px;
    }

    .request-action-form {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .request-reason {
        width: 100%;
        padding: 9px;
        border-radius: 7px;
        border: 1px solid rgba(148, 163, 184, 0.3);
        background: rgba(15, 23, 42, 0.7);
        color: #f8fafc;
        resize: vertical;
        box-sizing: border-box;
    }

    .request-btn {
        border: none;
        border-radius: 7px;
        padding: 9px 12px;
        color: #fff;
        font-weight: 600;
        cursor: pointer;
    }

    .request-btn.approve {
        background: #16a34a;
    }

    .request-btn.reject {
        background: #dc2626;
    }

    .request-btn:hover {
        opacity: 0.85;
    }

    .request-empty {
        padding: 35px 20px;
        text-align: center;
        color: #94a3b8;
        border: 1px dashed rgba(148, 163, 184, 0.3);
        border-radius: 12px;
    }
</style>

<div class="request-page">

    <h2>Pending Borrow Requests</h2>

    <p class="request-description">
        Review book borrowing requests and approve or reject them.
    </p>

    <% if ("approved".equals(requestResult)) { %>
        <div class="request-alert success">
            Borrow request approved successfully.
        </div>
    <% } else if ("rejected".equals(requestResult)) { %>
        <div class="request-alert success">
            Borrow request rejected successfully.
        </div>
    <% } else if ("unavailable".equals(requestResult)) { %>
        <div class="request-alert error">
            The book is no longer available, or the request could not be processed.
        </div>
    <% } else if ("reasonRequired".equals(requestResult)) { %>
        <div class="request-alert error">
            Please provide a reason before rejecting the request.
        </div>
    <% } else if ("invalid".equals(requestResult)) { %>
        <div class="request-alert error">
            Invalid request or action. Please try again.
        </div>
    <% } %>

    <% if (pendingBorrowRequests == null || pendingBorrowRequests.isEmpty()) { %>

        <div class="request-empty">
            <h3>No Pending Borrow Requests</h3>
            <p>New requests will appear here when users request books.</p>
        </div>

    <% } else { %>

        <div class="request-table-wrapper">
            <table class="request-table">
                <thead>
                    <tr>
                        <th>Request ID</th>
                        <th>User</th>
                        <th>Book</th>
                        <th>Request Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>
                    <% for (Map<String, Object> borrowRequest : pendingBorrowRequests) { %>

                        <tr>
                            <td>
                                <%= borrowRequest.get("requestId") %>
                            </td>

                            <td>
                                <%= borrowRequest.get("userName") %>
                                <br>
                                <small>
                                    User ID:
                                    <%= borrowRequest.get("userId") %>
                                </small>
                            </td>

                            <td>
                                <%= borrowRequest.get("bookTitle") %>
                                <br>
                                <small>
                                    Book ID:
                                    <%= borrowRequest.get("bookId") %>
                                </small>
                            </td>

                            <td>
                                <%= borrowRequest.get("requestDate") %>
                            </td>

                            <td>
                                <div class="request-actions">

                                    <form
                                        class="request-action-form"
                                        action="<%= contextPath %>/admin/borrow-request-action"
                                        method="post"
                                        onsubmit="return confirm('Approve this borrow request?');">

                                        <input
                                            type="hidden"
                                            name="requestId"
                                            value="<%= borrowRequest.get("requestId") %>">

                                        <input
                                            type="hidden"
                                            name="action"
                                            value="approve">

                                        <button
                                            type="submit"
                                            class="request-btn approve">
                                            Approve
                                        </button>
                                    </form>

                                    <form
                                        class="request-action-form"
                                        action="<%= contextPath %>/admin/borrow-request-action"
                                        method="post"
                                        onsubmit="return confirm('Reject this borrow request?');">

                                        <input
                                            type="hidden"
                                            name="requestId"
                                            value="<%= borrowRequest.get("requestId") %>">

                                        <input
                                            type="hidden"
                                            name="action"
                                            value="reject">

                                        <textarea
                                            class="request-reason"
                                            name="rejectionReason"
                                            placeholder="Reason for rejection"
                                            maxlength="500"
                                            rows="2"
                                            required></textarea>

                                        <button
                                            type="submit"
                                            class="request-btn reject">
                                            Reject
                                        </button>
                                    </form>

                                </div>
                            </td>
                        </tr>

                    <% } %>
                </tbody>
            </table>
        </div>

    <% } %>

</div>
