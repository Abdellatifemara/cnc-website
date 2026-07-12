#!/bin/bash
# CNC hero video encoding: seamless-loop web clips from broadcast MXF masters
set -e
SRC=/home/abdellatif/Desktop/caironews/wetransfer_306_1558-mxf_2026-07-10_1802
OUT=/home/abdellatif/Desktop/caironews/site/assets/video
mkdir -p "$OUT"

# encode_loop <src> <name> <start> <dur> <fadedur>
# takes dur+fade seconds, crossfades the tail over the head -> seamless loop
encode_loop() {
  local src="$1" name="$2" ss="$3" dur="$4" fade="$5"
  local total=$(echo "$dur + $fade" | bc)
  ffmpeg -y -v error -ss "$ss" -t "$total" -i "$src" -an \
    -filter_complex "[0:v]fps=25,scale=1920:1080,setsar=1,split[v1][v2];[v1]trim=0:${dur},setpts=PTS-STARTPTS[main];[v2]trim=${dur}:${total},setpts=PTS-STARTPTS[tail];[tail][main]xfade=transition=fade:duration=${fade}:offset=0[out]" \
    -map "[out]" -c:v libx264 -crf 27 -preset slow -profile:v high -pix_fmt yuv420p -movflags +faststart \
    "$OUT/${name}-h.mp4"
  ffmpeg -y -v error -i "$OUT/${name}-h.mp4" -frames:v 1 -q:v 3 "$OUT/${name}-h.jpg"
  echo "DONE ${name}-h $(du -h $OUT/${name}-h.mp4 | cut -f1)"
}

# encode_vert <src> <name> <start> <dur> <fadedur> <cropx>
# 9:16 crop (608x1080) at given x offset, for phones
encode_vert() {
  local src="$1" name="$2" ss="$3" dur="$4" fade="$5" cx="$6"
  local total=$(echo "$dur + $fade" | bc)
  ffmpeg -y -v error -ss "$ss" -t "$total" -i "$src" -an \
    -filter_complex "[0:v]fps=25,scale=1920:1080,crop=608:1080:${cx}:0,setsar=1,split[v1][v2];[v1]trim=0:${dur},setpts=PTS-STARTPTS[main];[v2]trim=${dur}:${total},setpts=PTS-STARTPTS[tail];[tail][main]xfade=transition=fade:duration=${fade}:offset=0[out]" \
    -map "[out]" -c:v libx264 -crf 27 -preset slow -profile:v high -pix_fmt yuv420p -movflags +faststart \
    "$OUT/${name}-v.mp4"
  ffmpeg -y -v error -i "$OUT/${name}-v.mp4" -frames:v 1 -q:v 3 "$OUT/${name}-v.jpg"
  echo "DONE ${name}-v $(du -h $OUT/${name}-v.mp4 | cut -f1)"
}

# horizontal loops
encode_loop "$SRC/306_1558.MXF" dusk-tower    20 12 1
encode_loop "$SRC/306_1559.MXF" dusk-tower-2  10 12 1
encode_loop "$SRC/306_1560.MXF" dusk-center   20 12 1
encode_loop "$SRC/306_1561.MXF" dusk-nile     10 12 1
encode_loop "$SRC/306_1562.MXF" nile-evening  20 12 1
encode_loop "$SRC/306_1565.MXF" night-tower    0 2.7 0.5
encode_loop "$SRC/306_1563.MXF" night-city     0 1.7 0.4
encode_loop "$SRC/306_1564.MXF" night-city-2   0 1.7 0.4

# vertical 9:16 crops centered on Cairo Tower
encode_vert "$SRC/306_1558.MXF" dusk-tower   20 12 1 936
encode_vert "$SRC/306_1560.MXF" dusk-center  20 12 1 676
encode_vert "$SRC/306_1565.MXF" night-tower   0 2.7 0.5 1312

echo "ALL ENCODES COMPLETE"
ls -la "$OUT"
