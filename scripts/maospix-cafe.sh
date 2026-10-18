#!/usr/bin/env bash
# MAOSPIX BSPWM - Modo Cafeína (XFCE Power Manager)
set -euo pipefail
CANAL="xfce4-power-manager"
PROPIEDAD="/xfce4-power-manager/presentation-mode"

if ! command -v xfconf-query >/dev/null 2>&1; then
    echo "☕ Cafeína no disponible (xfconf-query ausente)"
    exit 0
fi

if ! xfconf-query -c "$CANAL" -p "$PROPIEDAD" >/dev/null 2>&1; then
    xfconf-query -c "$CANAL" -p "$PROPIEDAD" --create --type bool --set false >/dev/null 2>&1 || true
fi

if [[ "${1:-}" == "toggle" ]]; then
    xfconf-query -c "$CANAL" -p "$PROPIEDAD" -T >/dev/null 2>&1 || true
fi

ESTADO="$(xfconf-query -c "$CANAL" -p "$PROPIEDAD" 2>/dev/null || echo false)"
if [[ "$ESTADO" == "true" ]]; then
    echo "☕ Cafeína ACTIVADA"
    [[ "${1:-}" == "toggle" ]] && notify-send "Maospix" "☕ Cafeína activada" || true
else
    echo "☕ Cafeína DESACTIVADA"
    [[ "${1:-}" == "toggle" ]] && notify-send "Maospix" "Cafeína desactivada" || true
fi
