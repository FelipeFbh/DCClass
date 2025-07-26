# DCClass

> **Contribuidores:** Felipe Olivares, Luis Mateu B. y Puntito (_Christopher Marín_)

## Resumen

El objetivo del proyecto se centra en desarrollar un reproductor y editor para clases envasadas basadas en una pizarra, con la finalidad de acercar la experiencia educativa remota al formato en vivo.
Se utiliza como base el proyecto [POODLE](./POODLE/README.md).


## Requisitos

- FFmpeg 7.1.1 (full_build)


## Build

Para compilar el proyecto en un ejecutable (`.exe`), basta con ejecutar el `export` desde Godot con los siguientes parámetros de `export_presets_DCClass.cfg`. Alternativamente, se puede definir manualmente los siguientes parámetros en el menú de exportación de Godot:

```
# Options
Binary Format:
    Embed PCK : true

#Resources
Filters to export non-resources files/folders:
    *.dcc
```