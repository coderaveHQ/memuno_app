#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGES_DIR="${SCRIPT_DIR}/images"

MODEL="${MODEL:-gemma3:12b}"
TAGS_FILE=""
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434/api/chat}"

SUPPORTED_LOCALES=(
  "de"
  "de_DE"
  "en"
  "en_US"
)

usage() {
  echo "Usage: $0 <development|staging|production> <start> <end>"
  echo "Example: $0 development 1 50"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
}

validate_number() {
  local value="$1"
  [[ "$value" =~ ^[0-9]+$ ]]
}

validate_flavor() {
  local value="$1"
  case "$value" in
    development|staging|production)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_images_dir() {
  if [[ ! -d "$IMAGES_DIR" ]]; then
    echo "Error: images folder not found at: $IMAGES_DIR" >&2
    exit 1
  fi
}

ensure_tags_file() {
  if [[ ! -f "$TAGS_FILE" ]]; then
    cat >"$TAGS_FILE" <<'EOF'
| number | tags | id | is_active |
| - | - | - | - |
EOF
  fi
}

escape_markdown_cell() {
  local value="$1"
  value="${value//$'\r'/ }"
  value="${value//$'\n'/ }"
  value="${value//|/\\|}"
  value="$(printf '%s' "$value" | sed -E 's/[[:space:]]+/ /g; s/^ +//; s/ +$//')"
  printf '%s' "$value"
}

normalize_tags() {
  local value="$1"

  printf '%s' "$value" \
    | tr '\r' ' ' \
    | tr '\n' ' ' \
    | sed -E 's/^```[a-zA-Z0-9_-]*[[:space:]]*//; s/[[:space:]]*```$//' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | sed -E 's/[[:space:]]*,[[:space:]]*/,/g' \
    | sed -E 's/,+/,/g' \
    | sed -E 's/^,+//; s/,+$//' \
    | tr '[:upper:]' '[:lower:]'
}

build_language_list() {
  local locale=""
  local language=""
  local result=""
  local seen="|"

  for locale in "${SUPPORTED_LOCALES[@]}"; do
    language="${locale%%_*}"
    language="$(printf '%s' "$language" | tr '[:upper:]' '[:lower:]')"

    if [[ -n "$language" && "$seen" != *"|$language|"* ]]; then
      seen="${seen}${language}|"
      if [[ -z "$result" ]]; then
        result="$language"
      else
        result="${result}"$'\n'"$language"
      fi
    fi
  done

  printf '%s\n' "$result"
}

build_prompt() {
  local locales_joined=""
  local languages_lines=""
  local language=""
  local first=1

  if [[ ${#SUPPORTED_LOCALES[@]} -eq 0 ]]; then
    echo "Error: SUPPORTED_LOCALES must not be empty." >&2
    exit 1
  fi

  for locale in "${SUPPORTED_LOCALES[@]}"; do
    if [[ $first -eq 1 ]]; then
      locales_joined="$locale"
      first=0
    else
      locales_joined="$locales_joined, $locale"
    fi
  done

  while IFS= read -r language; do
    [[ -z "$language" ]] && continue
    languages_lines="${languages_lines}- ${language}"$'\n'
  done <<EOF
$(build_language_list)
EOF

  cat <<EOF
Analyze this meme template image for use in a searchable meme-template database.

Return only one single comma-separated list of tags.

Supported app locales:
${locales_joined}

Relevant languages derived from these locales:
${languages_lines}Rules:
- Return only tags, nothing else.
- No explanation, no intro, no outro.
- No numbering, no bullets, no quotes.
- Use lowercase only.
- Separate tags only with commas.
- No duplicates.
- Include useful search tags for all relevant languages listed above.
- If multiple locales share the same language, do not create meaningless duplicates just because the region differs.
- Return as many tags as are genuinely useful for search.
- Do not artificially limit the number of tags.
- Do not invent extra tags just to make the list longer.
- Include only things that are clearly visible or strongly implied by the meme template itself.
- If a clearly recognizable real person or celebrity is shown, include their commonly known name as tags too.
- If the person is not clearly recognizable, do not guess a name.

Tag categories to cover:
- visible people, animals, objects, clothing, setting
- facial expression, body language, pose
- action or situation
- emotion, mood, reaction
- meme meaning, typical reaction use case, vibe
- common synonyms people would search for
- well-known person or celebrity names, but only when clearly recognizable

Tag quality rules:
- Prefer single words or very short phrases.
- Make tags practical for app search.
- Include both broad and specific terms where useful.
- Include all genuinely useful tags, even if the final list becomes very long.
- Do not include weak, redundant, or barely useful tags.
- Do not invent hidden backstory, names, or context unless the image itself clearly requires it.
- Do not mention watermarks, resolution, or technical image details.

Return only the final comma-separated tag list.
EOF
}

call_ollama_for_tags() {
  local image_path="$1"
  local prompt=""
  local image_b64=""
  local payload_file=""
  local response=""
  local content=""

  prompt="$(build_prompt)"
  image_b64="$(base64 < "$image_path" | tr -d '\n')"
  payload_file="$(mktemp)"

  {
    printf '{'
    printf '"model": "%s",' "$MODEL"
    printf '"stream": false,'
    printf '"messages": ['
    printf '{'
    printf '"role": "user",'
    printf '"content": %s,' "$(printf '%s' "$prompt" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    printf '"images": [%s]' "$(printf '%s' "$image_b64" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    printf '}'
    printf ']'
    printf '}'
  } > "$payload_file"

  response="$(curl -sS "$OLLAMA_URL" \
    -H 'Content-Type: application/json' \
    --data-binary "@$payload_file")"

  rm -f "$payload_file"

  content="$(printf '%s' "$response" | python3 -c 'import sys,json; data=json.load(sys.stdin); print(data.get("message", {}).get("content", ""))')"

  if [[ -z "$content" ]]; then
    echo "Error: Ollama returned no content for $image_path" >&2
    echo "Raw response: $response" >&2
    return 1
  fi

  normalize_tags "$content"
}

upsert_tags_row() {
  local number="$1"
  local tags="$2"
  local escaped_tags=""
  local tmp_file=""

  escaped_tags="$(escape_markdown_cell "$tags")"
  tmp_file="$(mktemp)"

  awk -F'|' -v number="$number" -v tags="$escaped_tags" '
    BEGIN {
      found = 0
    }

    function trim(s) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      return s
    }

    function print_new_row(n, t) {
      printf("| %s | %s |  |  |\n", n, t)
    }

    function print_updated_row(n, t, id_value, active_value) {
      printf("| %s | %s | %s | %s |\n", n, t, id_value, active_value)
    }

    NR <= 2 {
      print
      next
    }

    {
      raw = $0

      if (raw !~ /^\|/) {
        print raw
        next
      }

      current_number = trim($2)
      current_id = trim($4)
      current_is_active = trim($5)

      if (current_number ~ /^[0-9]+$/) {
        current_num = current_number + 0

        if (found == 0 && number < current_num) {
          print_new_row(number, tags)
          found = 1
        }

        if (current_num == number) {
          print_updated_row(number, tags, current_id, current_is_active)
          found = 1
          next
        }
      }

      print raw
    }

    END {
      if (found == 0) {
        print_new_row(number, tags)
      }
    }
  ' "$TAGS_FILE" > "$tmp_file"

  mv "$tmp_file" "$TAGS_FILE"
}

main() {
  local flavor=""
  local start=""
  local end=""
  local i=0
  local image_file=""
  local image_path=""
  local tags=""

  require_command curl
  require_command python3
  require_command base64
  require_command awk
  require_command sed
  require_command tr

  if [[ $# -ne 3 ]]; then
    usage
    exit 1
  fi

  flavor="$1"
  start="$2"
  end="$3"

  if ! validate_flavor "$flavor"; then
    echo "Error: flavor must be one of: development, staging, production." >&2
    exit 1
  fi

  if ! validate_number "$start" || ! validate_number "$end"; then
    echo "Error: start and end must both be positive integers." >&2
    exit 1
  fi

  if (( start > end )); then
    echo "Error: start must be less than or equal to end." >&2
    exit 1
  fi

  TAGS_FILE="${SCRIPT_DIR}/tags_${flavor}.md"

  ensure_images_dir
  ensure_tags_file

  echo "Using tags file: ${TAGS_FILE}" >&2

  for (( i = start; i <= end; i++ )); do
    image_file="${i}.png"
    image_path="${IMAGES_DIR}/${image_file}"

    if [[ ! -f "$image_path" ]]; then
      echo "Skipping $image_file: file not found in ${IMAGES_DIR}." >&2
      continue
    fi

    echo "Analyzing $image_file ..." >&2
    tags="$(call_ollama_for_tags "$image_path")"

    if [[ -z "$tags" ]]; then
      echo "Skipping $image_file: empty tags returned." >&2
      continue
    fi

    upsert_tags_row "$i" "$tags"
    echo "Saved tags for $image_file" >&2
  done
}

main "$@"
