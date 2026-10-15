
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    List<Map<String, Object>> pendingRenewalRequests =
        (List<Map<String, Object>>) request.getAttribute("pendingRenewalRequests");

    String renewalResult = request.getParameter("renewalResult");
%>

<style>
    .renewal-page {
        padding: 10px 0;
    }

    .renewal-description {
        color: #94a3b8;
        margin-bottom: 24px;
    }

    .renewal-alert {
        padding: 14px 18px;
        border-radius: 10px;
        margin-bottom: 20px;
        font-size: 14px;
    }

    .renewal-alert.success {
        background: rgba(34, 197, 94, 0.12);
        color: #4ade80;
        border: 1px solid rgba(34, 197, 94, 0.25);
    }

    .renewal-alert.error {
        background: rgba(239, 68, 68, 0.12);
        color: #f87171;
        border: 1px solid rgba(239, 68, 68, 0.25);
    }

    .renewal-table-wrapper {
        width: 100%;
        overflow-x: auto;
        border-radius: 12px;
    }

    .renewal-table {
        width: 100%;
        min-width: 800px;
        border-collapse: collapse;
    }

    .renewal-table th,
    .renewal-table td {
        padding: 15px;
        text-align: left;
        border-bottom: 1px solid rgba(148, 163, 184, 0.15);
    }

    .renewal-table th {
        color: #cbd5e1;
        font-size: 13px;
        font-weight: 600;
        background: rgba(148, 163, 184, 0.08);
    }

    .renewal-table td {
        color: #e2e8f0;
        font-size: 14px;
    }

    .renewal-actions {
        display: flex;
        flex-direction: column;
        gap: 10px;
        min-width: 160px;
    }

    .renewal-action-form {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .renewal-reason {
        width: 100%;
        padding: 9px;
        border-radius: 7px;
        border: 1px solid rgba(148, 163, 184, 0.3);
        background: rgba(15, 23, 42, 0.7);
        color: #f8fafc;
        resize: vertical;
        box-sizing: border-box;
    }

    .renewal-btn {
        border: none;
        border-radius: 7px;
        padding: 9px 12px;
        color: #fff;
        font-weight: 600;
        cursor: pointer;
    }

    .renewal-btn.approve {
        background: #16a34a;
    }

    .renewal-btn.reject {
        background: #dc2626;
    }

    .renewal-btn:hover {
        opacity: 0.85;
    }

    .renewal-empty {
        padding: 35px 20px;
        text-align: center;
        color: #94a3b8;
        border: 1px dashed rgba(148, 163, 184, 0.3);
        border-radius: 12px;
    }
</style>

<div class="renewal-page">

    <h2>Pending Renewal Requests</h2>

    <p class="renewal-description">
        Review requests to extend the borrowing period of issued books.
    </p>

    <% if ("approved".equals(renewalResult)) { %>
        <div class="renewal-alert success">
            Renewal request approved successfully.
        </div>
    <% } else if ("rejected".equals(renewalResult)) { %>
        <div class="renewal-alert success">
            Renewal request rejected successfully.
        </div>
    <% } else if ("reasonRequired".equals(renewalResult)) { %>
        <div class="renewal-alert error">
            Please provide a reason before rejecting the request.
        </div>
    <% } else if ("unavailable".equals(renewalResult)) { %>
        <div class="renewal-alert error">
            The renewal request could not be processed. The request may no longer be pending.
        </div>
    <% } else if ("invalid".equals(renewalResult)) { %>
        <div class="renewal-alert error">
            Invalid request or action. Please try again.
        </div>
    <% } %>

    <% if (pendingRenewalRequests == null || pendingRenewalRequests.isEmpty()) { %>

        <div class="renewal-empty">
            <h3>No Pending Renewal Requests</h3>
            <p>New renewal requests will appear here when users request extensions.</p>
        </div>

    <% } else { %>

        <div class="renewal-table-wrapper">
            <table class="renewal-table">
                <thead>
                    <tr>
                        <th>Request ID</th>
                        <th>User</th>
                        <th>Book</th>
                        <th>Borrow ID</th>
                        <th>Current Due Date</th>
                        <th>Request Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>
                    <% for (Map<String, Object> renewalRequest : pendingRenewalRequests) { %>

                        <tr>
                            <td>
                                <%= renewalRequest.get("requestId") %>
                            </td>

                            <td>
                                <%= renewalRequest.get("userName") %>
                                <br>
                                <small>
                                    User ID:
                                    <%= renewalRequest.get("userId") %>
                                </small>
                            </td>

                            <td>
                                <%= renewalRequest.get("bookTitle") %>
                            </td>

                            <td>
                                <%= renewalRequest.get("borrowId") %>
                            </td>

                            <td>
                                <%= renewalRequest.get("dueDate") %>
                            </td>

                            <td>
                                <%= renewalRequest.get("requestDate") %>
                            </td>

                            <td>
                                <div class="renewal-actions">

                                    <form
                                        class="renewal-action-form"
                                        action="<%= contextPath %>/admin/renewal-request-action"
                                        method="post"
                                        onsubmit="return confirm('Approve this renewal request?');">

                                        <input
                                            type="hidden"
                                            name="requestId"
                                            value="<%= renewalRequest.get("requestId") %>">

                                        <input
                                            type="hidden"
                                            name="action"
                                            value="approve">

                                        <button
                                            type="submit"
                                            class="renewal-btn approve">
                                            Approve
                                        </button>
                                    </form>

                                    <form
                                        class="renewal-action-form"
                                        action="<%= contextPath %>/admin/renewal-request-action"
                                        method="post"
                                        onsubmit="return confirm('Reject this renewal request?');">

                                        <input
                                            type="hidden"
                                            name="requestId"
                                            value="<%= renewalRequest.get("requestId") %>">

                                        <input
                                            type="hidden"
                                            name="action"
                                            value="reject">

                                        <textarea
                                            class="renewal-reason"
                                            name="rejectionReason"
                                            placeholder="Reason for rejection"
                                            maxlength="500"
                                            rows="2"
                                            required></textarea>

                                        <button
                                            type="submit"
                                            class="renewal-btn reject">
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
