#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$(basename "$0")"
IMAGES_DIR="${SCRIPT_DIR}/images"

if [ ! -d "${IMAGES_DIR}" ]; then
  echo "Error: images folder not found at: ${IMAGES_DIR}"
  exit 1
fi

MAX_NUMBER=0

is_image_file() {
  case "${1##*.}" in
    png|PNG|jpg|JPG|jpeg|JPEG|gif|GIF|webp|WEBP|bmp|BMP|tif|TIF|tiff|TIFF|heic|HEIC|avif|AVIF)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

while IFS= read -r FILE_PATH; do
  FILE_NAME="$(basename "${FILE_PATH}")"

  if ! is_image_file "${FILE_NAME}"; then
    continue
  fi

  BASE_NAME="${FILE_NAME%.*}"

  case "${BASE_NAME}" in
    ''|*[!0-9]*)
      continue
      ;;
  esac

  if [ "${BASE_NAME}" -gt "${MAX_NUMBER}" ]; then
    MAX_NUMBER="${BASE_NAME}"
  fi
done < <(find "${IMAGES_DIR}" -maxdepth 1 -type f -print)

COUNTER=$((MAX_NUMBER + 1))

find "${IMAGES_DIR}" -maxdepth 1 -type f -print | LC_ALL=C sort | while IFS= read -r FILE_PATH; do
  FILE_NAME="$(basename "${FILE_PATH}")"

  if ! is_image_file "${FILE_NAME}"; then
    continue
  fi

  BASE_NAME="${FILE_NAME%.*}"

  case "${BASE_NAME}" in
    ''|*[!0-9]*)
      ;;
    *)
      continue
      ;;
  esac

  EXTENSION=".${FILE_NAME##*.}"
  NEW_NAME="${COUNTER}${EXTENSION}"
  NEW_PATH="${IMAGES_DIR}/${NEW_NAME}"

  while [ -e "${NEW_PATH}" ]; do
    COUNTER=$((COUNTER + 1))
    NEW_NAME="${COUNTER}${EXTENSION}"
    NEW_PATH="${IMAGES_DIR}/${NEW_NAME}"
  done

  mv -- "${FILE_PATH}" "${NEW_PATH}"
  echo "Renamed: ${FILE_NAME} -> ${NEW_NAME}"

  COUNTER=$((COUNTER + 1))
done
