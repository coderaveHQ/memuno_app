#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DIST_DIR="$REPO_ROOT/legal/dist"

if [[ ! -d "$DIST_DIR" ]]; then
  echo "Missing legal/dist. Run legal/scripts/build_legal_site.sh first."
  exit 1
fi

failures=0

while IFS= read -r file; do
  while IFS= read -r href; do
    href="${href#href=\"}"
    href="${href%\"}"

    if [[ -z "$href" ]]; then
      continue
    fi
    if [[ "$href" =~ ^(https?://|mailto:|tel:|#|javascript:) ]]; then
      continue
    fi

    target=""
    if [[ "$href" == /* ]]; then
      target="$DIST_DIR${href}"
    else
      target="$(cd "$(dirname "$file")" && pwd)/$href"
    fi

    if [[ "$target" == */ ]]; then
      target="${target}index.html"
    elif [[ "$(basename "$target")" != *.* ]]; then
      target="${target}/index.html"
    fi

    if [[ ! -f "$target" ]]; then
      echo "Broken link: $file -> $href"
      failures=$((failures + 1))
    fi
  done < <(grep -Eo 'href="[^"]+"' "$file" || true)
done < <(find "$DIST_DIR" -type f -name '*.html' | sort)

if [[ "$failures" -gt 0 ]]; then
  echo "Found $failures broken internal link(s)."
  exit 1
fi

echo "All internal legal links are valid."
