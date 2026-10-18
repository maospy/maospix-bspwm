#!/usr/bin/env bash
# Maospix BSPWM - UNICO control de ventanas Eww (toggle/apply/status)
set -Eeuo pipefail
EWW="$HOME/.local/bin/eww"
LEFT="$HOME/.config/maospix-left"
STATE="$HOME/.config/maospix/widgets-estado"
LOG="$HOME/.cache/maospix-widgets.log"
mkdir -p "$(dirname "$STATE")" "$(dirname "$LOG")"
[[ -x "$EWW" ]] || { echo '[ERROR] Eww no instalado' >&2; exit 1; }
exec 9>"${STATE}.lock"
flock -x 9
accion="${1:-toggle}"
case "$accion" in toggle|apply|status) ;; *) echo 'Uso: toggle|apply|status' >&2; exit 2;; esac
if [[ ! -e "$STATE" ]]; then printf 'on\n' > "$STATE"; fi
estado="$(cat "$STATE")"
[[ "$estado" == on || "$estado" == off ]] || estado=on
if [[ "$accion" == status ]]; then printf '%s\n' "$estado"; exit 0; fi
if [[ "$accion" == toggle ]]; then
  if [[ "$estado" == on ]]; then estado=off; else estado=on; fi
  printf '%s\n' "$estado" > "$STATE"
fi
ensure_daemon() {
  if ! "$EWW" "$@" ping >/dev/null 2>&1; then
    "$EWW" "$@" daemon >>"$LOG" 2>&1 || true
    for i in $(seq 1 20); do
      "$EWW" "$@" ping >/dev/null 2>&1 && return 0
      sleep .1
    done
    echo "[ERROR] No inicia Eww $*" | tee -a "$LOG" >&2
    return 1
  fi
}
close_windows() {
  if "$EWW" ping >/dev/null 2>&1; then
    "$EWW" close maospix_clock >/dev/null 2>&1 || true
    "$EWW" close maospix_stats >/dev/null 2>&1 || true
  fi
  if [[ -f "$LEFT/eww.yuck" ]] && "$EWW" --config "$LEFT" ping >/dev/null 2>&1; then
    "$EWW" --config "$LEFT" close mpx_weather_window >/dev/null 2>&1 || true
    "$EWW" --config "$LEFT" close mpx_audio_window >/dev/null 2>&1 || true
  fi
}
open_checked() {
  if ! "$EWW" "$@" >>"$LOG" 2>&1; then
    echo "[ERROR] Eww no pudo abrir: $* (ver $LOG)" >&2
    return 1
  fi
}
if [[ "$estado" == off ]]; then
  close_windows
  echo '[MAOSPIX] WIDGETS OFF'
  exit 0
fi
ensure_daemon
# La sincronización del tema se realiza ANTES de abrir ventanas,
# mientras el lock impide dos comandos simultáneos desde Polybar.
if [[ -f "$LEFT/eww.yuck" ]]; then
  ensure_daemon --config "$LEFT"
fi
close_windows
failures=0
open_checked open maospix_clock || failures=1
open_checked open maospix_stats || failures=1
if [[ -f "$LEFT/eww.yuck" ]]; then
  tema="$(cat "$HOME/.config/maospix/tema-actual" 2>/dev/null || echo dark)"
  case "$tema" in dark|neon|retro|nord) ;; *) tema=dark;; esac
  "$EWW" --config "$LEFT" update "mpx_theme=$tema" >>"$LOG" 2>&1 || true
  open_checked --config "$LEFT" open mpx_weather_window || failures=1
  open_checked --config "$LEFT" open mpx_audio_window || failures=1
fi
printf '[MAOSPIX] WIDGETS ON (errores: %s)\n' "$failures"
exit "$failures"
