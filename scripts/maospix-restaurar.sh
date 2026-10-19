#!/usr/bin/env bash
# MAOSPIX - Restaurar escritorio al iniciar sesión

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
ESTADO="$HOME/.config/maospix"

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

    if [[ "$TEMA" == "dark" ]]; then
        bspc config bottom_padding 40
    else
        bspc config bottom_padding 0
    fi
fi

# XFCE Power Manager: la propiedad no existe en Fedora recién instalado
if command -v xfconf-query >/dev/null 2>&1; then
    PROP="/xfce4-power-manager/presentation-mode"
    if ! xfconf-query -c xfce4-power-manager -p "$PROP" >/dev/null 2>&1; then
        xfconf-query -c xfce4-power-manager -p "$PROP" --create --type bool --set false >/dev/null 2>&1 || true
    fi
    TRAY="/xfce4-power-manager/show-tray-icon"
    xfconf-query -c xfce4-power-manager -p "$TRAY" --set false >/dev/null 2>&1 || \
      xfconf-query -c xfce4-power-manager -p "$TRAY" --create --type bool --set false >/dev/null 2>&1 || true
fi


# Restaurar wallpaper del tema activo
"$REPO/scripts/maospix-wallpapers.sh" --apply || true

# Restaurar colores de bordes
"$REPO/scripts/maospix-bordes.sh" || true
