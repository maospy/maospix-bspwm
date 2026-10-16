#!/usr/bin/env bash
# MAOSPIX BSPWM - Modo Cafeína

CANAL="xfce4-power-manager"
PROPIEDAD="/xfce4-power-manager/presentation-mode"

if [[ "$1" == "toggle" ]]; then
    xfconf-query -c "$CANAL" -p "$PROPIEDAD" -T
fi

ESTADO=$(xfconf-query -c "$CANAL" -p "$PROPIEDAD")

if [[ "$ESTADO" == "true" ]]; then
    echo "☕ Cafeína ACTIVADA"
    [[ "$1" == "toggle" ]] && notify-send "Maospix" "☕ Cafeína activada"
else
    echo "☕ Cafeína DESACTIVADA"
    [[ "$1" == "toggle" ]] && notify-send "Maospix" "Cafeína desactivada"
fi
