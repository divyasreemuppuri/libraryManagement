
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    // ADDED: GET THE APPLICATION CONTEXT PATH
    String footerContextPath = request.getContextPath();
%>

<!-- ADDED: LIBRARYSPACE FOOTER -->
<footer class="site-footer">

    <div class="footer-container">

        <!-- ADDED: BRAND AND DESCRIPTION -->
        <div class="footer-brand">

            <a href="<%= footerContextPath %>/home"
               class="nav-logo">

                <span class="logo-icon">
                    <i class="fa-solid fa-book-open"></i>
                </span>

                <span class="logo-text">
                    Library<span>Space</span>
                </span>

            </a>

            <p>
                Your gateway to knowledge, discovery, and lifelong learning.
                Explore books, manage your borrowing, and make every reading
                moment count with LibrarySpace.
            </p>

        </div>

        <!-- ADDED: QUICK NAVIGATION LINKS -->
        <div class="footer-column">

            <h4>Explore</h4>

            <div class="footer-links">
                <a href="<%= footerContextPath %>/home">
                    Home
                </a>

                <a href="<%= footerContextPath %>/home#featured-books">
                    Explore Books
                </a>

                <a href="<%= footerContextPath %>/home#features">
                    Features
                </a>

                <a href="<%= footerContextPath %>/home#how-it-works">
                    How It Works
                </a>
            </div>

        </div>

        <!-- ADDED: ACCOUNT LINKS -->
        <div class="footer-column">

            <h4>Your Account</h4>

            <div class="footer-links">
                <a href="<%= footerContextPath %>/login.jsp">
                    Login
                </a>

                <a href="<%= footerContextPath %>/register.jsp">
                    Create an Account
                </a>
            </div>

        </div>

    </div>

    <!-- ADDED: COPYRIGHT SECTION -->
    <div class="footer-bottom">
        <p>
            &copy; <%= java.time.Year.now().getValue() %>
            LibrarySpace. All rights reserved.
        </p>

        <p class="footer-tagline">
            <i class="fa-solid fa-book-open"></i>
            Built for readers. Designed for discovery.
        </p>
    </div>

</footer>