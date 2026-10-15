
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String contextPath = request.getContextPath();

    // ADDED: READ LOGIN MESSAGES FROM THE CONTROLLER
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Login | Library Management System</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/landing.css">

    <link rel="stylesheet"
          href="<%= contextPath %>/css/login.css">
</head>

<body data-context-path="<%= contextPath %>">

    <%@ include file="components/navbar.jsp" %>

    <main class="login-page">
        <section class="login-card">

            <h1>Welcome Back</h1>

            <p class="login-subtitle">
                Sign in to access your library account.
            </p>

            <% if (errorMessage != null) { %>
                <div class="login-message login-error" role="alert">
                    <%= errorMessage %>
                </div>
            <% } %>

            <% if (successMessage != null) { %>
                <div class="login-message login-success" role="status">
                    <%= successMessage %>
                </div>
            <% } %>

            <!-- ADDED: LOGIN FORM SUBMITS TO THE LOGIN CONTROLLER -->
            <form class="login-form"
                  action="<%= contextPath %>/login"
                  method="post">

                <div>
                    <label for="email">Email Address</label>
                    <input type="email"
                           id="email"
                           name="email"
                           required
                           maxlength="150"
                           autocomplete="username"
                           placeholder="Enter your email">
                </div>

                <div>
                    <label for="password">Password</label>
                    <input type="password"
                           id="password"
                           name="password"
                           required
                           autocomplete="current-password"
                           placeholder="Enter your password">
                </div>

                <button type="submit" class="login-button">
                    Login
                </button>

            </form>

            <p class="login-register">
                Don't have an account?
                <a href="<%= contextPath %>/register.jsp">
                    Register here
                </a>
            </p>

        </section>
    </main>

    <%@ include file="components/footer.jsp" %>

</body>
</html>
