#!/usr/bin/env bash
# MAOSPIX BSPWM - Instalador de configuraciones

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"

TEMA="${1:-dark}"
MODO="${2:---check}"

case "$TEMA" in
    dark|neon|retro|nord) ;;
    *) echo "ERROR: tema desconocido"; exit 1 ;;
esac

case "$MODO" in
    --check|--install) ;;
    *) echo "Uso: $0 [tema] [--check|--install]"; exit 1 ;;
esac

ORIGEN="$REPO/themes/$TEMA/config"
DESTINO="$HOME/.config"

ARCHIVOS=(
    bspwm/bspwmrc
    sxhkd/sxhkdrc
    polybar/config.ini
    picom/picom.conf
    dunst/dunstrc
)

echo "=================================="
echo " MAOSPIX BSPWM - CONFIGURACIONES"
echo "=================================="
echo "Tema: $TEMA"
echo

# Verificar todas las fuentes antes de instalar
FALTANTES=0

for archivo in "${ARCHIVOS[@]}"; do
    src="$ORIGEN/$archivo"
    if [[ -f "$src" ]]; then
        echo "[OK] $archivo"
    else
        echo "[FALTA] $archivo"
        ((FALTANTES+=1))
    fi
done

if (( FALTANTES > 0 )); then
    echo "ERROR: faltan $FALTANTES archivos."
    exit 1
fi

if [[ "$MODO" == "--check" ]]; then
    echo
    echo "Verificación correcta: ${#ARCHIVOS[@]} archivos."
    echo "No se modificó ninguna configuración."
    exit 0
fi

echo
echo "ATENCIÓN: se instalarán configuraciones en:"
echo "$DESTINO"
read -r -p "Escribí INSTALAR para continuar: " RESPUESTA

if [[ "$RESPUESTA" != "INSTALAR" ]]; then
    echo "Operación cancelada."
    exit 0
fi

BACKUP="$HOME/Respaldos-Maospix/instalacion-$(date +%Y%m%d-%H%M%S)"

for archivo in "${ARCHIVOS[@]}"; do
    src="$ORIGEN/$archivo"
    dst="$DESTINO/$archivo"

    if [[ ! -L "$dst" ]] && cmp -s "$src" "$dst"; then
        echo "[IGUAL] $archivo"
        continue
    fi

    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$BACKUP/$(dirname "$archivo")"
        cp -a -- "$dst" "$BACKUP/$archivo"
    fi

    mkdir -p "$(dirname "$dst")"
    cp -p --remove-destination -- "$src" "$dst"

    echo "[INSTALADO] $archivo"
done

echo
echo "Instalación completada."
echo "Respaldos: $BACKUP"
