# 🐱 Maospix BSPWM

**Un escritorio moderno, ligero y personalizable basado en Fedora Linux, BSPWM y X11.**

Maospix BSPWM es un proyecto de personalización de escritorio que combina un gestor de ventanas ligero con componentes visuales modernos, temas intercambiables, widgets y herramientas integradas.

Su objetivo es ofrecer una experiencia visual completa mediante un instalador automatizado para Fedora Linux y, posteriormente, una imagen ISO propia.

> **Estado del proyecto:** versión de desarrollo (Alpha).
> El instalador todavía requiere pruebas completas en una instalación limpia de Fedora.

---

## 🎨 Temas disponibles

| Tema | Descripción |
|------|-------------|
| Dark | Oscuro, elegante y minimalista |
| Neon | Estilo futurista con tonos violetas y cian |
| Retro | Inspirado en Synthwave y Retrowave |
| Nord | Tonos azules fríos y estética tecnológica |

Todos los temas incluyen configuraciones personalizadas para Polybar, Eww y otros componentes del escritorio.

### Capturas de pantalla

Las capturas del escritorio completo serán incorporadas después de validar la primera versión instalable.

---

## 🖥️ Componentes

| Componente | Tecnología |
|------------|------------|
| Sistema base | Fedora Linux |
| Servidor gráfico | Xorg / X11 |
| Gestor de ventanas | BSPWM |
| Atajos de teclado | SXHKD |
| Barra superior | Polybar |
| Terminal principal | Kitty |
| Terminal alternativa | Alacritty |
| Lanzador de aplicaciones | Rofi |
| Widgets | Eww |
| Información del sistema | Fastfetch |
| Compositor | Picom |
| Notificaciones | Dunst |
| Dock | Plank |
| Fondos de pantalla | Feh |
| Pantalla de inicio de sesión | LightDM |
| Bloqueo | Light Locker |

Maospix incluye un Power Menu personalizado, selector de temas y galería visual de wallpapers.

---

## 📋 Requisitos

- Fedora Linux 44 como entorno inicial de desarrollo y pruebas.
- Conexión a Internet.
- Usuario normal con permisos sudo.
- Git para descargar el repositorio.
- Espacio disponible para instalar paquetes y compilar Eww.

Se recomienda probar inicialmente en una máquina virtual o instalación limpia.

**No se recomienda ejecutar todavía el instalador sobre un sistema de producción.**

---

## 🚀 Instalación en Fedora

### 1. Preparar Fedora

Actualizar el sistema:

    sudo dnf upgrade --refresh

Instalar Git:

    sudo dnf install git

### 2. Descargar Maospix

Por HTTPS, con acceso autorizado al repositorio:

    git clone https://github.com/maospy/maospix-bspwm.git

Alternativamente, mediante SSH previamente configurado:

    git clone git@github.com:maospy/maospix-bspwm.git

Entrar al proyecto:

    cd maospix-bspwm

### 3. Comprobar los requisitos

    bash maospix.sh --check nord

El instalador mostrará los paquetes presentes y los faltantes.

### 4. Instalar Maospix

    bash maospix.sh --install nord

Para seleccionar otro tema inicial:

    bash maospix.sh --install dark
    bash maospix.sh --install neon
    bash maospix.sh --install retro

El instalador solicitará confirmación antes de proceder.

**Importante:** la instalación completa todavía no está validada en Fedora limpio. Realizarla únicamente en un entorno de pruebas y revisar las modificaciones propuestas.

### 5. Iniciar sesión

Una vez completada satisfactoriamente la instalación, reiniciar cuando corresponda y seleccionar BSPWM desde el gestor de sesiones.

Si el sistema ya utiliza otro gestor de sesiones, el instalador no garantiza sustituirlo automáticamente por LightDM.

---

## 📁 Organización del proyecto

| Directorio o archivo | Función |
|----------------------|---------|
| `maospix.sh` | Instalador descargable |
| `install.sh` | Instalador principal |
| `packages/` | Dependencias Fedora |
| `scripts/` | Instaladores y funciones auxiliares |
| `themes/` | Configuraciones de los cuatro temas |
| `components/` | Componentes visuales |
| `assets/` | Logos y fuentes |
| `config/` | Configuraciones generales |
| `wallpapers/` | Fondos seleccionados |
| `docs/` | Documentación del proyecto |

---

## 🔒 Estado del repositorio

Actualmente, Maospix BSPWM se desarrolla en un repositorio privado de GitHub.

Las descargas requieren acceso autorizado hasta que se decida publicar oficialmente el proyecto.

---

## ⚠️ Advertencias

El instalador puede instalar paquetes y modificar configuraciones del usuario.

Algunos módulos realizan respaldos en `~/Respaldos-Maospix/`, pero todavía no existe una garantía de recuperación integral ni un desinstalador completo.

No utilizar el instalador con `sudo bash`; debe ejecutarse desde una cuenta de usuario normal.

---

## 🛠️ Próximos objetivos

- Validar la instalación completa en Fedora limpio.
- Corregir las dependencias y configuraciones detectadas durante las pruebas.
- Completar la documentación y las capturas de pantalla.
- Publicar una primera versión estable del instalador.
- Crear una ISO Live basada en Fedora con Maospix BSPWM preconfigurado.

---

## 🖼️ Wallpapers y recursos

El repositorio incorpora wallpapers seleccionados para Maospix.

Otros fondos utilizados durante el desarrollo no se incluyen mientras no se verifiquen sus derechos de redistribución.

Consultar `docs/wallpapers-auditoria.md`.

---

## 👨‍💻 Proyecto

**Maospix BSPWM**

Desarrollado y personalizado por maospy.

Repositorio: https://github.com/maospy/maospix-bspwm

**Estado actual: Alpha — en desarrollo.**
