#!/usr/bin/env bash
# MAOSPIX - Power Menu con Rofi

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
ROFI_THEME="$HOME/.config/rofi/themes/maospix-dark.rasi"

opcion=$(
    printf '%s\n' \
        "Bloquear" \
        "Suspender" \
        "Reiniciar" \
        "Apagar" \
        "Cancelar" |
    rofi -dmenu \
        -i \
        -no-custom \
        -p "◆ MAOSPIX - ENERGÍA" \
        -theme "$ROFI_THEME" \
        -theme-str "window { width: 360px; } listview { columns: 1; lines: 5; fixed-height: true; }"
) || exit 0

case "$opcion" in
    Bloquear|Suspender|Reiniciar|Apagar)
        "$REPO/scripts/maospix-power-confirm.sh" "$opcion"
        ;;
    *)
        exit 0
        ;;
esac
