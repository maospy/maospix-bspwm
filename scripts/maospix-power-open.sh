#!/usr/bin/env bash
# MAOSPIX - Abrir Power Menu Eww

EWW="$HOME/.local/bin/eww"
DIR="$HOME/Proyectos/maospix-bspwm/tests/power-menu"

# Abrir el panel; iniciar Eww si no está ejecutándose
if ! "$EWW" --config "$DIR" open maospix_power 2>/dev/null; then
    "$EWW" --config "$DIR" daemon >/tmp/maospix-power-eww.log 2>&1 || true
    sleep 0.5
    "$EWW" --config "$DIR" open maospix_power
fi
