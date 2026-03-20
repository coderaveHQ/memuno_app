#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

usage() {
  cat >&2 <<'EOF'
Usage: ./upload_templates_by_flavor.sh <development|staging|production>
EOF
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Error: Required command not found: $command_name" >&2
    exit 1
  fi
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

parse_markdown_rows() {
  local tags_file="$1"
  python3 - "$tags_file" <<'PY'
import sys

path = sys.argv[1]

with open(path, "r", encoding="utf-8") as file:
    for line_number, raw_line in enumerate(file, start=1):
        stripped = raw_line.strip()
        if not stripped.startswith("|"):
            continue

        cells = [cell.strip() for cell in stripped.split("|")[1:-1]]
        if len(cells) < 4:
            continue

        number, tags, row_id, is_active = cells[0], cells[1], cells[2], cells[3]
        if number.lower() == "number":
            continue
        if set(number) <= {"-", " "}:
            continue
        if not number.isdigit():
            continue

        tags = tags.replace("\t", " ").replace("\n", " ")
        row_id = row_id.replace("\t", " ").replace("\n", " ")
        is_active = is_active.replace("\t", " ").replace("\n", " ")
        print(f"{line_number}\t{number}\t{tags}\t{row_id}\t{is_active}")
PY
}

to_tags_json() {
  local tags_raw="$1"
  python3 - "$tags_raw" <<'PY'
import json
import sys

raw = sys.argv[1]
tags = [part.strip() for part in raw.split(",")]
tags = [tag for tag in tags if tag]
print(json.dumps(tags, ensure_ascii=False))
PY
}

aspect_ratio_for_image() {
  local image_path="$1"
  local width
  local height

  width="$(sips -g pixelWidth "$image_path" 2>/dev/null | awk '/pixelWidth:/ { print $2 }')"
  height="$(sips -g pixelHeight "$image_path" 2>/dev/null | awk '/pixelHeight:/ { print $2 }')"

  if [[ -z "$width" || -z "$height" || "$height" == "0" ]]; then
    echo "Error: Failed to read image dimensions from: $image_path" >&2
    exit 1
  fi

  python3 - "$width" "$height" <<'PY'
import sys

width = float(sys.argv[1])
height = float(sys.argv[2])
if height <= 0:
    raise SystemExit("height must be > 0")
print(f"{width / height:.10f}")
PY
}

upload_object() {
  local bucket="$1"
  local object_name="$2"
  local local_file="$3"
  local response_body
  local http_code

  response_body="$(mktemp)"
  http_code="$(
    curl -sS -o "$response_body" -w "%{http_code}" \
      -X POST \
      -H "apikey: $SUPABASE_SECRET_KEY" \
      -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
      -H "Content-Type: image/jpeg" \
      -H "x-upsert: false" \
      --data-binary "@$local_file" \
      "$SUPABASE_URL/storage/v1/object/$bucket/$object_name"
  )"

  if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
    echo "Error: Upload failed for $bucket/$object_name (HTTP $http_code)" >&2
    cat "$response_body" >&2
    rm -f "$response_body"
    return 1
  fi

  rm -f "$response_body"
}

delete_object_best_effort() {
  local bucket="$1"
  local object_name="$2"

  curl -sS -o /dev/null \
    -X DELETE \
    -H "apikey: $SUPABASE_SECRET_KEY" \
    -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
    "$SUPABASE_URL/storage/v1/object/$bucket/$object_name" || true
}

insert_meme_template_row() {
  local payload="$1"
  local response_body
  local http_code

  response_body="$(mktemp)"
  http_code="$(
    curl -sS -o "$response_body" -w "%{http_code}" \
      -X POST \
      -H "apikey: $SUPABASE_SECRET_KEY" \
      -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
      -H "Content-Type: application/json" \
      -H "Prefer: return=minimal" \
      -d "$payload" \
      "$SUPABASE_URL/rest/v1/meme_templates"
  )"

  if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
    echo "Error: Insert into public.meme_templates failed (HTTP $http_code)" >&2
    cat "$response_body" >&2
    rm -f "$response_body"
    return 1
  fi

  rm -f "$response_body"
}

write_row_id_back() {
  local tags_file="$1"
  local target_line="$2"
  local new_id="$3"

  python3 - "$tags_file" "$target_line" "$new_id" <<'PY'
import sys

path = sys.argv[1]
target_line = int(sys.argv[2])
new_id = sys.argv[3]

with open(path, "r", encoding="utf-8") as file:
    lines = file.readlines()

if target_line < 1 or target_line > len(lines):
    raise SystemExit(f"line out of range: {target_line}")

row = lines[target_line - 1].strip()
if not row.startswith("|"):
    raise SystemExit(f"target line is not a markdown table row: {target_line}")

cells = [cell.strip() for cell in row.split("|")[1:-1]]
if len(cells) < 4:
    raise SystemExit(f"expected at least 4 columns on line {target_line}")

cells[2] = new_id
updated = f"| {cells[0]} | {cells[1]} | {cells[2]} | {cells[3]} |\n"
lines[target_line - 1] = updated

with open(path, "w", encoding="utf-8", newline="") as file:
    file.writelines(lines)
PY
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

FLAVOR="$1"
case "$FLAVOR" in
  development|staging|production)
    ;;
  *)
    usage
    exit 1
    ;;
esac

require_command curl
require_command jq
require_command uuidgen
require_command sips
require_command python3

ENV_FILE="$SCRIPT_DIR/.env.$FLAVOR"
TAGS_FILE="$SCRIPT_DIR/tags_${FLAVOR}.md"
IMAGE_150_DIR="$SCRIPT_DIR/images/150_kb"
IMAGE_20_DIR="$SCRIPT_DIR/images/20_kb"
BUCKET_HIGH="meme_templates"
BUCKET_LOW="meme_templates_low"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: Missing env file: $ENV_FILE" >&2
  exit 1
fi
if [[ ! -f "$TAGS_FILE" ]]; then
  echo "Error: Missing tags file: $TAGS_FILE" >&2
  exit 1
fi
if [[ ! -d "$IMAGE_150_DIR" || ! -d "$IMAGE_20_DIR" ]]; then
  echo "Error: Expected image directories not found: $IMAGE_150_DIR and/or $IMAGE_20_DIR" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${SUPABASE_URL:?Error: SUPABASE_URL is required in $ENV_FILE}"
: "${SUPABASE_SECRET_KEY:?Error: SUPABASE_SECRET_KEY is required in $ENV_FILE}"
SUPABASE_URL="${SUPABASE_URL%/}"

rows_found=0
processed=0
skipped=0

while IFS=$'\t' read -r line_no number tags id_value _is_active; do
  [[ -z "${line_no:-}" ]] && continue
  rows_found=$((rows_found + 1))

  id_trimmed="$(trim "$id_value")"
  if [[ -n "$id_trimmed" ]]; then
    echo "[$number] skipped (id already set: $id_trimmed)"
    skipped=$((skipped + 1))
    continue
  fi

  image_150_path="$IMAGE_150_DIR/${number}.jpg"
  image_20_path="$IMAGE_20_DIR/${number}.jpg"

  if [[ ! -f "$image_150_path" ]]; then
    echo "Error: Missing image file: $image_150_path" >&2
    exit 1
  fi
  if [[ ! -f "$image_20_path" ]]; then
    echo "Error: Missing image file: $image_20_path" >&2
    exit 1
  fi

  uuid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  object_name="${uuid}.jpg"
  ratio="$(aspect_ratio_for_image "$image_150_path")"
  tags_json="$(to_tags_json "$tags")"
  payload="$(
    jq -cn \
      --arg image_path "$object_name" \
      --arg image_path_low "$object_name" \
      --argjson aspect_ratio "$ratio" \
      --argjson tags "$tags_json" \
      '{
        image_path: $image_path,
        image_path_low: $image_path_low,
        aspect_ratio: $aspect_ratio,
        tags: $tags
      }'
  )"

  upload_object "$BUCKET_HIGH" "$object_name" "$image_150_path"
  if ! upload_object "$BUCKET_LOW" "$object_name" "$image_20_path"; then
    delete_object_best_effort "$BUCKET_HIGH" "$object_name"
    exit 1
  fi

  if ! insert_meme_template_row "$payload"; then
    delete_object_best_effort "$BUCKET_HIGH" "$object_name"
    delete_object_best_effort "$BUCKET_LOW" "$object_name"
    exit 1
  fi

  write_row_id_back "$TAGS_FILE" "$line_no" "$uuid"
  echo "[$number] uploaded -> inserted -> markdown updated ($uuid)"
  processed=$((processed + 1))
done < <(parse_markdown_rows "$TAGS_FILE")

if [[ "$rows_found" -eq 0 ]]; then
  echo "Error: No data rows found in $TAGS_FILE" >&2
  exit 1
fi

echo "Done. processed=$processed skipped=$skipped flavor=$FLAVOR"
