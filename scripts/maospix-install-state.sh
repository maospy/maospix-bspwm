#!/usr/bin/env bash
# MAOSPIX BSPWM - Estado inicial del escritorio

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"

TEMA="${1:-nord}"
MODO="${2:---check}"

case "$TEMA" in
    dark|neon|retro|nord) ;;
    *)
        echo "ERROR: tema desconocido: $TEMA"
        exit 1
        ;;
esac

case "$MODO" in
    --check|--install) ;;
    *)
        echo "Uso: $0 [tema] [--check|--install]"
        exit 1
        ;;
esac

ESTADO="$HOME/.config/maospix"
ROFI="$HOME/.config/rofi/themes/maospix-dark.rasi"

ORIGEN="$REPO/themes/$TEMA/config/rofi/themes/maospix-$TEMA.rasi"

echo "=== MAOSPIX - ESTADO INICIAL ==="
echo "Tema: $TEMA"

# Verificar que exista el tema de Rofi
if [[ ! -f "$ORIGEN" ]]; then
    echo "ERROR: falta la configuración de Rofi:"
    echo "$ORIGEN"
    exit 1
fi

echo "[OK] Configuración de Rofi disponible"

if [[ "$MODO" == "--check" ]]; then
    echo "Verificación completada. Sin modificaciones."
    exit 0
fi

# No sustituir silenciosamente otro tema existente
if [[ -e "$ESTADO/tema-actual" ]]; then
    ACTUAL="$(cat "$ESTADO/tema-actual")"

    if [[ "$ACTUAL" != "$TEMA" ]]; then
        echo "ERROR: ya existe el tema $ACTUAL."
        echo "No se modificarán las preferencias existentes."
        exit 1
    fi
fi

echo
echo "Se preparará el estado inicial del tema $TEMA."
read -r -p "Escribí INSTALAR para continuar: " RESPUESTA

if [[ "$RESPUESTA" != "INSTALAR" ]]; then
    echo "Operación cancelada."
    exit 0
fi

mkdir -p "$ESTADO"
mkdir -p "$(dirname "$ROFI")"

# Tema predeterminado
if [[ ! -e "$ESTADO/tema-actual" ]]; then
    printf '%s\n' "$TEMA" > "$ESTADO/tema-actual"
    echo "[CREADO] tema-actual"
else
    echo "[CONSERVADO] tema-actual"
fi

# Dock predeterminado
if [[ ! -e "$ESTADO/dock-estado" ]]; then
    if [[ "$TEMA" == "dark" ]]; then
        printf 'off\n' > "$ESTADO/dock-estado"
    else
        printf 'on\n' > "$ESTADO/dock-estado"
    fi

    echo "[CREADO] dock-estado"
else
    echo "[CONSERVADO] dock-estado"
fi

# Mostrar cuatro widgets por defecto (respetar preferencia existente)
if [[ ! -e "$ESTADO/widgets-estado" ]]; then
    printf 'on\n' > "$ESTADO/widgets-estado"
    echo "[CREADO] widgets-estado (on)"
else
    echo "[CONSERVADO] widgets-estado"
fi

# Configuración de Rofi
if cmp -s "$ORIGEN" "$ROFI" && [[ ! -L "$ROFI" ]]; then
    echo "[IGUAL] Rofi"
else
    if [[ -e "$ROFI" || -L "$ROFI" ]]; then
        BACKUP="$HOME/Respaldos-Maospix/estado-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP"
        cp -a -- "$ROFI" "$BACKUP/maospix-dark.rasi"
        echo "[RESPALDO] $BACKUP"
    fi

    cp -p --remove-destination -- "$ORIGEN" "$ROFI"
    echo "[INSTALADO] Rofi"
fi

echo
echo "Estado inicial preparado correctamente."
echo "Tema: $(cat "$ESTADO/tema-actual")"
echo "Dock: $(cat "$ESTADO/dock-estado")"
