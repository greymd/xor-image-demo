#!/bin/sh
set -eu

cd "$(dirname "$0")"

font='/System/Library/Fonts/ヒラギノ角ゴシック W8.ttc'

# Render fixed-seed, independent RGB noise, then add identical lettering.
# XOR with a white secret complements the noise inside the silhouette. Uniform
# random RGB and its complement have the same distribution, hiding the border.
magick -seed 20260725 -size 768x768 xc: +noise Random \
  -colorspace sRGB -alpha off -depth 8 \
  -fill black -stroke white -strokewidth 8 \
  -draw 'roundrectangle 48,55 720,230 25,25' \
  -font "$font" -pointsize 112 -gravity north \
  -fill white -stroke black -strokewidth 14 -annotate +0+92 'きれい画像' \
  -fill white -stroke none -annotate +0+92 'きれい画像' \
  -alpha off -depth 8 PNG24:share1.png

# The XOR target is also forced to exact 0/255 channel values.
magick -background black secret-silhouette.svg \
  -colorspace sRGB -alpha off -threshold 50% -depth 8 \
  PNG24:secret.png

# share2 is completely determined by share1 XOR secret.
magick share1.png secret.png \
  -colorspace sRGB -alpha off -evaluate-sequence Xor -depth 8 \
  PNG24:share2.png

# Perform the same merge operation as the shell function in the question.
magick share1.png share2.png \
  -colorspace sRGB -alpha off -evaluate-sequence Xor -depth 8 \
  PNG24:merged.png

# A convenient overview; this file is not involved in the XOR operation.
magick montage share1.png share2.png merged.png \
  -background '#e8e8e8' -geometry 384x384+18+18 -tile 3x1 montage.png

# Exact pixel-level verification. `compare` exits non-zero on a mismatch.
if ! difference=$(magick compare -metric AE secret.png merged.png null: 2>&1); then
  echo "verification failed: ${difference}" >&2
  exit 1
fi

different_pixels=${difference%% *}
if [ "$different_pixels" != "0" ]; then
  echo "verification failed: ${different_pixels} differing pixels" >&2
  exit 1
fi

echo 'OK: merged.png is pixel-for-pixel identical to secret.png'
