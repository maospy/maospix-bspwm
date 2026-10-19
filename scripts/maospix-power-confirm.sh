#!/usr/bin/env bash
# MAOSPIX - Confirmación del Power Menu con Rofi

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
ROFI_THEME="$HOME/.config/rofi/themes/maospix-dark.rasi"
LOG="$HOME/.cache/maospix-power.log"

case "${1:-}" in
    Bloquear)
        accion="bloquear"
        mensaje="¿Bloquear la sesión?"
        ;;
    Suspender)
        accion="suspender"
        mensaje="¿Suspender el equipo?"
        ;;
    Reiniciar)
        accion="reiniciar"
        mensaje="¿Reiniciar el equipo?"
        ;;
    Apagar)
        accion="apagar"
        mensaje="¿Apagar el equipo?"
        ;;
    *)
        exit 1
        ;;
esac

respuesta=$(
    printf '%s\n' \
        "Sí" \
        "Cancelar" |
    rofi -dmenu \
        -i \
        -no-custom \
        -p "$mensaje" \
        -theme "$ROFI_THEME" \
        -theme-str "window { width: 360px; } listview { columns: 1; lines: 2; fixed-height: true; }"
) || exit 0

[[ "$respuesta" == "Sí" ]] || exit 0

mkdir -p "$HOME/.cache"

nohup "$REPO/scripts/maospix-power-action.sh" "$accion" \
    >> "$LOG" 2>&1 </dev/null &
