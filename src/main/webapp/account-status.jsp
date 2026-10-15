
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // READ ACCOUNT STATUS AND MESSAGE
    String accountStatus = (String) request.getAttribute("accountStatus");
    String accountStatusMessage = (String) request.getAttribute("accountStatusMessage");

    // VALIDATE ACCOUNT STATUS
    boolean isPending = "PENDING".equalsIgnoreCase(accountStatus);
    boolean isRejected = "REJECTED".equalsIgnoreCase(accountStatus);

    // SET STATUS-SPECIFIC CONTENT
    String heading = isPending
        ? "Your Account Is Awaiting Approval"
        : "Account Registration Not Approved";

    String description = accountStatusMessage != null
        ? accountStatusMessage
        : "Your account status could not be determined. Please return to the login page.";

    String statusLabel = isPending ? "PENDING" : "REJECTED";
    String icon = isPending ? "fa-clock" : "fa-circle-xmark";

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Account Status | Library Management System</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #17345f;
            background: linear-gradient(135deg, #f4f8ff, #edf4ff);
            display: flex;
            flex-direction: column;
        }

        .status-navbar {
            min-height: 76px;
            padding: 16px 5%;
            background: #244777;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            font-size: clamp(18px, 2.3vw, 28px);
            font-weight: 700;
        }

        .brand i {
            font-size: 36px;
            color: #dbeafe;
        }

        .navbar-tagline {
            font-size: 14px;
            text-align: right;
            color: #e5edff;
        }

        .status-main {
            width: 100%;
            max-width: 850px;
            margin: auto;
            padding: 60px 24px;
            display: flex;
            justify-content: center;
            flex: 1;
        }

        .status-card {
            width: 100%;
            max-width: 620px;
            padding: 42px 38px;
            background: rgba(255, 255, 255, 0.94);
            border: 1px solid #d9e6fa;
            border-radius: 22px;
            box-shadow: 0 18px 55px rgba(32, 69, 120, 0.10);
            text-align: center;
        }

        .status-illustration {
            width: 100%;
            max-width: 270px;
            height: 180px;
            margin: 0 auto 26px;
            border-radius: 18px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 105px;
        }

        .pending-illustration {
            background: linear-gradient(135deg, #e7efff, #d6e5ff);
            color: #4775ce;
        }

        .rejected-illustration {
            background: linear-gradient(135deg, #fff0f0, #ffe0e4);
            color: #dc4654;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 10px 20px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 0.7px;
            margin-bottom: 22px;
        }

        .pending-badge {
            background: #fff0c5;
            color: #a65b00;
        }

        .rejected-badge {
            background: #ffe1e4;
            color: #bd2437;
        }

        .status-card h1 {
            font-size: clamp(25px, 4vw, 32px);
            line-height: 1.3;
            margin-bottom: 18px;
            color: #153665;
        }

        .status-description {
            max-width: 480px;
            margin: 0 auto;
            color: #536b8e;
            font-size: 16px;
            line-height: 1.8;
            overflow-wrap: anywhere;
        }

        .status-note {
            margin-top: 22px;
            padding: 14px;
            border-radius: 12px;
            background: #f3f7fd;
            color: #526989;
            font-size: 14px;
            line-height: 1.6;
        }

        .login-button {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            min-width: 220px;
            margin-top: 30px;
            padding: 15px 25px;
            background: #2c5da1;
            color: #ffffff;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s ease, transform 0.2s ease;
        }

        .login-button:hover {
            background: #1d467f;
            transform: translateY(-2px);
        }

        .status-footer {
            padding: 22px 15px;
            border-top: 1px solid #d8e4f5;
            text-align: center;
            color: #637795;
            font-size: 13px;
        }

        @media (max-width: 600px) {
            .status-navbar {
                padding: 16px 20px;
            }

            .navbar-tagline {
                display: none;
            }

            .status-main {
                padding: 32px 16px;
            }

            .status-card {
                padding: 30px 20px;
            }

            .status-illustration {
                height: 145px;
                font-size: 80px;
            }

            .login-button {
                width: 100%;
            }
        }
    </style>
</head>

<body>

    <header class="status-navbar">
        <div class="brand">
            <i class="fa-solid fa-book-open"></i>
            <span>Library Management System</span>
        </div>

        <div class="navbar-tagline">
            Books &nbsp; • &nbsp; Knowledge &nbsp; • &nbsp; Better Tomorrow
        </div>
    </header>

    <main class="status-main">

        <section class="status-card">

            <% if (isPending) { %>

                <div class="status-illustration pending-illustration"
                     aria-hidden="true">
                    <i class="fa-solid fa-user-clock"></i>
                </div>

                <span class="status-badge pending-badge">
                    <i class="fa-regular fa-clock"></i>
                    PENDING APPROVAL
                </span>

            <% } else if (isRejected) { %>

                <div class="status-illustration rejected-illustration"
                     aria-hidden="true">
                    <i class="fa-solid fa-file-circle-xmark"></i>
                </div>

                <span class="status-badge rejected-badge">
                    <i class="fa-solid fa-circle-xmark"></i>
                    REJECTED
                </span>

            <% } else { %>

                <div class="status-illustration pending-illustration"
                     aria-hidden="true">
                    <i class="fa-solid fa-circle-info"></i>
                </div>

                <span class="status-badge pending-badge">
                    ACCOUNT STATUS
                </span>

            <% } %>

            <h1>
                <%= isPending || isRejected
                    ? heading
                    : "Unable to Determine Account Status" %>
            </h1>

            <p class="status-description">
                <%= description
                    .replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;") %>
            </p>

            <% if (isPending) { %>

                <div class="status-note">
                    <i class="fa-solid fa-circle-info"></i>
                    Your account will become accessible after the administrator
                    approves your registration. You can return to the login
                    page to check again later.
                </div>

            <% } else if (isRejected) { %>

                <div class="status-note">
                    <i class="fa-solid fa-envelope"></i>
                    If you believe this decision was made in error, please
                    contact your library administrator.
                </div>

            <% } %>

            <a class="login-button" href="<%= contextPath %>/login">
                <i class="fa-solid fa-arrow-left"></i>
                Back to Login
            </a>

        </section>

    </main>

    <footer class="status-footer">
        &copy; <%= java.time.Year.now().getValue() %>
        Library Management System. All rights reserved.
    </footer>

</body>
</html>
