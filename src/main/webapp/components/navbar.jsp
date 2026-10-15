
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tap.model.User" %>

<%
    String navContextPath = request.getContextPath();

    // GET THE CURRENTLY LOGGED-IN USER FROM THE SESSION.
    User navUser = null;

    if (session != null) {
        navUser = (User) session.getAttribute("loggedInUser");
    }

    boolean navLoggedIn = navUser != null;

    boolean navIsAdmin = navLoggedIn
            && "ADMIN".equalsIgnoreCase(navUser.getRole());

    boolean navIsUser = navLoggedIn
            && "USER".equalsIgnoreCase(navUser.getRole());

    String navDashboardUrl = "";

    if (navIsAdmin) {
        navDashboardUrl = navContextPath + "/admin-dashboard";
    } else if (navIsUser) {
    	navDashboardUrl = navContextPath + "/user-dashboard";
    }

    String navDisplayName = navLoggedIn
            && navUser.getName() != null
            && !navUser.getName().trim().isEmpty()
            ? navUser.getName().trim()
            : "My Account";

    String navInitial = navDisplayName.substring(0, 1).toUpperCase();
%>

<!-- RESPONSIVE LIBRARY NAVIGATION BAR -->
<header class="site-header">

    <nav class="navbar" aria-label="Main navigation">

        <!-- LIBRARY LOGO -->
        <a href="<%= navContextPath %>/home"
           class="nav-logo"
           aria-label="LibrarySpace home">

            <span class="logo-icon">
                <i class="fa-solid fa-book-open"></i>
            </span>

            <span class="logo-text">
                Library<span>Space</span>
            </span>
        </a>

        <!-- MOBILE MENU BUTTON -->
        <button type="button"
                class="menu-toggle"
                id="menuToggle"
                aria-label="Toggle navigation"
                aria-controls="navLinks"
                aria-expanded="false">

            <i class="fa-solid fa-bars menu-open-icon"></i>
            <i class="fa-solid fa-xmark menu-close-icon"></i>
        </button>

        <!-- MAIN NAVIGATION LINKS -->
        <div class="nav-links" id="navLinks">

            <a href="<%= navContextPath %>/home"
               class="nav-link">
                <i class="fa-solid fa-house"></i>
                Home
            </a>

            <a href="<%= navContextPath %>/home#featured-books"
               class="nav-link">
                <i class="fa-solid fa-book"></i>
                Explore Books
            </a>

            <a href="<%= navContextPath %>/home#features"
               class="nav-link">
                <i class="fa-solid fa-layer-group"></i>
                Features
            </a>

            <a href="<%= navContextPath %>/home#how-it-works"
               class="nav-link">
                <i class="fa-solid fa-circle-info"></i>
                How It Works
            </a>

        </div>

        <!-- DYNAMIC ACCOUNT ACTIONS -->
        <div class="nav-actions" id="navActions">

            <% if (!navLoggedIn) { %>

                <!-- LOGGED-OUT NAVBAR -->
                <a href="<%= navContextPath %>/login"
                   class="btn btn-nav-login">
                    <i class="fa-regular fa-user"></i>
                    Login
                </a>

                <a href="<%= navContextPath %>/register.jsp"
                   class="btn btn-nav-register">
                    <i class="fa-solid fa-user-plus"></i>
                    Register
                </a>

            <% } else { %>

                <!-- LOGGED-IN PROFILE MENU -->
                <div class="nav-profile" id="navProfile">

                    <button type="button"
                            class="nav-profile-trigger"
                            id="navProfileTrigger"
                            aria-label="Open account menu"
                            aria-controls="navProfileDropdown"
                            aria-expanded="false">

                        <span class="nav-profile-avatar">
                            <%= navInitial %>
                        </span>

                        <span class="nav-profile-name">
                            <%= navDisplayName %>
                        </span>

                        <i class="fa-solid fa-chevron-down nav-profile-chevron"></i>
                    </button>

                    <div class="nav-profile-dropdown"
                         id="navProfileDropdown"
                         aria-hidden="true">

                        <div class="nav-profile-heading">
                            <span class="nav-profile-heading-avatar">
                                <%= navInitial %>
                            </span>

                            <div class="nav-profile-user-info">
                                <strong><%= navDisplayName %></strong>

                                <span>
                                    <%= navIsAdmin ? "Administrator" : "Library Member" %>
                                </span>
                            </div>
                        </div>

                        <div class="nav-profile-divider"></div>

                        <% if (navIsAdmin || navIsUser) { %>

                            <a href="<%= navDashboardUrl %>"
                               class="nav-profile-item">
                                <i class="fa-solid fa-gauge-high"></i>

                                <span>
                                    <%= navIsAdmin ? "Admin Dashboard" : "My Dashboard" %>
                                </span>

                                <i class="fa-solid fa-arrow-up-right-from-square nav-item-arrow"></i>
                            </a>

                        <% } %>

                        <a href="<%= navContextPath %>/logout"
                           class="nav-profile-item nav-profile-logout">
                            <i class="fa-solid fa-right-from-bracket"></i>
                            <span>Logout</span>
                        </a>

                    </div>
                </div>

            <% } %>

        </div>

    </nav>

</header>
