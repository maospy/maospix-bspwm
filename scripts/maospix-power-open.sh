#!/usr/bin/env bash
# MAOSPIX BSPWM - Abrir Power Menu Eww

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"

EWW="$HOME/.local/bin/eww"
DIR="$REPO/components/power-menu"

# Abrir el panel; iniciar Eww si no está ejecutándose
if ! "$EWW" --config "$DIR" open maospix_power 2>/dev/null; then
    "$EWW" --config "$DIR" daemon >/tmp/maospix-power-eww.log 2>&1 || true
    sleep 0.5
    "$EWW" --config "$DIR" open maospix_power
fi
