#!/usr/bin/env bash
#
# Renders cv-en.html / cv-pt.html to the PDFs served from ../assets.
# Requires Google Chrome (headless); uses Ghostscript to shrink the result
# when it is available. Run from anywhere:
#
#   ./cv-src/build.sh
#
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$here/../assets"

chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
if [ ! -x "$chrome" ]; then
  echo "Chrome not found at: $chrome" >&2
  echo "Set CHROME=/path/to/chrome and try again." >&2
  exit 1
fi

if ! command -v gs >/dev/null 2>&1; then
  echo "warning: ghostscript not found, skipping the shrink pass" >&2
  echo "         (brew install ghostscript) — PDFs will be ~40% larger" >&2
fi

render() {
  local src="$1" dest="$2"
  "$chrome" \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --no-pdf-header-footer \
    --virtual-time-budget=4000 \
    --print-to-pdf="$dest" \
    "file://$src" 2>/dev/null

  # Chrome embeds one font subset per distinct font-size and stores the photo
  # at its source resolution. Ghostscript rewrites both: fonts get re-embedded
  # once and the image is resampled to 300 dpi. Text stays vector either way.
  if command -v gs >/dev/null 2>&1; then
    local tmp="$dest.tmp"
    # The explicit sRGB strategy is not cosmetic: without it Ghostscript emits
    # an empty ICCBased colour space that some readers warn about.
    gs -sDEVICE=pdfwrite \
       -dCompatibilityLevel=1.7 \
       -dPDFSETTINGS=/prepress \
       -dDetectDuplicateImages=true \
       -dColorConversionStrategy=/sRGB \
       -dProcessColorModel=/DeviceRGB \
       -dNOPAUSE -dQUIET -dBATCH \
       -sOutputFile="$tmp" "$dest"
    mv "$tmp" "$dest"
  fi

  printf '%-46s %s\n' "$(basename "$dest")" "$(du -h "$dest" | cut -f1)"
}

render "$here/cv-en.html" "$out/Rafael-Ribeiro-da-Silva-CV-EN.pdf"
render "$here/cv-pt.html" "$out/Rafael-Ribeiro-da-Silva-CV-PT.pdf"

echo "Done."
