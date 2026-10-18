#!/usr/bin/env bash
# Maospix - Apps solicitadas: navegador Brave y reproductor CLIAMP
set -euo pipefail
[[ -f /etc/fedora-release ]] || { echo 'ERROR: requiere Fedora'; exit 1; }
[[ $EUID -ne 0 ]] || { echo 'ERROR: ejecutar como usuario, sin sudo'; exit 1; }
MODO="${1:---install}"
case "$MODO" in --check|--install) ;; *) echo 'Uso: --check|--install'; exit 2;; esac

CLIAMP_VERSION=v1.63.1
CLIAMP_SHA_AMD64=4754a374a17e2dcd3519665a43827b8c77853c874667ee3c97574a1d32d6bffc
CLIAMP_SHA_ARM64=62de249cf7e728bc1abd6d6b58462c875e120e540715b7cdfdb90b1fa5c13f18

if command -v brave-browser >/dev/null 2>&1; then echo '[OK] Brave'; else echo '[FALTA] Brave'; fi
if command -v cliamp >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/cliamp" ]]; then echo '[OK] CLIAMP'; else echo '[FALTA] CLIAMP'; fi
if [[ "$MODO" == --check ]]; then exit 0; fi

# Se necesita curl también si Brave ya estaba instalado.
if ! command -v curl >/dev/null 2>&1; then
    sudo dnf install -y curl
fi

# Brave: repositorio RPM oficial, Fedora 41+ (DNF5).
if ! rpm -q brave-browser >/dev/null 2>&1; then
    echo '=== Instalando Brave (repositorio oficial) ==='
    sudo dnf install -y dnf-plugins-core curl
    if [[ ! -f /etc/yum.repos.d/brave-browser.repo ]]; then
        sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    fi
    sudo dnf install -y brave-browser
fi

# CLIAMP: binario publicado con SHA256 fijado para no ejecutar scripts remotos.
if ! command -v cliamp >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/cliamp" ]]; then
    echo '=== Instalando CLIAMP (binario verificado) ==='
    case "$(uname -m)" in
        x86_64) arch=amd64; esperado="$CLIAMP_SHA_AMD64" ;;
        aarch64) arch=arm64; esperado="$CLIAMP_SHA_ARM64" ;;
        *) echo '[AVISO] CLIAMP no está preparado para esta arquitectura'; exit 0 ;;
    esac
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT
    curl -fL --retry 2 --connect-timeout 15 -o "$TMP/cliamp" \
        "https://github.com/bjarneo/cliamp/releases/download/$CLIAMP_VERSION/cliamp-linux-$arch"
    printf '%s  %s\n' "$esperado" "$TMP/cliamp" | sha256sum -c -
    curl -fL --retry 2 --connect-timeout 15 -o "$TMP/LICENSE" \
        "https://raw.githubusercontent.com/bjarneo/cliamp/$CLIAMP_VERSION/LICENSE"
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/licenses/cliamp" "$HOME/.local/share/applications"
    install -m 755 "$TMP/cliamp" "$HOME/.local/bin/cliamp"
    install -m 644 "$TMP/LICENSE" "$HOME/.local/share/licenses/cliamp/LICENSE"
fi

# Acceso en menús de aplicaciones, sin forzar iconos en el Dock del usuario.
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/maospix-cliamp.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=CLIAMP
Comment=Reproductor de música en terminal
Exec=kitty -e cliamp
Icon=multimedia-player
Terminal=false
Categories=Audio;AudioVideo;Player;
DESKTOP

printf '[OK] Brave y CLIAMP preparados. CLIAMP se inicia con: cliamp\n'
