#!/usr/bin/env bash
# MAOSPIX - control de los cuatro widgets con UN SOLO EWW
set -Eeuo pipefail
EWW="$HOME/.local/bin/eww"
ESTADO="$HOME/.config/maospix/widgets-estado"
LOG="$HOME/.cache/maospix-widgets.log"
mkdir -p "$(dirname "$ESTADO")" "$(dirname "$LOG")"
[[ -x "$EWW" ]] || { echo "[ERROR] Falta Eww: $EWW" >&2; exit 1; }
accion="${1:-toggle}"
case "$accion" in toggle|apply|status|on|off) ;; *) echo 'Uso: toggle|apply|status|on|off' >&2; exit 2;; esac
exec 9>"${ESTADO}.lock"
if command -v flock >/dev/null 2>&1; then flock -x 9; fi
actual="$(cat "$ESTADO" 2>/dev/null || echo on)"
[[ "$actual" == on || "$actual" == off ]] || actual=on
case "$accion" in
 status) printf '%s\n' "$actual"; exit 0;;
 toggle) if [[ "$actual" == on ]]; then actual=off; else actual=on; fi;;
 on|off) actual="$accion";;
esac
if [[ "$accion" != apply ]]; then printf '%s\n' "$actual" > "$ESTADO"; fi
if [[ "$actual" == off ]]; then
  if "$EWW" ping >/dev/null 2>&1; then
    for nombre in maospix_clock maospix_stats mpx_weather_window mpx_audio_window; do
      "$EWW" close "$nombre" >>"$LOG" 2>&1 || true
    done
  fi
  echo '[MAOSPIX] WIDGETS OFF'
  exit 0
fi
if ! "$EWW" ping >/dev/null 2>&1; then
  "$EWW" daemon >>"$LOG" 2>&1 || true
  for intento in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    if "$EWW" ping >/dev/null 2>&1; then break; fi
    sleep .15
  done
fi
if ! "$EWW" ping >/dev/null 2>&1; then
  echo "[ERROR] Eww no responde. Revisá $LOG" >&2
  exit 1
fi
# Cierre dirigido para no tocar calendario ni el menú de energía.
for nombre in maospix_clock maospix_stats mpx_weather_window mpx_audio_window; do
  "$EWW" close "$nombre" >>"$LOG" 2>&1 || true
done
fallos=0
for nombre in maospix_clock maospix_stats mpx_weather_window mpx_audio_window; do
  if ! "$EWW" open "$nombre" >>"$LOG" 2>&1; then
    echo "[ERROR] No pudo abrir $nombre (ver $LOG)" >&2
    fallos=1
  fi
done
if [[ "$fallos" == 0 ]]; then echo '[MAOSPIX] WIDGETS ON (4/4)'; fi
exit "$fallos"
