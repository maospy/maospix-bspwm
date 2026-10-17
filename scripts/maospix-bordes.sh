#!/usr/bin/env bash
# MAOSPIX BSPWM - Bordes por tema

TEMA=$(cat "$HOME/.config/maospix/tema-actual" 2>/dev/null)

case "$TEMA" in
    dark)
        COLOR="#A3BE8C"
        NORMAL="#303A32"
        ;;
    neon)
        COLOR="#B388FF"
        NORMAL="#292044"
        ;;
    retro)
        COLOR="#FF4FD8"
        NORMAL="#30204B"
        ;;
    nord)
        COLOR="#88C0D0"
        NORMAL="#3B4252"
        ;;
    *)
        echo "Tema desconocido: $TEMA"
        exit 1
        ;;
esac

bspc config focused_border_color "$COLOR"
bspc config active_border_color "$COLOR"
bspc config normal_border_color "$NORMAL"

echo "Maospix: bordes $TEMA aplicados ($COLOR)"
