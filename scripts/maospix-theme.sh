
#!/usr/bin/env bash
# MAOSPIX BSPWM - Selector Dark / Neon
# Plank automatico en Neon y opcional desde Rofi

set -e

REPO="$HOME/Proyectos/maospix-bspwm"
BACKUP="$HOME/Respaldos-Maospix/antes-selector"
EWW="$HOME/.local/bin/eww"
ESTADO="$HOME/.config/maospix"

# Mostrar selector
opcion=$(printf 'Dark\nNeon\nRetro\nCancelar\n' |
    rofi -dmenu -i -p "◆ MAOSPIX - TEMA") || exit 0

case "$opcion" in
    Dark|Neon|Retro) ;;
    *) exit 0 ;;
esac

tema="${opcion,,}"
BASE="$REPO/themes/$tema/config"

# Verificar archivos
for archivo in \
    "$BASE/polybar/config.ini" \
    "$BASE/eww/eww.yuck" \
    "$BASE/eww/eww.scss" \
    "$BASE/rofi/themes/maospix-$tema.rasi"; do

    if [[ ! -f "$archivo" ]]; then
        notify-send "Maospix" "Falta: $archivo"
        exit 1
    fi
done

# Respaldar configuracion original
mkdir -p "$BACKUP" "$ESTADO"

cp -n "$HOME/.config/polybar/config.ini" \
    "$BACKUP/polybar.ini"

cp -n "$HOME/.config/eww/eww.yuck" \
    "$BACKUP/eww.yuck"

cp -n "$HOME/.config/eww/eww.scss" \
    "$BACKUP/eww.scss"

cp -n "$HOME/.config/rofi/themes/maospix-dark.rasi" \
    "$BACKUP/rofi.rasi"

# Aplicar tema
cp "$BASE/polybar/config.ini" \
    "$HOME/.config/polybar/config.ini"

cp "$BASE/eww/eww.yuck" \
    "$HOME/.config/eww/eww.yuck"

cp "$BASE/eww/eww.scss" \
    "$HOME/.config/eww/eww.scss"

cp "$BASE/rofi/themes/maospix-$tema.rasi" \
    "$HOME/.config/rofi/themes/maospix-dark.rasi"

# Actualizar Eww
if [[ -x "$EWW" ]]; then
    "$EWW" close-all 2>/dev/null || true
    "$EWW" reload || true
    "$EWW" open maospix_clock || true
    "$EWW" open maospix_stats || true
fi

# Dock segun tema
if [[ "$tema" == "dark" ]]; then

    # DARK: Polybar abajo, sin dock
    pkill -x plank 2>/dev/null || true
    bspc config bottom_padding 0

elif [[ "$tema" == "neon" || "$tema" == "retro" ]]; then
    printf 'on\n' > "$ESTADO/dock-estado" 

    # NEON: Plank activado por defecto
    bspc config bottom_padding 75

    if ! pgrep -x plank >/dev/null; then
        nohup plank \
            > /tmp/maospix-plank.log 2>&1 < /dev/null &
    fi

fi

# Actualizar Polybar
polybar-msg cmd restart >/dev/null 2>&1 || true

# Guardar tema seleccionado
printf '%s\n' "$tema" > "$ESTADO/tema-actual"

notify-send "Maospix" "Tema $opcion aplicado"
