
// WAIT UNTIL THE PAGE HTML IS READY
document.addEventListener("DOMContentLoaded", function () {

    // GET THE SIDEBAR ELEMENTS
    const sidebar = document.getElementById("userSidebar");
    const menuButton = document.getElementById("userMobileMenuButton");
    const overlay = document.getElementById("userSidebarOverlay");

    // STOP IF THE REQUIRED ELEMENTS ARE NOT AVAILABLE
    if (!sidebar || !menuButton || !overlay) {
        return;
    }

    // OPEN THE MOBILE SIDEBAR
    function openSidebar() {
        sidebar.classList.add("sidebar-open");
        overlay.classList.add("overlay-visible");
        menuButton.setAttribute("aria-expanded", "true");
        menuButton.setAttribute("aria-label", "Close navigation menu");
    }

    // CLOSE THE MOBILE SIDEBAR
    function closeSidebar() {
        sidebar.classList.remove("sidebar-open");
        overlay.classList.remove("overlay-visible");
        menuButton.setAttribute("aria-expanded", "false");
        menuButton.setAttribute("aria-label", "Open navigation menu");
    }

    // TOGGLE THE SIDEBAR WHEN THE MENU BUTTON IS CLICKED
    menuButton.addEventListener("click", function () {
        if (sidebar.classList.contains("sidebar-open")) {
            closeSidebar();
        } else {
            openSidebar();
        }
    });

    // CLOSE THE SIDEBAR WHEN THE OVERLAY IS CLICKED
    overlay.addEventListener("click", closeSidebar);

    // CLOSE THE SIDEBAR WHEN THE ESCAPE KEY IS PRESSED
    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            closeSidebar();
        }
    });

    // CLOSE THE SIDEBAR AFTER A NAVIGATION LINK IS CLICKED
    sidebar.querySelectorAll(".user-nav-link").forEach(function (link) {
        link.addEventListener("click", closeSidebar);
    });

    // CLOSE THE MOBILE SIDEBAR WHEN THE SCREEN BECOMES DESKTOP-SIZED
    window.addEventListener("resize", function () {
        if (window.innerWidth > 760) {
            closeSidebar();
        }
    });

});
