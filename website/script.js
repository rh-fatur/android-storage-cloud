/* Android Storage Cloud, situs statis. Tanpa dependensi. */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- 1. Ketik output terminal di layar HP ---------- */
  var term = document.getElementById("term");
  if (term && !reduceMotion) {
    var full = term.textContent;
    var i = 0;
    term.textContent = "";
    (function tick() {
      i += 1;
      term.textContent = full.slice(0, i);
      if (i < full.length) {
        var ch = full.charAt(i - 1);
        setTimeout(tick, ch === "\n" ? 260 : 14);
      }
    })();
  }

  /* ---------- 2. Tombol salin pada blok kode ---------- */
  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      var ta = document.createElement("textarea");
      ta.value = text;
      ta.setAttribute("readonly", "");
      ta.style.position = "fixed";
      ta.style.opacity = "0";
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand("copy") ? resolve() : reject(); }
      catch (e) { reject(e); }
      document.body.removeChild(ta);
    });
  }

  document.querySelectorAll(".code .copy").forEach(function (btn) {
    var timer;
    btn.setAttribute("aria-live", "polite");
    btn.addEventListener("click", function () {
      var code = btn.parentElement.querySelector("code");
      copyText(code.textContent.trim()).then(function () {
        btn.textContent = "Tersalin";
        btn.classList.add("is-done");
      }, function () {
        btn.textContent = "Gagal, salin manual";
      }).then(function () {
        clearTimeout(timer);
        timer = setTimeout(function () {
          btn.textContent = "Salin";
          btn.classList.remove("is-done");
        }, 1800);
      });
    });
  });

  /* ---------- 3. Tab perintah (laptop / HP) ---------- */
  var tabs = Array.prototype.slice.call(document.querySelectorAll('[role="tab"]'));
  function selectTab(tab) {
    tabs.forEach(function (t) {
      var on = t === tab;
      t.setAttribute("aria-selected", on ? "true" : "false");
      t.tabIndex = on ? 0 : -1;
      document.getElementById(t.getAttribute("aria-controls")).hidden = !on;
    });
  }
  tabs.forEach(function (tab, idx) {
    tab.addEventListener("click", function () { selectTab(tab); });
    tab.addEventListener("keydown", function (e) {
      var next;
      if (e.key === "ArrowRight") next = tabs[(idx + 1) % tabs.length];
      else if (e.key === "ArrowLeft") next = tabs[(idx - 1 + tabs.length) % tabs.length];
      else if (e.key === "Home") next = tabs[0];
      else if (e.key === "End") next = tabs[tabs.length - 1];
      if (next) { e.preventDefault(); selectTab(next); next.focus(); }
    });
  });

  /* ---------- 4. Tandai menu sesuai bagian yang sedang dibaca ---------- */
  var links = {};
  document.querySelectorAll('.top nav a[href^="#"]').forEach(function (a) {
    links[a.getAttribute("href").slice(1)] = a;
  });
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (!en.isIntersecting) return;
        Object.keys(links).forEach(function (id) { links[id].removeAttribute("aria-current"); });
        var a = links[en.target.id];
        if (a) a.setAttribute("aria-current", "true");
      });
    }, { rootMargin: "-35% 0px -60% 0px" });
    Object.keys(links).forEach(function (id) {
      var sec = document.getElementById(id);
      if (sec) io.observe(sec);
    });
  }
})();
