#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGES_DIR="${SCRIPT_DIR}/images"

if [ ! -d "${IMAGES_DIR}" ]; then
  echo "Error: images folder not found at: ${IMAGES_DIR}"
  exit 1
fi

cd "${IMAGES_DIR}"

shopt -s nullglob nocaseglob

converted_any=false

for file in *.{png,jpeg,webp,gif,bmp,tif,tiff,heic,avif}; do
  [ -f "$file" ] || continue

  base_name="${file%.*}"
  output_file="${base_name}.jpg"

  echo "Converting: $file -> $output_file"
  ffmpeg -y -i "$file" -q:v 2 "$output_file"

  echo "Deleting original: $file"
  rm -f "$file"

  converted_any=true
done

if [ "$converted_any" = false ]; then
  echo "No convertible images found in: ${IMAGES_DIR}"
else
  echo "Done."
fi
