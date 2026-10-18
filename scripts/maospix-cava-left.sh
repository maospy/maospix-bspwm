#!/usr/bin/env bash
# Maospix - Audio del sistema mediante CAVA
set -o pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"

cava -p "$REPO/components/left-widgets/cava.conf" | \
python3 -u -c '
import sys
import json

for linea in sys.stdin:
    try:
        valores = [
            max(5, min(80, int(float(v) * 0.8)))
            for v in linea.strip().split(";")
            if v.strip()
        ]
        if len(valores) >= 16:
            print(json.dumps(valores[:16]), flush=True)
    except (ValueError, OverflowError):
        continue
'
