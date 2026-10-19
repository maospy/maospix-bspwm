#!/usr/bin/env bash
# MAOSPIX BSPWM - Coordinador de instalacion
# Fedora Linux / BSPWM / X11

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
MODO="${1:---check}"
TEMA="${2:-dark}"

case "$MODO" in
    --check|--install) ;;
    *)
        echo "Uso: $0 [--check|--install] [dark|neon|retro|nord]"
        exit 1
        ;;
esac

case "$TEMA" in
    dark|neon|retro|nord) ;;
    *)
        echo "ERROR: Tema desconocido: $TEMA"
        exit 1
        ;;
esac

echo "=========================================="
echo "       MAOSPIX BSPWM - INSTALADOR"
echo "=========================================="
echo
echo "Tema seleccionado: $TEMA"
echo "Repositorio: $REPO"
echo

MODULOS=(
    "install.sh"
    "scripts/maospix-install-fonts.sh"
    "scripts/maospix-install-links.sh"
    "scripts/maospix-install-configs.sh"
    "scripts/maospix-install-state.sh"
    "scripts/maospix-install-apps.sh"
)

echo "=== VERIFICACION DE MODULOS ==="

for modulo in "${MODULOS[@]}"; do
    if [[ ! -f "$REPO/$modulo" ]]; then
        echo "[ERROR] Falta $modulo"
        exit 1
    fi

    bash -n "$REPO/$modulo"
    echo "[OK] $modulo"
done

if [[ "$MODO" == "--check" ]]; then
    echo
    echo "=== COMPROBACION COMPLETA ==="

    bash "$REPO/install.sh" --check-all
    bash "$REPO/scripts/maospix-install-configs.sh" "$TEMA" --check
    bash "$REPO/scripts/maospix-install-state.sh" "$TEMA" --check

    echo
    echo "Todos los modulos fueron revisados."
    echo "No se modifico el sistema."
    exit 0
fi

echo
echo "ATENCION:"
echo "Se instalaran paquetes, fuentes,"
echo "enlaces y configuraciones del tema $TEMA."
echo
echo "Las configuraciones existentes se respaldaran."
echo "No se modificara automaticamente LightDM."
echo

read -r -p "Escribi INSTALAR para continuar: " RESPUESTA

if [[ "$RESPUESTA" != "INSTALAR" ]]; then
    echo "Instalacion cancelada."
    exit 0
fi

# Instalar paquetes Fedora faltantes
printf 'INSTALAR\n' |
    bash "$REPO/install.sh" --install-packages


# Instalar la fuente oficial Maospix
printf 'INSTALAR\n' |
    bash "$REPO/scripts/maospix-install-fonts.sh" --install

# Preparar enlaces auxiliares
printf 'INSTALAR\n' |
    bash "$REPO/scripts/maospix-install-links.sh" --install

# Instalar configuraciones del tema seleccionado
printf 'INSTALAR\n' |
    bash "$REPO/scripts/maospix-install-configs.sh" "$TEMA" --install

# Preparar tema inicial, estado y apariencia de Rofi
printf 'INSTALAR\n' |
    bash "$REPO/scripts/maospix-install-state.sh" "$TEMA" --install

# Brave y CLIAMP son aplicaciones externas: si su servidor está caído,
# no bloquean la instalación del escritorio principal.
echo
 echo "=== APLICACIONES MAOSPIX ==="
if ! bash "$REPO/scripts/maospix-install-apps.sh" --install; then
    echo '[AVISO] Brave o CLIAMP pendientes. Podés reintentar más tarde:'
    echo "  bash '$REPO/scripts/maospix-install-apps.sh' --install"
fi

echo
echo "=========================================="
echo "     COMPONENTES MAOSPIX INSTALADOS"
echo "=========================================="
echo
echo "Paquetes, configuraciones, enlaces y estado inicial preparados."
echo "El inicio gráfico (LightDM) se configura desde maospix.sh."
echo "Validar el primer inicio en una instalación limpia de Fedora."
