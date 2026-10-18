#!/usr/bin/env bash
# MAOSPIX BSPWM - Incorporar capturas reales al README

set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
ORIGEN="${1:-$HOME/Imágenes/Maospix_Capturas}"
README="$REPO/README.md"
DESTINO="$REPO/assets/screenshots"

INICIO="<!-- MAOSPIX-SCREENSHOTS:START -->"
FIN="<!-- MAOSPIX-SCREENSHOTS:END -->"

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

echo "=================================="
echo " MAOSPIX - CAPTURAS PARA README"
echo "=================================="
echo "Repositorio: $REPO"
echo "Origen: $ORIGEN"
echo

[[ -d "$ORIGEN" ]] || error "No existe la carpeta de capturas"
[[ -f "$README" ]] || error "No existe README.md"

for tema in dark neon nord retro; do
    [[ -f "$ORIGEN/$tema.png" ]] || error "Falta $ORIGEN/$tema.png"
done

mkdir -p "$DESTINO"
mkdir -p "$HOME/Respaldos-Maospix/readme"

RESPALDO="$HOME/Respaldos-Maospix/readme/readme-capturas-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESPALDO"

cp -p "$README" "$RESPALDO/README.md.bak"

for tema in dark neon nord retro; do
    if [[ -f "$DESTINO/$tema.png" ]]; then
        cp -p "$DESTINO/$tema.png" "$RESPALDO/$tema.png.bak"
    fi
done

cp -p "$ORIGEN/dark.png"  "$DESTINO/dark.png"
cp -p "$ORIGEN/neon.png"  "$DESTINO/neon.png"
cp -p "$ORIGEN/nord.png"  "$DESTINO/nord.png"
cp -p "$ORIGEN/retro.png" "$DESTINO/retro.png"

echo "[OK] Capturas copiadas a assets/screenshots/"
echo

python3 - "$README" "$INICIO" "$FIN" <<'PY'
from pathlib import Path
import sys

readme = Path(sys.argv[1])
inicio = sys.argv[2]
fin = sys.argv[3]

texto = readme.read_text(encoding="utf-8")

bloque = f"""{inicio}
## 📸 Capturas reales de Maospix BSPWM

Estas son capturas reales de los cuatro temas actuales de **Maospix BSPWM**.

| Dark | Neon |
|------|------|
| ![Maospix Dark](assets/screenshots/dark.png) | ![Maospix Neon](assets/screenshots/neon.png) |

| Nord | Retro |
|------|------|
| ![Maospix Nord](assets/screenshots/nord.png) | ![Maospix Retro](assets/screenshots/retro.png) |
{fin}"""

if inicio in texto and fin in texto:
    a = texto.index(inicio)
    b = texto.index(fin, a) + len(fin)
    nuevo = texto[:a].rstrip() + "\n\n" + bloque + "\n\n" + texto[b:].lstrip("\n")
else:
    if not texto.endswith("\n"):
        texto += "\n"
    nuevo = texto.rstrip() + "\n\n" + bloque + "\n"

readme.write_text(nuevo, encoding="utf-8")
print("[OK] README.md actualizado correctamente")
PY

echo
echo "[OK] Proceso terminado"
echo "Respaldos: $RESPALDO"
echo
echo "=== ESTADO GIT ==="
git -C "$REPO" status --short README.md assets/screenshots/
