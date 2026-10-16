#!/usr/bin/env bash

# MAOSPIX BSPWM - Selector de Wallpapers

DIR="$HOME/Imágenes/Wallpapers"
THEME="$HOME/.config/rofi/themes/maospix-dark.rasi"

# Buscar fondos disponibles
fondos=$(find "$DIR" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" \
  -o -iname "*.png" -o -iname "*.webp" \) \
  -printf '%f\n' | sort)

# Verificar si existen fondos
if [ -z "$fondos" ]; then
    notify-send "Maospix" "No hay wallpapers disponibles"
    exit 1
fi

# Mostrar selector Rofi
seleccion=$(printf '%s\n' "$fondos" |
    rofi -dmenu -i \
    -p "Wallpapers" \
    -theme "$THEME")

# Aplicar fondo
if [ -n "$seleccion" ]; then
    feh --bg-fill "$DIR/$seleccion"
fi
