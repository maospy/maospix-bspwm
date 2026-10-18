#!/usr/bin/env bash
# Maospix BSPWM - Control centralizado de los cuatro widgets
set -euo pipefail

EWW="$HOME/.local/bin/eww"
LEFT="$HOME/.config/maospix-left"
STATE="$HOME/.config/maospix/widgets-estado"

mkdir -p "$(dirname "$STATE")"

# Evita arranques Eww duplicados si Polybar y el inicio de sesión actúan juntos.
exec 9>"${STATE}.lock"
flock -x 9

if [[ ! -x "$EWW" ]]; then
    echo "ERROR: Eww no está disponible"
    exit 1
fi

visible() {
    local right left
    right="$("$EWW" active-windows 2>/dev/null || true)"
    left=""

    if [[ -f "$LEFT/eww.yuck" ]]; then
        left="$("$EWW" --config "$LEFT" active-windows 2>/dev/null || true)"
    fi

    [[ "$right" == *maospix_clock* ||
       "$right" == *maospix_stats* ||
       "$left" == *mpx_weather_window* ||
       "$left" == *mpx_audio_window* ]]
}

hide_all() {
    "$EWW" close maospix_clock 2>/dev/null || true
    "$EWW" close maospix_stats 2>/dev/null || true

    if [[ -f "$LEFT/eww.yuck" ]]; then
        "$EWW" --config "$LEFT" close mpx_weather_window 2>/dev/null || true
        "$EWW" --config "$LEFT" close mpx_audio_window 2>/dev/null || true
    fi
}

show_all() {
    if ! "$EWW" ping >/dev/null 2>&1; then
        "$EWW" daemon
        sleep 1
    fi

    "$EWW" open maospix_clock 2>/dev/null || true
    "$EWW" open maospix_stats 2>/dev/null || true

    if [[ -f "$LEFT/eww.yuck" ]]; then
        if ! "$EWW" --config "$LEFT" ping >/dev/null 2>&1; then
            "$EWW" --config "$LEFT" daemon
            sleep 1
        fi

        "$EWW" --config "$LEFT" open mpx_weather_window 2>/dev/null || true
        "$EWW" --config "$LEFT" open mpx_audio_window 2>/dev/null || true
    fi
}

ACTION="${1:-toggle}"

case "$ACTION" in
    toggle)
        if visible; then
            printf 'off\n' > "$STATE"
            hide_all
            echo "[MAOSPIX] Widgets OFF"
        else
            printf 'on\n' > "$STATE"
            show_all
            echo "[MAOSPIX] Widgets ON"
        fi
        ;;

    apply)
        if [[ "$(cat "$STATE" 2>/dev/null || echo on)" == "off" ]]; then
            hide_all
        else
            show_all
        fi
        ;;

    status)
        cat "$STATE" 2>/dev/null || echo on
        ;;

    *)
        echo "Uso: $0 {toggle|apply|status}"
        exit 1
        ;;
esac
