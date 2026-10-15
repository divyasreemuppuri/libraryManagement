
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String contextPath = request.getContextPath();

    // ADDED: READ THE MESSAGE SENT BY THE REGISTRATION CONTROLLER
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Register | Library Management System</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/landing.css">
    <link rel="stylesheet"
          href="<%= contextPath %>/css/register.css">

    
</head>

<body data-context-path="<%= contextPath %>">

    <%@ include file="components/navbar.jsp" %>

    <main class="register-page">
        <section class="register-card">

            <h1>Create Your Account</h1>

            <p class="register-subtitle">
                Register to explore and borrow books from our library.
            </p>

            <% if (errorMessage != null) { %>
                <div class="register-message register-error" role="alert">
                    <%= errorMessage %>
                </div>
            <% } %>

            <% if (successMessage != null) { %>
                <div class="register-message register-success" role="status">
                    <%= successMessage %>
                </div>
            <% } %>

            <!-- ADDED: SEND REGISTRATION DATA TO THE REGISTER CONTROLLER -->
            <form class="register-form"
                  action="<%= contextPath %>/register"
                  method="post">

                <div>
                    <label for="name">Full Name</label>
                    <input type="text"
                           id="name"
                           name="name"
                           required
                           maxlength="100"
                           autocomplete="name"
                           placeholder="Enter your full name">
                </div>

                <div>
                    <label for="email">Email Address</label>
                    <input type="email"
                           id="email"
                           name="email"
                           required
                           maxlength="150"
                           autocomplete="email"
                           placeholder="Enter your email">
                </div>

                <div>
                    <label for="password">Password</label>
                    <input type="password"
                           id="password"
                           name="password"
                           required
                           minlength="8"
                           autocomplete="new-password"
                           placeholder="Create a password">
                </div>

                <div>
                    <label for="phone">Phone Number</label>
                    <input type="tel"
                           id="phone"
                           name="phone"
                           required
                           maxlength="20"
                           autocomplete="tel"
                           placeholder="Enter your phone number">
                </div>

                <div>
                    <label for="address">Address</label>
                    <textarea id="address"
                              name="address"
                              required
                              maxlength="500"
                              autocomplete="street-address"
                              placeholder="Enter your address"></textarea>
                </div>

                <!-- ROLE AND STATUS ARE NOT ACCEPTED FROM THE USER -->

                <button type="submit" class="register-button">
                    Create Account
                </button>
            </form>

            <p class="register-login">
                Already registered?
                <a href="<%= contextPath %>/login.jsp">Login here</a>
            </p>

        </section>
    </main>

    <%@ include file="components/footer.jsp" %>

</body>
</html>
