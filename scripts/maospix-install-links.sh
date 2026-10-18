#!/usr/bin/env bash
# MAOSPIX BSPWM - Instalador de scripts auxiliares

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
MODO="${1:---check}"
DESTINO="$HOME/.local/bin"

SCRIPTS=(
    maospix-bluetooth.sh
    maospix-cafe.sh
    maospix-wallpapers.sh
    maospix-widgets.sh
    maospix-theme.sh
    maospix-power-open.sh
    maospix-power-confirm.sh
    maospix-restaurar.sh
    maospix-dock.sh
    maospix-fastfetch.sh
    maospix-cava-left.sh
    maospix-weather-left.py
)

case "$MODO" in
    --check|--install) ;;
    *) echo "Uso: $0 [--check|--install]"; exit 1 ;;
esac

echo "=== MAOSPIX - SCRIPTS AUXILIARES ==="

for nombre in "${SCRIPTS[@]}"; do
    if [[ ! -x "$REPO/scripts/$nombre" ]]; then
        echo "[ERROR] Falta o no es ejecutable: $nombre"
        exit 1
    fi
    echo "[OK] $nombre"
done

if [[ "$MODO" == "--check" ]]; then
    echo "Verificación completada. Sin modificaciones."
    exit 0
fi

read -r -p "Escribí INSTALAR para continuar: " RESPUESTA

if [[ "$RESPUESTA" != "INSTALAR" ]]; then
    echo "Instalación cancelada."
    exit 0
fi

BACKUP="$HOME/Respaldos-Maospix/enlaces-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DESTINO"

for nombre in "${SCRIPTS[@]}"; do
    origen="$REPO/scripts/$nombre"
    destino="$DESTINO/$nombre"

    if [[ -L "$destino" && "$(readlink -f "$destino")" == "$origen" ]]; then
        echo "[IGUAL] $nombre"
        continue
    fi

    if [[ -e "$destino" || -L "$destino" ]]; then
        mkdir -p "$BACKUP"
        mv -- "$destino" "$BACKUP/$nombre"
        echo "[RESPALDADO] $nombre"
    fi

    ln -s "$origen" "$destino"
    echo "[ENLAZADO] $nombre"
done

echo "Instalación de scripts completada."
