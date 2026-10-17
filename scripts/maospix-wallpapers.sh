#!/usr/bin/env bash
# MAOSPIX BSPWM - Wallpaper Manager
# Selector con miniaturas y fondos por tema

set -euo pipefail

REPO="$HOME/Proyectos/maospix-bspwm"
ESTADO="$HOME/.config/maospix"
ROFI="$HOME/.config/rofi/themes/maospix-dark.rasi"

TEMA="$(cat "$ESTADO/tema-actual" 2>/dev/null || echo dark)"

case "$TEMA" in
    dark|neon|retro|nord) ;;
    *) TEMA="dark" ;;
esac

DIR="$REPO/wallpapers/$TEMA"
mkdir -p "$ESTADO/wallpapers"

GUARDADO="$ESTADO/wallpapers/$TEMA"

# Buscar las imagenes del tema actual
mapfile -d '' -t IMAGENES < <(
    find "$DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' \
        -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0 | sort -z
)

if (( ${#IMAGENES[@]} == 0 )); then
    notify-send "Maospix" "No hay wallpapers para $TEMA"
    exit 1
fi

# Aplicar el wallpaper guardado al cambiar de tema
if [[ "${1:-}" == "--apply" ]]; then
    IMAGEN="$(cat "$GUARDADO" 2>/dev/null || true)"

    if [[ ! -f "$IMAGEN" || "$IMAGEN" != "$DIR/"* ]]; then
        IMAGEN="${IMAGENES[0]}"
    fi

    feh --bg-fill "$IMAGEN"
    exit 0
fi

# Galeria visual de Rofi
ESTILO='
window { width: 850px; }
listview { columns: 3; lines: 3; fixed-height: false; }
element { orientation: vertical; padding: 8px; }
element-icon { size: 135px; }
element-text { horizontal-align: 0.5; }
'

SELECCION="$(
    for IMAGEN in "${IMAGENES[@]}"; do
        printf '%s\0icon\x1f%s\n' \
            "$(basename "$IMAGEN")" "$IMAGEN"
    done | rofi -dmenu -i -no-custom \
        -show-icons \
        -p "◆ WALLPAPERS ${TEMA^^}" \
        -theme "$ROFI" \
        -theme-str "$ESTILO"
)" || exit 0

# Comprobar que la seleccion pertenece al tema
for IMAGEN in "${IMAGENES[@]}"; do
    if [[ "$(basename "$IMAGEN")" == "$SELECCION" ]]; then
        feh --bg-fill "$IMAGEN"
        printf '%s\n' "$IMAGEN" > "$GUARDADO"

        notify-send "Maospix" \
            "Wallpaper ${TEMA^^} actualizado"
        exit 0
    fi
done
