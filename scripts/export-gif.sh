#!/usr/bin/env bash
# Export a demo video to an optimized animated GIF using ffmpeg + gifski.
# Usage: ./scripts/export-gif.sh [input.mp4] [output.gif]

set -euo pipefail

INPUT="${1:-assets/visualping demo.mp4}"
OUTPUT="${2:-assets/demo.gif}"
FPS=30
WIDTH=480
QUALITY=90

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Extracting frames at ${FPS}fps, ${WIDTH}px wide..."
ffmpeg -loglevel warning -i "$INPUT" \
    -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos" \
    "$TMPDIR/frame%04d.png"

FRAME_COUNT=$(ls "$TMPDIR"/frame*.png | wc -l | tr -d ' ')
echo "Extracted $FRAME_COUNT frames"

echo "Assembling GIF with gifski (quality=$QUALITY)..."
gifski --quality "$QUALITY" --fps "$FPS" --width "$WIDTH" \
    -o "$OUTPUT" "$TMPDIR"/frame*.png

SIZE=$(stat -f%z "$OUTPUT" 2>/dev/null || stat -c%s "$OUTPUT")
SIZE_KB=$((SIZE / 1024))
echo "Output: $OUTPUT (${SIZE_KB}KB)"
