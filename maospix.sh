#!/usr/bin/env bash
# MAOSPIX BSPWM - Instalador descargable para Fedora
set -Eeuo pipefail

MODO="${1:---check}"
TEMA="${2:-nord}"
URL="https://github.com/maospy/maospix-bspwm.git"
DESTINO="$HOME/.local/share/maospix-bspwm"

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

[[ $# -le 2 ]] || error "Demasiados argumentos"

case "$MODO" in
    --check|--install) ;;
    *) error "Uso: bash maospix.sh [--check|--install] [tema]" ;;
esac

case "$TEMA" in
    dark|neon|retro|nord) ;;
    *) error "Tema desconocido: $TEMA" ;;
esac

[[ $EUID -ne 0 ]] || error "Ejecutar como usuario normal, sin sudo"

[[ -f /etc/fedora-release ]] ||
    error "Maospix requiere Fedora Linux"

echo "==================================="
echo "    MAOSPIX BSPWM - FEDORA"
echo "==================================="
echo "Modo: $MODO"
echo "Tema: $TEMA"
echo

if [[ "$MODO" == "--install" ]]; then
    read -r -p "Escribí INSTALAR para continuar: " RESPUESTA
    [[ "$RESPUESTA" == "INSTALAR" ]] || exit 0
fi

# Usar proyecto local o descargar desde GitHub
CARPETA="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$CARPETA/install.sh" &&
      -f "$CARPETA/scripts/maospix-install-components.sh" ]]; then
    REPO="$CARPETA"
else
    if ! command -v git >/dev/null; then
        if [[ "$MODO" == "--check" ]]; then
            error "Falta Git. Instalalo o ejecutá --install"
        fi
        sudo dnf install -y git
    fi

    if [[ ! -d "$DESTINO/.git" ]]; then
        [[ ! -e "$DESTINO" ]] ||
            error "Destino ocupado: $DESTINO"

        mkdir -p "$(dirname "$DESTINO")"
        git clone --depth 1 "$URL" "$DESTINO" ||
            error "No se pudo descargar el repositorio"
    fi

    ORIGEN="$(git -C "$DESTINO" remote get-url origin)"
    [[ "$ORIGEN" == "$URL" ]] ||
        error "El repositorio existente tiene otro origen"

    REPO="$DESTINO"
fi

echo
echo "Repositorio: $REPO"

[[ -f "$REPO/packages/fedora-base.txt" ]] ||
    error "Falta la lista de paquetes"

[[ -f "$REPO/scripts/maospix-install-state.sh" ]] ||
    error "Falta el instalador del estado inicial"

echo
echo "=== PAQUETES FEDORA ==="

FALTANTES=0

while IFS= read -r PAQUETE || [[ -n "$PAQUETE" ]]; do
    PAQUETE="${PAQUETE%%#*}"
    PAQUETE="${PAQUETE//[$' \t\r']/}"
    [[ -z "$PAQUETE" ]] && continue

    if rpm -q "$PAQUETE" >/dev/null 2>&1; then
        echo "[OK] $PAQUETE"
    else
        echo "[FALTA] $PAQUETE"
        ((FALTANTES+=1))
    fi
done < "$REPO/packages/fedora-base.txt"

echo
echo "Paquetes faltantes: $FALTANTES"

if [[ "$MODO" == "--check" ]]; then
    echo "Revisión terminada. No se instalaron paquetes."
    exit 0
fi

# Dependencias para compilar Eww si todavía no existe
if [[ ! -x "$HOME/.local/bin/eww" ]]; then
    echo
    echo "=== PREPARANDO EWW X11 ==="

    sudo dnf install -y \
        git rust cargo gcc pkgconf-pkg-config \
        gtk3-devel glib2-devel cairo-devel \
        pango-devel gdk-pixbuf2-devel \
        libdbusmenu-gtk3-devel
fi

echo
echo "=== INSTALANDO COMPONENTES ==="

printf 'INSTALAR\n' |
    bash "$REPO/install.sh" --install "$TEMA"

# Comprobar resultados antes de finalizar
[[ -f "$HOME/.config/bspwm/bspwmrc" ]] ||
    error "No se instaló bspwmrc"

[[ -f "$HOME/.config/maospix/tema-actual" ]] ||
    error "No se preparó el tema inicial"

[[ "$(cat "$HOME/.config/maospix/tema-actual")" == "$TEMA" ]] ||
    error "El tema instalado no coincide"

[[ -x "$HOME/.local/bin/eww" ]] ||
    error "Eww no quedó instalado"

# Fastfetch en Kitty
mkdir -p "$HOME/.local/bin"

DEST_FASTFETCH="$HOME/.local/bin/maospix-fastfetch.sh"

if [[ ! -e "$DEST_FASTFETCH" && ! -L "$DEST_FASTFETCH" ]]; then
    ln -s "$REPO/scripts/maospix-fastfetch.sh" "$DEST_FASTFETCH"
fi

touch "$HOME/.bashrc"

if ! grep -qF '# MAOSPIX FASTFETCH KITTY' "$HOME/.bashrc"; then
    mkdir -p "$HOME/Respaldos-Maospix"
    cp -p "$HOME/.bashrc" \
        "$HOME/Respaldos-Maospix/bashrc-antes-maospix.bak"

    cat >> "$HOME/.bashrc" <<'BASHRC'

# MAOSPIX FASTFETCH KITTY
if [[ $- == *i* && "${TERM:-}" == "xterm-kitty" && -z "${SSH_CONNECTION:-}" ]]; then
    if [[ -x "$HOME/.local/bin/maospix-fastfetch.sh" ]]; then
        "$HOME/.local/bin/maospix-fastfetch.sh"
    fi
fi
BASHRC
fi

echo
echo "=== INICIO GRÁFICO ==="

if systemctl is-enabled --quiet gdm.service ||
   systemctl is-enabled --quiet sddm.service; then
    echo "Ya existe otro gestor de inicio habilitado."
    echo "Seleccioná BSPWM al iniciar sesión."
else
    sudo systemctl enable lightdm.service
    sudo systemctl set-default graphical.target
    echo "[OK] LightDM preparado para el próximo reinicio"
fi

echo
echo "==================================="
echo "    MAOSPIX - INSTALACIÓN FINALIZADA"
echo "==================================="
echo "Tema inicial: $TEMA"
echo "Repositorio: $REPO"
echo "Reiniciá cuando estés preparado."
