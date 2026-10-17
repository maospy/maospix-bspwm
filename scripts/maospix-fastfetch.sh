#!/usr/bin/env bash
# MAOSPIX BSPWM - Fastfetch personalizado

set -e

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG="$DIR/config/fastfetch/maospix-nord.jsonc"
LOGO="$DIR/assets/logo/maospix-nord-braille.txt"

if ! command -v fastfetch >/dev/null 2>&1; then
    echo "Error: Fastfetch no está instalado."
    exit 1
fi

if [[ ! -f "$CONFIG" || ! -f "$LOGO" ]]; then
    echo "Error: faltan archivos de Maospix Fastfetch."
    exit 1
fi

exec fastfetch \
    --config "$CONFIG" \
    --logo-type file-raw \
    --logo "$LOGO" \
    --logo-position left \
    --logo-padding-right 3
