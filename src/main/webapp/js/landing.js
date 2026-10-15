
/* HANDLE DATABASE SEARCH AND LANDING PAGE INTERACTIONS */
document.addEventListener("DOMContentLoaded", function () {

    // GET THE SEARCH ELEMENTS
    const searchInput = document.getElementById("bookSearch");
    const clearSearchButton = document.getElementById("clearSearch");

    // GET THE CONTEXT PATH PROVIDED BY THE JSP
    const contextPath = document.body.dataset.contextPath || "";

    // READ THE CURRENT SEARCH TERM FROM THE URL
    const urlParams = new URLSearchParams(window.location.search);
    const currentSearch = urlParams.get("query");

    // KEEP THE SEARCH TERM VISIBLE AFTER THE PAGE RELOADS
    if (searchInput && currentSearch) {
        searchInput.value = currentSearch;
    }

    // SUBMIT THE SEARCH TO THE DATABASE-BACKED CONTROLLER
    function submitSearch() {
        if (!searchInput) {
            return;
        }

        const query = searchInput.value.trim();

        // RETURN TO THE DEFAULT BOOKS WHEN SEARCH IS EMPTY
        if (query === "") {
            window.location.href = contextPath + "/home";
            return;
        }

        // SEND THE SEARCH TERM TO BOOKCONTROLLER
        window.location.href =
            contextPath + "/home?query=" + encodeURIComponent(query);
    }

    // SEARCH WHEN THE USER PRESSES ENTER
    if (searchInput) {
        searchInput.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
                submitSearch();
            }
        });
    }

    // CLEAR SEARCH AND RESTORE THE FEATURED BOOKS
    if (clearSearchButton) {
        clearSearchButton.addEventListener("click", function () {
            if (searchInput) {
                searchInput.value = "";
            }

            window.location.href = contextPath + "/home";
        });
    }

    // GET THE MOBILE NAVIGATION ELEMENTS
    const menuToggle =
        document.getElementById("menuToggle") ||
        document.getElementById("mobileMenuToggle") ||
        document.querySelector(".menu-toggle") ||
        document.querySelector(".hamburger") ||
        document.querySelector("[aria-controls='navLinks']");

    const navLinks =
        document.getElementById("navLinks") ||
        document.querySelector(".nav-links");

    const navActions =
        document.getElementById("navActions") ||
        document.querySelector(".nav-actions");

    // TOGGLE MOBILE NAVIGATION
    if (menuToggle) {
        menuToggle.setAttribute("aria-expanded", "false");

        menuToggle.addEventListener("click", function () {
            const isOpen = navLinks
                ? navLinks.classList.toggle("open")
                : false;

            if (navActions) {
                navActions.classList.toggle("open", isOpen);
            }

            menuToggle.setAttribute("aria-expanded", String(isOpen));
            menuToggle.classList.toggle("active", isOpen);
        });
    }

    // CLOSE MOBILE NAVIGATION AFTER A LINK IS SELECTED
    document.querySelectorAll(
        ".nav-links a, .nav-actions a"
    ).forEach(function (link) {
        link.addEventListener("click", function () {
            if (navLinks) {
                navLinks.classList.remove("open");
            }

            if (navActions) {
                navActions.classList.remove("open");
            }

            if (menuToggle) {
                menuToggle.classList.remove("active");
                menuToggle.setAttribute("aria-expanded", "false");
            }
        });
    });

    // HANDLE THE LOGGED-IN USER PROFILE DROPDOWN
    const navProfile = document.getElementById("navProfile");
    const navProfileTrigger =
        document.getElementById("navProfileTrigger");
    const navProfileDropdown =
        document.getElementById("navProfileDropdown");

    if (navProfile && navProfileTrigger && navProfileDropdown) {

        // OPEN OR CLOSE THE PROFILE MENU
        function setProfileMenuOpen(isOpen) {
            navProfile.classList.toggle("is-open", isOpen);

            navProfileTrigger.setAttribute(
                "aria-expanded",
                String(isOpen)
            );

            navProfileDropdown.setAttribute(
                "aria-hidden",
                String(!isOpen)
            );
        }

        // OPEN THE PROFILE MENU WHEN HOVERING ON DESKTOP
        navProfile.addEventListener("mouseenter", function () {
            if (
                window.matchMedia(
                    "(hover: hover) and (pointer: fine)"
                ).matches
            ) {
                setProfileMenuOpen(true);
            }
        });

        // CLOSE THE PROFILE MENU WHEN THE POINTER LEAVES
        navProfile.addEventListener("mouseleave", function () {
            if (
                window.matchMedia(
                    "(hover: hover) and (pointer: fine)"
                ).matches
            ) {
                setProfileMenuOpen(false);
            }
        });

        // TOGGLE THE PROFILE MENU ON CLICK
        navProfileTrigger.addEventListener("click", function () {
            const isOpen =
                navProfile.classList.contains("is-open");

            setProfileMenuOpen(!isOpen);
        });

        // CLOSE THE PROFILE MENU WHEN CLICKING OUTSIDE
        document.addEventListener("click", function (event) {
            if (!navProfile.contains(event.target)) {
                setProfileMenuOpen(false);
            }
        });

        // CLOSE THE PROFILE MENU WHEN ESCAPE IS PRESSED
        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                setProfileMenuOpen(false);
                navProfileTrigger.focus();
            }
        });
    }

    // GET ELEMENTS THAT SHOULD APPEAR WHEN SCROLLED INTO VIEW
    const revealElements = document.querySelectorAll(
        ".reveal, .fade-in, .feature-card, .step-card, .book-card, .stat-card"
    );

    // REVEAL ELEMENTS USING INTERSECTION OBSERVER
    if ("IntersectionObserver" in window && revealElements.length > 0) {
        const revealObserver = new IntersectionObserver(
            function (entries, observer) {
                entries.forEach(function (entry) {
                    if (entry.isIntersecting) {
                        entry.target.classList.add(
                            "visible",
                            "revealed"
                        );

                        observer.unobserve(entry.target);
                    }
                });
            },
            {
                threshold: 0.12,
                rootMargin: "0px 0px -30px 0px"
            }
        );

        revealElements.forEach(function (element) {
            element.classList.add("reveal-ready");
            revealObserver.observe(element);
        });
    } else {
        revealElements.forEach(function (element) {
            element.classList.add("visible", "revealed");
        });
    }

});
