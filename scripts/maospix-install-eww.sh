#!/usr/bin/env bash
# MAOSPIX BSPWM - Instalador de Eww para Fedora X11

set -euo pipefail

MODO="${1:---check}"
VERSION="v0.6.0"
DESTINO="$HOME/.local/bin/eww"

DEPENDENCIAS=(
    git rust cargo gcc pkgconf-pkg-config
    gtk3-devel glib2-devel cairo-devel
    pango-devel gdk-pixbuf2-devel
    libdbusmenu-gtk3-devel
)

case "$MODO" in
    --check|--install) ;;
    *)
        echo "Uso: $0 [--check|--install]"
        exit 1
        ;;
esac

echo "=== MAOSPIX - EWW X11 ==="

FALTANTES=()

for paquete in "${DEPENDENCIAS[@]}"; do
    if rpm -q "$paquete" >/dev/null 2>&1; then
        echo "[OK] $paquete"
    else
        echo "[FALTA] $paquete"
        FALTANTES+=("$paquete")
    fi
done

INSTALADO=false

if [[ -x "$DESTINO" ]]; then
    VERSION_ACTUAL="$("$DESTINO" --version 2>/dev/null || true)"
    echo
    echo "Eww actual: $VERSION_ACTUAL"

    if [[ "$VERSION_ACTUAL" == eww\ 0.6.0* ||
          "$VERSION_ACTUAL" == eww\ 0.5.0\ d87c2fdb* ]]; then
        INSTALADO=true
    fi
else
    echo
    echo "Eww todavía no está instalado."
fi

if [[ "$MODO" == "--check" ]]; then
    echo
    echo "Dependencias faltantes: ${#FALTANTES[@]}"
    echo "Eww 0.6.0 disponible: $INSTALADO"
    echo "Verificación terminada. Sin modificaciones."
    exit 0
fi

if [[ "$INSTALADO" == true ]]; then
    echo "[OK] Eww 0.6.0 ya instalado."
    exit 0
fi

echo
echo "Se instalará Eww $VERSION para X11."
read -r -p "Escribí INSTALAR para continuar: " RESPUESTA

if [[ "$RESPUESTA" != "INSTALAR" ]]; then
    echo "Operación cancelada."
    exit 0
fi

if (( ${#FALTANTES[@]} > 0 )); then
    sudo dnf install -y "${FALTANTES[@]}"
fi

TEMP="$(mktemp -d)"
trap 'rm -rf -- "$TEMP"' EXIT

git clone --depth 1 --branch "$VERSION" \
    https://github.com/elkowar/eww.git "$TEMP/eww"

cd "$TEMP/eww"

# Compatibilidad: dependencia time 0.3.34 falla con Rust reciente (E0282)
cargo update -p time@0.3.34 --precise 0.3.36

cargo build --release --locked \
    --no-default-features --features x11

if [[ -e "$DESTINO" ]]; then
    BACKUP="$HOME/Respaldos-Maospix/eww"
    mkdir -p "$BACKUP"
    cp -p "$DESTINO" \
        "$BACKUP/eww-$(date +%Y%m%d-%H%M%S)"
fi

install -Dm755 target/release/eww "$DESTINO"

echo
echo "[OK] Eww instalado."
"$DESTINO" --version
