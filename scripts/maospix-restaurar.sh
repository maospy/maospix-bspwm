#!/usr/bin/env bash
# MAOSPIX - Restaurar escritorio al iniciar sesión

ESTADO="$HOME/.config/maospix"
EWW="$HOME/.local/bin/eww"

TEMA="$(cat "$ESTADO/tema-actual" 2>/dev/null || echo dark)"
DOCK="$(cat "$ESTADO/dock-estado" 2>/dev/null || echo on)"

# Restaurar dock y espacio inferior
if [[ ( "$TEMA" == "neon" || "$TEMA" == "retro" || "$TEMA" == "nord" ) && "$DOCK" != "off" ]]; then
    bspc config bottom_padding 75

    if ! pgrep -x plank >/dev/null; then
        nohup plank >/tmp/maospix-plank.log 2>&1 </dev/null &
    fi
else
    pkill -x plank 2>/dev/null || true
    bspc config bottom_padding 0
fi

# Restaurar widgets del escritorio
if [[ -x "$EWW" ]]; then
    "$EWW" open maospix_clock 2>/dev/null || true
    "$EWW" open maospix_stats 2>/dev/null || true
fi

# Restaurar wallpaper del tema activo
"$HOME/Proyectos/maospix-bspwm/scripts/maospix-wallpapers.sh" --apply || true

# Restaurar colores de bordes del tema activo
"$HOME/Proyectos/maospix-bspwm/scripts/maospix-bordes.sh" || true
