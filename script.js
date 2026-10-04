document.addEventListener("DOMContentLoaded", function () {

  const toggle = document.querySelector(".mobile-toggle");
  const menu = document.querySelector(".menu");

  if (toggle && menu) {

    toggle.addEventListener("click", function () {

      const abierto = menu.classList.toggle("open");

      if (abierto) {
        menu.style.display = "flex";
        menu.style.position = "absolute";
        menu.style.top = "68px";
        menu.style.left = "0";
        menu.style.right = "0";
        menu.style.flexDirection = "column";
        menu.style.alignItems = "stretch";
        menu.style.padding = "14px";
        menu.style.background = "#06090d";
        menu.style.border = "1px solid #263341";
        menu.style.borderRadius = "0 0 14px 14px";
        menu.style.zIndex = "99999";
      } else {
        menu.style.display = "none";
      }

    });

    menu.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        menu.classList.remove("open");
        menu.style.display = "none";
      });
    });
  }

  document.querySelectorAll("[data-year]").forEach(function (el) {
    el.textContent = new Date().getFullYear();
  });

});
