#!/usr/bin/env bash

# MAOSPIX BSPWM - Bluetooth

if [[ "$1" == "toggle" ]]; then
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
        notify-send "Maospix" "Bluetooth desactivado"
    else
        bluetoothctl power on
        notify-send "Maospix" "Bluetooth activado"
    fi
else
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo "ON"
    else
        echo "OFF"
    fi
fi
