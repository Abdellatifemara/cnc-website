#!/bin/bash
# CNC scroll-scrub master: dusk -> evening -> night as ONE timeline.
# All-intra (-g 1): every frame is a keyframe, so video.currentTime seeks
# land instantly in both directions — this is what makes scroll-scrubbing smooth.
set -e
SRC=/home/abdellatif/Desktop/caironews/wetransfer_306_1558-mxf_2026-07-10_1802
OUT=/home/abdellatif/Desktop/caironews/site/assets/video
mkdir -p "$OUT"

FADE=0.75

# ---------- horizontal master (desktop) ----------
# chain: dusk tower 10s -> nile evening 8s -> night tower 3.3s -> night city 2.1s -> night city 2 2.1s
ffmpeg -y -v error \
  -ss 20 -t 10   -i "$SRC/306_1558.MXF" \
  -ss 20 -t 8    -i "$SRC/306_1562.MXF" \
  -i "$SRC/306_1565.MXF" \
  -i "$SRC/306_1563.MXF" \
  -i "$SRC/306_1564.MXF" \
  -an -filter_complex "\
[0:v]fps=25,scale=1536:864,setsar=1[v0];\
[1:v]fps=25,scale=1536:864,setsar=1[v1];\
[2:v]fps=25,scale=1536:864,setsar=1[v2];\
[3:v]fps=25,scale=1536:864,setsar=1[v3];\
[4:v]fps=25,scale=1536:864,setsar=1[v4];\
[v0][v1]xfade=transition=fade:duration=${FADE}:offset=9.25[x1];\
[x1][v2]xfade=transition=fade:duration=${FADE}:offset=16.5[x2];\
[x2][v3]xfade=transition=fade:duration=${FADE}:offset=19.03[x3];\
[x3][v4]xfade=transition=fade:duration=${FADE}:offset=20.4[out]" \
  -map "[out]" -c:v libx264 -crf 30 -preset medium -g 1 -profile:v high \
  -pix_fmt yuv420p -movflags +faststart "$OUT/scrub-master-h.mp4"
ffmpeg -y -v error -i "$OUT/scrub-master-h.mp4" -frames:v 1 -q:v 3 "$OUT/scrub-master-h.jpg"
ffmpeg -y -v error -sseof -0.1 -i "$OUT/scrub-master-h.mp4" -frames:v 1 -q:v 3 "$OUT/scrub-master-h-end.jpg"
echo "H: $(du -h $OUT/scrub-master-h.mp4 | cut -f1) $(ffprobe -v error -show_entries format=duration -of csv=p=0 $OUT/scrub-master-h.mp4)s"

# ---------- vertical master (phones, 9:16, tower-centred crops) ----------
ffmpeg -y -v error \
  -ss 20 -t 10   -i "$SRC/306_1558.MXF" \
  -ss 20 -t 8    -i "$SRC/306_1562.MXF" \
  -i "$SRC/306_1565.MXF" \
  -i "$SRC/306_1563.MXF" \
  -i "$SRC/306_1564.MXF" \
  -an -filter_complex "\
[0:v]fps=25,crop=608:1080:936:0,scale=540:960,setsar=1[v0];\
[1:v]fps=25,crop=608:1080:656:0,scale=540:960,setsar=1[v1];\
[2:v]fps=25,crop=608:1080:1312:0,scale=540:960,setsar=1[v2];\
[3:v]fps=25,crop=608:1080:656:0,scale=540:960,setsar=1[v3];\
[4:v]fps=25,crop=608:1080:656:0,scale=540:960,setsar=1[v4];\
[v0][v1]xfade=transition=fade:duration=${FADE}:offset=9.25[x1];\
[x1][v2]xfade=transition=fade:duration=${FADE}:offset=16.5[x2];\
[x2][v3]xfade=transition=fade:duration=${FADE}:offset=19.03[x3];\
[x3][v4]xfade=transition=fade:duration=${FADE}:offset=20.4[out]" \
  -map "[out]" -c:v libx264 -crf 30 -preset medium -g 1 -profile:v high \
  -pix_fmt yuv420p -movflags +faststart "$OUT/scrub-master-v.mp4"
ffmpeg -y -v error -i "$OUT/scrub-master-v.mp4" -frames:v 1 -q:v 3 "$OUT/scrub-master-v.jpg"
echo "V: $(du -h $OUT/scrub-master-v.mp4 | cut -f1) $(ffprobe -v error -show_entries format=duration -of csv=p=0 $OUT/scrub-master-v.mp4)s"

echo SCRUB-DONE
