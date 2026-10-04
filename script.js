
document.addEventListener("DOMContentLoaded",()=>{
  const toggle=document.querySelector(".mobile-toggle"), menu=document.querySelector(".menu");
  if(toggle) toggle.addEventListener("click",()=>{menu.classList.toggle("open");});
  document.querySelectorAll(".menu a").forEach(a=>a.addEventListener("click",()=>menu.classList.remove("open")));
  document.querySelectorAll("[data-year]").forEach(el=>el.textContent=new Date().getFullYear());
});
