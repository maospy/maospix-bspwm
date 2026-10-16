#!/usr/bin/env bash
# MAOSPIX - Dock ON/OFF con estado persistente

ESTADO="$HOME/.config/maospix"
mkdir -p "$ESTADO"

if pgrep -x plank >/dev/null; then
    opcion=$(printf 'Ocultar dock\nCancelar\n' |
        rofi -dmenu -i -p "◆ MAOSPIX DOCK")
else
    opcion=$(printf 'Mostrar dock\nCancelar\n' |
        rofi -dmenu -i -p "◆ MAOSPIX DOCK")
fi

case "$opcion" in
    "Mostrar dock")
        printf 'on\n' > "$ESTADO/dock-estado"
        bspc config bottom_padding 75

        if ! pgrep -x plank >/dev/null; then
            nohup plank >/tmp/maospix-plank.log 2>&1 </dev/null &
        fi

        notify-send "Maospix" "Dock activado"
        ;;

    "Ocultar dock")
        printf 'off\n' > "$ESTADO/dock-estado"
        pkill -x plank 2>/dev/null || true
        bspc config bottom_padding 0
        notify-send "Maospix" "Dock desactivado"
        ;;
esac
