#!/usr/bin/env bash

# MAOSPIX BSPWM - Control de widgets Eww

EWW="$HOME/.local/bin/eww"

if "$EWW" active-windows | grep -qE 'maospix_clock|maospix_stats'; then
    "$EWW" close-all
else
    "$EWW" open maospix_clock
    "$EWW" open maospix_stats
fi
