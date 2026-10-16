#!/usr/bin/env bash
# Render every theme to SVG, PNG, and an interactive HTML page. PNG conversion needs rsvg-convert (librsvg).
# Usage: ./render.sh [YYYY | --year YYYY]
set -euo pipefail
cd "$(dirname "$0")"
python=python3
[ -x .venv/bin/python3 ] && python=.venv/bin/python3

YEAR_ARG=()
while [ $# -gt 0 ]; do
  case "$1" in
    --year|-y)
      YEAR_ARG=(--year "$2")
      shift 2
      ;;
    --year=*)
      YEAR_ARG=(--year "${1#*=}")
      shift
      ;;
    [12][0-9][0-9][0-9])
      YEAR_ARG=(--year "$1")
      shift
      ;;
    *)
      echo "Usage: $0 [--year YYYY | YYYY]" >&2
      exit 1
      ;;
  esac
done

for theme in tokyonight solarized; do
  "$python" make_poster.py "$theme" ${YEAR_ARG[@]+"${YEAR_ARG[@]}"}
  "$python" make_page.py "$theme" ${YEAR_ARG[@]+"${YEAR_ARG[@]}"}
done
if command -v rsvg-convert >/dev/null; then
  for svg in output/*.svg; do
    [ -f "$svg" ] && rsvg-convert -w 1800 "$svg" -o "${svg%.svg}.png"
  done
else
  echo "rsvg-convert not found; skipping PNGs (try: nix shell nixpkgs#librsvg)" >&2
fi
