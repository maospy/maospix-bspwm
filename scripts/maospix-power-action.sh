#!/usr/bin/env bash
# MAOSPIX - Acciones de energia

set -e

# Breve margen para cerrar la ventana grafica
sleep 0.3

case "${1:-}" in
    bloquear)
        exec light-locker-command -l
        ;;

    suspender)
        notify-send -t 1200 "Maospix" "Suspendiendo equipo..." || true
        exec systemctl suspend
        ;;

    apagar)
        notify-send -t 1200 "Maospix" "Apagando equipo..." || true
        exec systemctl poweroff
        ;;

    reiniciar)
        notify-send -t 1200 "Maospix" "Reiniciando equipo..." || true
        exec systemctl reboot
        ;;

    *)
        echo "Accion no valida" >&2
        exit 1
        ;;
esac
