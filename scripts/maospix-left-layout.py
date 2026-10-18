#!/usr/bin/env python3
# Maospix: sync geometry + live stylesheet; no extra daemons.
from pathlib import Path
import subprocess
import re
import sys
home = Path.home()
repo = Path(__file__).resolve().parent.parent
left = home / '.config/maospix-left'
yuck = left / 'eww.yuck'
scss = left / 'eww.scss'
source_css = repo / 'components/left-widgets/eww.scss'
eww = home / '.local/bin/eww'
if not all(p.is_file() for p in (yuck, source_css)):
    sys.exit(0)
state = home / '.config/maospix/tema-actual'
tema = state.read_text().strip() if state.exists() else 'dark'
if tema not in ('dark','neon','retro','nord'): tema = 'dark'
posiciones = (20,260) if tema == 'dark' else (55,295)
# CSS applies same final palette to both widgets even if older Eww keeps a stale class
paletas = {
 'dark': ('#191e1b','#a3ba8d','#e5e9e3','#a3ba8d','#8ca67d','#d6b16b'),
 'neon': ('#121025','#B388FF','#EAE6FF','#42D9FF','#42D9FF','#B388FF'),
 'retro': ('#1b1127','#f052d0','#f0e4ff','#ff6bd9','#7c4dff','#ff6bac'),
 'nord': ('#2e3440','#88c0d0','#eceff4','#88c0d0','#81a1c1','#a3d7df')
}
bg,border,fg,accent,bar1,bar2 = paletas[tema]
classes = ',\n'.join(f'.mpx-card.theme-{n}' for n in paletas)
def subs(suffix):
 return ',\n'.join(f'.mpx-card.theme-{n} {suffix}' for n in paletas)
css = source_css.read_text().rstrip() + f'''
/* MAOSPIX LIVE THEME: {tema} - generado automáticamente */
{classes} {{ background-color: {bg}; border: 2px solid {border}; color: {fg}; }}
{subs('.mpx-title')},
{subs('.mpx-small')},
{subs('.mpx-source')} {{ color: {accent}; }}
{subs('.mpx-temp')},
{subs('.mpx-desc')} {{ color: {fg}; }}
{subs('.mpx-bar')} {{ background-image: linear-gradient(to top, {bar1}, {bar2}); }}
'''
texto=yuck.read_text()
patron=re.compile(r'(?m)^([ \t]*:y ")([0-9]+)px(")')
positions=list(patron.finditer(texto))
if len(positions)!=2:
 print('[ERROR] Geometría inesperada en left Eww',file=sys.stderr);sys.exit(1)
iterpos=iter(posiciones)
nuevo=patron.sub(lambda m: m.group(1)+str(next(iterpos))+'px'+m.group(3),texto)
changed=False
if nuevo!=texto:
 yuck.write_text(nuevo);changed=True
if not scss.is_file() or scss.read_text()!=css:
 scss.parent.mkdir(parents=True,exist_ok=True);scss.write_text(css);changed=True
if changed and eww.is_file():
 cmd=[str(eww),'--config',str(left)]
 if subprocess.run(cmd+['ping'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0:
  subprocess.run(cmd+['reload'],check=False,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
print(f'[OK] Widgets izquierdos: {tema}, {posiciones[0]}/{posiciones[1]}px')
