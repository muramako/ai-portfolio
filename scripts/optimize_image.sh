#!/usr/bin/env bash
# staging/ の画像を docs/images/ へ移す際に、長辺800px・WebP形式にリサイズ・変換する。
# Usage: scripts/optimize_image.sh <input.png> <output.webp> [quality] [max_long_edge]
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <input> <output.webp> [quality=82] [max_long_edge=800]" >&2
  exit 1
fi

in="$1"
out="$2"
quality="${3:-82}"
max_long_edge="${4:-800}"

if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp が見つかりません。'sudo apt install webp' でインストールしてください。" >&2
  exit 1
fi

dims=$(file "$in" | grep -oE '[0-9]+ x [0-9]+' | head -1)
w=$(echo "$dims" | cut -d' ' -f1)
h=$(echo "$dims" | cut -d' ' -f3)

if [ -z "$w" ] || [ -z "$h" ]; then
  echo "画像サイズを取得できませんでした: $in" >&2
  exit 1
fi

new_w=0
new_h=0
if [ "$w" -ge "$h" ] && [ "$w" -gt "$max_long_edge" ]; then
  new_w=$max_long_edge
elif [ "$h" -gt "$w" ] && [ "$h" -gt "$max_long_edge" ]; then
  new_h=$max_long_edge
fi

cwebp -quiet -q "$quality" -resize "$new_w" "$new_h" "$in" -o "$out"
echo "$in ($w x $h) -> $out"
