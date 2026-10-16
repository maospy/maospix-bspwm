#!/usr/bin/env bash

# MAOSPIX BSPWM - Menu de energia

THEME="$HOME/.config/rofi/themes/maospix-dark.rasi"

opcion=$(printf '%s\n' \
    "Apagar" \
    "Reiniciar" \
    "Cerrar sesión" \
    "Cancelar" |
    rofi -dmenu -i -p "MAOSPIX ENERGÍA" -theme "$THEME")

case "$opcion" in
    "Apagar"|"Reiniciar"|"Cerrar sesión")
        confirmar=$(printf 'No\nSí\n' |
            rofi -dmenu -p "¿Confirmar $opcion?" -theme "$THEME")

        [[ "$confirmar" == "Sí" ]] || exit 0

        case "$opcion" in
            "Apagar") systemctl poweroff ;;
            "Reiniciar") systemctl reboot ;;
            "Cerrar sesión") bspc quit ;;
        esac
        ;;
esac
