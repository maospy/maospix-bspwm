#!/usr/bin/env bash
# MAOSPIX - Power menu con paleta del tema seleccionado
set -euo pipefail
REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
EWW="$HOME/.local/bin/eww"
DIR="$REPO/components/power-menu"
TEMA="$(cat "$HOME/.config/maospix/tema-actual" 2>/dev/null || echo nord)"
case "$TEMA" in dark|neon|retro|nord) ;; *) TEMA=nord ;; esac

if ! "$EWW" --config "$DIR" ping >/dev/null 2>&1; then
    "$EWW" --config "$DIR" daemon >/dev/null 2>&1 || true
    for i in 1 2 3 4 5 6 7 8 9 10; do
        "$EWW" --config "$DIR" ping >/dev/null 2>&1 && break
        sleep 0.2
    done
fi
"$EWW" --config "$DIR" update "power_theme=$TEMA" power_confirm=none
"$EWW" --config "$DIR" open maospix_power
