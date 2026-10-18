#!/usr/bin/env python3
from pathlib import Path
import subprocess
import re
import sys

home = Path.home()
left = home / ".config/maospix-left"
yuck = left / "eww.yuck"
eww = home / ".local/bin/eww"

if not yuck.is_file() or not eww.is_file():
    sys.exit(0)

estado = home / ".config/maospix/tema-actual"
tema = estado.read_text().strip() if estado.is_file() else "nord"

# Dark usa Polybar inferior; los demás Polybar superior
if tema == "dark":
    posiciones = [20, 260]
else:
    posiciones = [55, 295]

texto = yuck.read_text()

patron = re.compile(r'(?m)^([ \t]*:y ")([0-9]+)px(")')
coincidencias = list(patron.finditer(texto))

if len(coincidencias) != 2:
    print("ERROR: posiciones Eww inesperadas", file=sys.stderr)
    sys.exit(1)

actuales = [int(m.group(2)) for m in coincidencias]

if actuales[0] not in (20, 55) or actuales[1] not in (260, 295):
    print("ERROR: geometría desconocida", file=sys.stderr)
    sys.exit(1)

comando = [str(eww), "--config", str(left)]

resultado = subprocess.run(
    comando + ["active-windows"],
    capture_output=True,
    text=True
)

activos = resultado.stdout

ventanas = [
    "mpx_weather_window",
    "mpx_audio_window"
]

abiertas = [v for v in ventanas if v in activos]

# Cerrar solo las ventanas que ya estaban abiertas
for ventana in abiertas:
    subprocess.run(comando + ["close", ventana], check=False)

indice = iter(posiciones)

nuevo = patron.sub(
    lambda m: m.group(1) + str(next(indice)) + 'px' + m.group(3),
    texto
)

if nuevo != texto:
    yuck.write_text(nuevo)

# Si todavía no hay daemon, solo preparar el archivo de la sesión.
if subprocess.run(comando + ["ping"], capture_output=True).returncode == 0:
    subprocess.run(comando + ["reload"], check=True)

# Respetar el estado del botón WIDGETS
for ventana in abiertas:
    subprocess.run(comando + ["open", ventana], check=True)

print(f"[OK] Tema {tema}: clima {posiciones[0]}px, audio {posiciones[1]}px")
