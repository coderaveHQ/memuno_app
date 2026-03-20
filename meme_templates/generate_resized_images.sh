#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGES_DIR="$SCRIPT_DIR/images"
OUT_150_DIR="$IMAGES_DIR/150_kb"
OUT_20_DIR="$IMAGES_DIR/20_kb"
# Keep these aligned with Supabase storage.buckets.file_size_limit values.
TARGET_150_BYTES=153600
TARGET_20_BYTES=20480
CANDIDATE_LIST_FILE=""
SORTED_LIST_FILE=""

mkdir -p "$OUT_150_DIR"
mkdir -p "$OUT_20_DIR"

cleanup_temp_files() {
  find "$OUT_150_DIR" "$OUT_20_DIR" -maxdepth 1 -type f -name '.*_tmp.jpg' -delete 2>/dev/null || true
  if [ -n "$CANDIDATE_LIST_FILE" ]; then
    rm -f "$CANDIDATE_LIST_FILE"
  fi
  if [ -n "$SORTED_LIST_FILE" ]; then
    rm -f "$SORTED_LIST_FILE"
  fi
}

trap cleanup_temp_files EXIT INT TERM

if ! command -v magick >/dev/null 2>&1; then
  echo "Error: ImageMagick is not installed."
  echo "Install it with: brew install imagemagick"
  exit 1
fi

if [ ! -d "$IMAGES_DIR" ]; then
  echo "Error: Folder not found: $IMAGES_DIR"
  exit 1
fi

usage() {
  echo "Usage: $(basename "$0") [start_number [end_number]]"
  echo "Examples:"
  echo "  $(basename "$0")        # Process all numeric filenames in ascending order"
  echo "  $(basename "$0") 8      # Process only file number 8"
  echo "  $(basename "$0") 8 20   # Process range 8 to 20 (inclusive)"
}

is_non_negative_integer() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

START_NUMBER=""
END_NUMBER=""

if [ "$#" -gt 2 ]; then
  usage
  exit 1
fi

if [ "$#" -eq 1 ]; then
  START_NUMBER="$1"
  END_NUMBER="$1"
fi

if [ "$#" -eq 2 ]; then
  START_NUMBER="$1"
  END_NUMBER="$2"
fi

if [ -n "$START_NUMBER" ]; then
  if ! is_non_negative_integer "$START_NUMBER"; then
    echo "Error: start_number must be a non-negative integer, got '$START_NUMBER'."
    exit 1
  fi

  if ! is_non_negative_integer "$END_NUMBER"; then
    echo "Error: end_number must be a non-negative integer, got '$END_NUMBER'."
    exit 1
  fi

  if [ "$START_NUMBER" -gt "$END_NUMBER" ]; then
    echo "Error: start_number ($START_NUMBER) cannot be greater than end_number ($END_NUMBER)."
    exit 1
  fi
fi

process_image() {
  local input_file="$1"
  local target_bytes="$2"
  local output_dir="$3"
  local target_label="$4"

  local filename
  local basename
  local output_file
  local temp_file
  local smallest_size
  local scale
  local quality
  local success

  filename="$(basename "$input_file")"
  basename="${filename%.*}"

  output_file="$output_dir/${basename}.jpg"
  temp_file="$output_dir/.${basename}_tmp.jpg"
  smallest_size=0
  success=0

  rm -f "$output_file" "$temp_file"

  for scale in 100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 9 8 7 6 5 4 3 2 1; do
    for quality in 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 8 6 5 4 3 2 1; do
      magick "$input_file" \
        -auto-orient \
        -strip \
        -resize "${scale}%" \
        -background white \
        -alpha remove \
        -alpha off \
        -sampling-factor 4:2:0 \
        -define jpeg:optimize-coding=true \
        -interlace Plane \
        -quality "$quality" \
        "$temp_file"

      if [ -f "$temp_file" ]; then
        local file_size
        file_size="$(stat -f%z "$temp_file")"
        if [ "$smallest_size" -eq 0 ] || [ "$file_size" -lt "$smallest_size" ]; then
          smallest_size="$file_size"
        fi

        if [ "$file_size" -le "$target_bytes" ]; then
          mv "$temp_file" "$output_file"
          echo "Created: $output_file (${file_size} bytes <= ${target_label})"
          success=1
          break 2
        fi
      fi
    done
  done

  if [ "$success" -eq 0 ]; then
    rm -f "$temp_file" "$output_file"
    echo "Error: Could not reduce '$filename' to <= ${target_label}. Smallest attempt was ${smallest_size} bytes."
    return 1
  fi
}

had_errors=0

CANDIDATE_LIST_FILE="$(mktemp)"

while IFS= read -r -d '' image_file; do
  image_filename="$(basename "$image_file")"
  image_basename="${image_filename%.*}"

  if ! is_non_negative_integer "$image_basename"; then
    continue
  fi

  image_number=$((10#$image_basename))
  if [ -n "$START_NUMBER" ] && { [ "$image_number" -lt "$START_NUMBER" ] || [ "$image_number" -gt "$END_NUMBER" ]; }; then
    continue
  fi

  printf '%s\t%s\n' "$image_number" "$image_file" >> "$CANDIDATE_LIST_FILE"
done < <(
  find "$IMAGES_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" -o \
    -iname "*.gif" -o \
    -iname "*.bmp" -o \
    -iname "*.tif" -o \
    -iname "*.tiff" -o \
    -iname "*.heic" -o \
    -iname "*.avif" \
  \) ! -path "$OUT_150_DIR/*" ! -path "$OUT_20_DIR/*" -print0
)

if [ ! -s "$CANDIDATE_LIST_FILE" ]; then
  if [ -n "$START_NUMBER" ]; then
    echo "Error: No numeric image files found in range [$START_NUMBER, $END_NUMBER] under $IMAGES_DIR."
  else
    echo "Error: No numeric image files found under $IMAGES_DIR."
  fi
  exit 1
fi

SORTED_LIST_FILE="$(mktemp)"
sort -n -k1,1 "$CANDIDATE_LIST_FILE" > "$SORTED_LIST_FILE"

if [ -n "$START_NUMBER" ]; then
  echo "Processing numeric range [$START_NUMBER, $END_NUMBER] in ascending order."
else
  echo "Processing all numeric files in ascending order."
fi

while IFS=$'\t' read -r image_number image_file; do
  [ -n "$image_file" ] || continue
  echo "Processing #$image_number: $image_file"
  if ! process_image "$image_file" "$TARGET_150_BYTES" "$OUT_150_DIR" "153600 bytes"; then
    had_errors=1
  fi
  if ! process_image "$image_file" "$TARGET_20_BYTES" "$OUT_20_DIR" "20480 bytes"; then
    had_errors=1
  fi
done < "$SORTED_LIST_FILE"

if [ "$had_errors" -ne 0 ]; then
  echo "Done with errors."
  echo "At least one output could not be generated within Supabase size limits."
  exit 1
fi

echo "Done."
echo "Originals remain untouched in: $IMAGES_DIR"
echo "150 KB versions: $OUT_150_DIR"
echo "20 KB versions: $OUT_20_DIR"
