#!/usr/bin/env bash
# MAOSPIX - Ejecucion independiente del Power Menu

set -euo pipefail

case "${1:-}" in
    Bloquear) accion="bloquear" ;;
    Suspender) accion="suspender" ;;
    Apagar) accion="apagar" ;;
    Reiniciar) accion="reiniciar" ;;
    *) exit 1 ;;
esac

DIR="$HOME/Proyectos/maospix-bspwm"
EWW="$HOME/.local/bin/eww"
CONFIG="$DIR/tests/power-menu"
LOG="$HOME/.cache/maospix-power.log"

mkdir -p "$HOME/.cache"

# Iniciar accion de forma independiente
nohup "$DIR/scripts/maospix-power-action.sh" "$accion" \
    >> "$LOG" 2>&1 </dev/null &

# Cerrar inmediatamente el panel
"$EWW" --config "$CONFIG" update power_confirm=none \
    >/dev/null 2>&1 || true

"$EWW" --config "$CONFIG" close maospix_power \
    >/dev/null 2>&1 || true
