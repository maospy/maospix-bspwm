#!/usr/bin/env bash
# MAOSPIX BSPWM - Instalador oficial para Fedora
# Fase 3: comprobacion integrada de componentes

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LISTA="$REPO/packages/fedora-base.txt"
MODO="${1:---check}"

case "$MODO" in
    --check|--check-all|--install-packages|--install) ;;
    *)
        echo "Uso: ./install.sh [--check|--check-all|--install-packages|--install [tema]]"
        exit 1
        ;;
esac

echo "===================================="
echo "       MAOSPIX BSPWM INSTALLER"
echo "===================================="
echo

if [[ ! -f /etc/fedora-release ]]; then
    echo "ERROR: este instalador requiere Fedora."
    exit 1
fi

echo "Sistema: $(cat /etc/fedora-release)"

if [[ ! -f "$LISTA" ]]; then
    echo "ERROR: falta la lista de paquetes."
    exit 1
fi

# Instalacion completa mediante el coordinador
if [[ "$MODO" == "--install" ]]; then

    if (( $# > 2 )); then
        echo "ERROR: demasiados argumentos."
        exit 1
    fi

    TEMA="${2:-dark}"

    case "$TEMA" in
        dark|neon|retro|nord) ;;
        *)
            echo "ERROR: tema desconocido: $TEMA"
            exit 1
            ;;
    esac

    COORDINADOR="$REPO/scripts/maospix-install-components.sh"

    if [[ ! -f "$COORDINADOR" ]]; then
        echo "ERROR: falta el coordinador."
        exit 1
    fi

    echo
    echo "Iniciando instalador Maospix..."
    echo "Tema seleccionado: $TEMA"

    exec bash "$COORDINADOR" --install "$TEMA"
fi

PAQUETES=()

while IFS= read -r paquete || [[ -n "$paquete" ]]; do
    paquete="${paquete%%#*}"
    paquete="${paquete//[$' \t\r']/}"

    [[ -z "$paquete" ]] && continue

    if [[ ! "$paquete" =~ ^[a-zA-Z0-9][a-zA-Z0-9+._-]*$ ]]; then
        echo "ERROR: nombre de paquete invalido: $paquete"
        exit 1
    fi

    PAQUETES+=("$paquete")
done < "$LISTA"

FALTANTES=()

echo
echo "=== PAQUETES FEDORA ==="

for paquete in "${PAQUETES[@]}"; do
    if rpm -q "$paquete" >/dev/null 2>&1; then
        echo "[OK] $paquete"
    else
        echo "[FALTA] $paquete"
        FALTANTES+=("$paquete")
    fi
done

echo
echo "Registrados: ${#PAQUETES[@]}"
echo "Faltantes: ${#FALTANTES[@]}"

if [[ "$MODO" == "--install-packages" ]]; then
    if (( ${#FALTANTES[@]} == 0 )); then
        echo "Todos los paquetes estan instalados."
        exit 0
    fi

    printf '\nPaquetes a instalar:\n'
    printf ' - %s\n' "${FALTANTES[@]}"

    read -r -p "Escribi INSTALAR para continuar: " respuesta

    if [[ "$respuesta" != "INSTALAR" ]]; then
        echo "Operacion cancelada."
        exit 0
    fi

    sudo dnf install -y "${FALTANTES[@]}"
    exit 0
fi

echo
echo "=== ARCHIVOS PRINCIPALES ==="

ARCHIVOS=(
    assets/fonts/MaospixIcon-Regular.ttf
    assets/logo/maospix-nord-braille.txt
    config/fastfetch/maospix-nord.jsonc
    scripts/maospix-fastfetch.sh
    scripts/maospix-theme.sh
    scripts/maospix-wallpapers.sh
)

for archivo in "${ARCHIVOS[@]}"; do
    if [[ -f "$REPO/$archivo" ]]; then
        echo "[OK] $archivo"
    else
        echo "[FALTA] $archivo"
        exit 1
    fi
done

echo
echo "=== TEMAS ==="

for tema in dark neon retro nord; do
    archivo="$REPO/themes/$tema/config/polybar/config.ini"

    if [[ -f "$archivo" ]]; then
        echo "[OK] $tema"
    else
        echo "[FALTA] $tema"
        exit 1
    fi
done

if [[ "$MODO" == "--check-all" ]]; then
    echo
    echo "=== CONFIGURACIONES BASE ==="
    bash "$REPO/scripts/maospix-install-configs.sh" dark --check

    echo
    echo "=== FUENTES ==="
    bash "$REPO/scripts/maospix-install-fonts.sh" --check

    echo

    echo
    echo "=== ENLACES MAOSPIX ==="
    bash "$REPO/scripts/maospix-install-links.sh" --check

    echo
    echo "=== APLICACIONES ==="
    bash "$REPO/scripts/maospix-install-apps.sh" --check

    echo
    echo "=== WALLPAPERS MAOSPIX ==="

    total=0

    for tema in dark neon retro nord; do
        carpeta="$REPO/wallpapers/$tema"

        if [[ ! -d "$carpeta" ]]; then
            echo "[FALTA] wallpapers/$tema"
            exit 1
        fi

        cantidad=$(
            find "$carpeta" -maxdepth 1 -type f \
                \( -name 'Imagen de ChatGPT*.png' \
                -o -name 'Gato hacker en ciudad synthwave neon.png' \) \
                -printf '.' | wc -c
        )

        echo "[OK] $tema: $cantidad wallpapers"
        total=$((total + cantidad))
    done

    echo "Total de wallpapers seleccionados: $total"
fi

echo
echo "Verificacion finalizada."
echo "No se modifico el sistema."
