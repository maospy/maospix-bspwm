#!/usr/bin/env bash
# MAOSPIX BSPWM - Instalador de fuentes

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
MODO="${1:---check}"

ORIGEN="$REPO/assets/fonts/MaospixIcon-Regular.ttf"
DESTINO="$HOME/.local/share/fonts/MaospixIcon-Regular.ttf"

case "$MODO" in
    --check|--install) ;;
    *)
        echo "Uso: $0 [--check|--install]"
        exit 1
        ;;
esac

echo "=== MAOSPIX BSPWM - FUENTES ==="

if [[ ! -f "$ORIGEN" ]]; then
    echo "[ERROR] Falta MaospixIcon-Regular.ttf"
    exit 1
fi

if [[ -f "$DESTINO" ]] && cmp -s "$ORIGEN" "$DESTINO"; then
    echo "[OK] Fuente Maospix ya instalada"
    exit 0
fi

echo "[PENDIENTE] Instalar fuente Maospix Icon"

if [[ "$MODO" == "--check" ]]; then
    echo "Sin modificaciones."
    exit 0
fi

read -r -p "Escribí INSTALAR para continuar: " RESPUESTA

if [[ "$RESPUESTA" != "INSTALAR" ]]; then
    echo "Instalación cancelada."
    exit 0
fi

if [[ -e "$DESTINO" || -L "$DESTINO" ]]; then
    BACKUP="$HOME/Respaldos-Maospix/fuentes-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP"
    cp -a -- "$DESTINO" "$BACKUP/"
    echo "[BACKUP] $BACKUP"
fi

mkdir -p "$(dirname "$DESTINO")"
cp -p --remove-destination -- "$ORIGEN" "$DESTINO"

if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts"
fi

echo "[OK] Fuente Maospix instalada correctamente."
