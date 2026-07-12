/* CNC site engine.
   Scroll-scrub: the master video is all-intra (ffmpeg -g 1), every frame a
   keyframe, so currentTime seeks resolve instantly both directions. */
(function () {
  'use strict';

  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var phone = window.matchMedia('(orientation: portrait) and (max-width: 820px)');

  /* frame draw-in on load */
  document.documentElement.classList.add('js');
  window.addEventListener('load', function () {
    document.body.classList.add('ready');
  });

  /* ---------- the film ---------- */
  var vid = document.getElementById('film-v');
  var track = document.querySelector('.film-track');
  var nav = document.querySelector('.nav');
  var titles = Array.prototype.slice.call(document.querySelectorAll('.act-title'));
  var dots = Array.prototype.slice.call(document.querySelectorAll('.film-ui .dots i'));
  var tc = document.getElementById('tc');
  var hint = document.querySelector('.film-hint');

  if (vid && track) {
    var setSrc = function () {
      var wantV = phone.matches && vid.dataset.v;
      var src = wantV ? vid.dataset.v : vid.dataset.h;
      if (vid.dataset.current === src) return;
      vid.dataset.current = src;
      vid.poster = wantV ? vid.dataset.pv : vid.dataset.ph;
      vid.src = src;
      vid.load();
    };
    setSrc();
    phone.addEventListener('change', setSrc);
    vid.addEventListener('loadeddata', function () { vid.pause(); });

    var current = 0;
    var loop = function () {
      var r = track.getBoundingClientRect();
      var span = r.height - window.innerHeight;
      var p = span > 0 ? Math.min(1, Math.max(0, -r.top / span)) : 0;

      if (!reduced) {
        var dur = vid.duration;
        if (dur && vid.readyState >= 2) {
          var target = p * (dur - 0.06);
          current += (target - current) * 0.16;
          if (Math.abs(vid.currentTime - current) > 0.02) {
            vid.currentTime = current;
          }
        }
      }

      /* acts: explicit windows matched to the footage */
      var on = 0;
      for (var i = 0; i < titles.length; i++) {
        var a = parseFloat(titles[i].dataset.from);
        var z = parseFloat(titles[i].dataset.to);
        var hit = p >= a && p < z;
        titles[i].classList.toggle('on', hit);
        if (hit) on = i;
      }
      for (var j = 0; j < dots.length; j++) {
        dots[j].classList.toggle('on', j === on);
      }

      /* evening clock, 18:30 -> 00:00 */
      if (tc) {
        var sec = 18.5 * 3600 + p * 5.5 * 3600;
        var h = Math.floor(sec / 3600) % 24;
        var m = Math.floor(sec / 60) % 60;
        tc.textContent = (tc.dataset.city || 'CAIRO') + ' ' + (h < 10 ? '0' : '') + h + ':' + (m < 10 ? '0' : '') + m;
      }

      if (hint) hint.style.opacity = p > 0.03 ? 0 : 0.8;

      /* nav color: white over the film, black on the sheet */
      if (nav) nav.classList.toggle('on-film', r.bottom > 80);

      requestAnimationFrame(loop);
    };
    requestAnimationFrame(loop);

    if (reduced) {
      vid.addEventListener('loadeddata', function () { vid.currentTime = 2; });
    }
  } else if (nav) {
    nav.classList.remove('on-film');
  }

  /* ---------- reveals ---------- */
  var rvs = document.querySelectorAll('.rv');
  if ('IntersectionObserver' in window && !reduced) {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -8% 0px' });
    rvs.forEach(function (el) { io.observe(el); });
  } else {
    rvs.forEach(function (el) { el.classList.add('in'); });
  }

  /* ---------- mailto forms ---------- */
  document.querySelectorAll('form[data-mailto]').forEach(function (form) {
    form.addEventListener('submit', function (ev) {
      ev.preventDefault();
      var lines = [];
      form.querySelectorAll('input, textarea, select').forEach(function (f) {
        if (f.name && f.value) lines.push(f.name + ': ' + f.value);
      });
      window.location.href = 'mailto:' + form.dataset.mailto +
        '?subject=' + encodeURIComponent(form.dataset.subject || 'Website enquiry') +
        '&body=' + encodeURIComponent(lines.join('\n'));
    });
  });

  /* figures count up when revealed */
  var figs = document.querySelectorAll('.figures .n');
  if ('IntersectionObserver' in window && !reduced && figs.length) {
    var fio = new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        if (!e.isIntersecting) return;
        fio.unobserve(e.target);
        var node = e.target.firstChild; /* the text node */
        var target = parseInt(node.textContent, 10);
        if (!target) return;
        var t0 = null;
        var step = function (t) {
          if (!t0) t0 = t;
          var k = Math.min((t - t0) / 1100, 1);
          k = 1 - Math.pow(1 - k, 3);
          node.textContent = Math.round(target * k);
          if (k < 1) requestAnimationFrame(step);
        };
        requestAnimationFrame(step);
      });
    }, { threshold: 0.6 });
    figs.forEach(function (el) { fio.observe(el); });
  }

  /* mobile menu */
  var burger = document.querySelector('.burger');
  if (burger) {
    burger.addEventListener('click', function () {
      document.body.classList.toggle('menu-open');
    });
    document.querySelectorAll('.menu a').forEach(function (a) {
      a.addEventListener('click', function () {
        document.body.classList.remove('menu-open');
      });
    });
  }

  var yr = document.getElementById('yr');
  if (yr) yr.textContent = new Date().getFullYear();
})();
