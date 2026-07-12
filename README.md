# CNC — Cairo News Company website

Static site, no build step. Upload the folder to any host.
Local preview: `node tools/serve.js` then open http://127.0.0.1:8742
(video seeking needs HTTP Range support; python's dev server lacks it, every real host has it).

## The homepage film (ffmpeg on scroll)

The page opens on one continuous take of Cairo going from dusk to true night
(clips reordered so it ENDS at night). Scroll drives the video timeline both
directions. Act titles (Golden hour / Prime time / City lights / Midnight),
the dots and the Cairo clock all run off the same scroll position.

How: `tools/encode-scrub.sh` concatenates the MXF masters with crossfades and
encodes ALL-INTRA (`-g 1`), so every frame is a keyframe and currentTime seeks
land instantly. 23.8s, 9.7 MB desktop (16:9), 3.8 MB phone (9:16 crop on the
tower). `assets/js/site.js` maps scroll to time with a rAF lerp.

## Design

Built from three award-winning production company sites (screenshots were
studied during design research): ArtClass (film titles over full-bleed
footage), Partizan (framed viewport), Silent House (asymmetric editorial
sheet, giant contact line). One typeface, Archivo variable: condensed-black
caps for display (news voice), regular for text. Photo stills in
`assets/img/stills/` are frame grabs from the company's own footage at
different times and crops.

## Pages

index (film + editorial sheet) · about · services (numbered, with stills) ·
clients (logo grid) · careers (form) · contact (offices, desks, form, map).
All content is real, taken from the company's previous site. Forms are mailto
(static hosting); swap the handler in assets/js/site.js when a backend exists.
