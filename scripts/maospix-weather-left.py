#!/usr/bin/env python3
# Maospix - Clima usando Open-Meteo
import json
import os
import time
import urllib.parse
import urllib.request
from pathlib import Path

CIUDAD = os.environ.get("MAOSPIX_CITY", "Itauguá")
PAIS = os.environ.get("MAOSPIX_COUNTRY", "PY")
CACHE = Path.home() / ".cache/maospix-weather-left.json"

def solicitar(url, parametros):
    consulta = url + "?" + urllib.parse.urlencode(parametros)
    req = urllib.request.Request(
        consulta, headers={"User-Agent": "Maospix-BSPWM/1.0"}
    )
    with urllib.request.urlopen(req, timeout=8) as respuesta:
        return json.load(respuesta)

def condicion(codigo):
    if codigo == 0:
        return "☀", "Despejado"
    if codigo in (1, 2):
        return "🌤", "Parcialmente nublado"
    if codigo == 3:
        return "☁", "Nublado"
    if codigo in (45, 48):
        return "☁", "Neblina"
    if codigo in (51, 53, 55, 61, 63, 65, 80, 81, 82):
        return "☂", "Lluvia"
    if codigo in (95, 96, 99):
        return "⚡", "Tormenta"
    return "◈", "Variable"

def actualizar():
    geografia = solicitar(
        "https://geocoding-api.open-meteo.com/v1/search",
        {"name": CIUDAD, "count": 1, "countryCode": PAIS,
         "language": "es"},
    )
    lugar = geografia["results"][0]

    datos = solicitar(
        "https://api.open-meteo.com/v1/forecast",
        {
            "latitude": lugar["latitude"],
            "longitude": lugar["longitude"],
            "current": (
                "temperature_2m,relative_humidity_2m,"
                "wind_speed_10m,weather_code"
            ),
            "timezone": "auto",
        },
    )

    actual = datos["current"]
    icono, descripcion = condicion(actual["weather_code"])

    return {
        "city": lugar["name"],
        "temp": str(round(actual["temperature_2m"])),
        "humidity": str(round(actual["relative_humidity_2m"])),
        "wind": str(round(actual["wind_speed_10m"])),
        "icon": icono,
        "desc": descripcion,
    }

try:
    if CACHE.is_file() and time.time() - CACHE.stat().st_mtime < 900:
        resultado = json.loads(CACHE.read_text(encoding="utf-8"))
    else:
        resultado = actualizar()
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(
            json.dumps(resultado, ensure_ascii=False),
            encoding="utf-8",
        )
except (Exception) as error:
    try:
        resultado = json.loads(CACHE.read_text(encoding="utf-8"))
    except Exception:
        resultado = {
            "city": CIUDAD,
            "temp": "--",
            "humidity": "--",
            "wind": "--",
            "icon": "☁",
            "desc": "Sin conexión",
        }

print(json.dumps(resultado, ensure_ascii=False))
