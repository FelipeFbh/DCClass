# DCClass

> **Contribuidores:** Juan Cid, Evelyn Avila, Felipe Olivares, Luis Mateu B. y Puntito (_Christopher Marín_)

## Resumen

El objetivo del proyecto se centra en desarrollar un reproductor y editor de contenidos para clases envasadas basadas en una pizarra, con la finalidad de acercar la experiencia educativa remota al formato en vivo.
Se utiliza como base el proyecto [POODLE](./POODLE/README.md).


## Funcionalidades

- Reproductor integrado para ver la clase envasada y su edición en vivo.
- Agrupación de elementos mediante grupos de los elementos para facilitar la organización de la clase.
- Permitir copiar, pegar y eliminar elementos.
- Grabación de audio y de trazos en la pizarra.
- Compatibilidad con tabletas gráficas.
- Camara libre para extender el área de la pizarra.

## Requisitos
- Godot 4.4
- FFmpeg 7.1.1 (full_build)


## Build

Para compilar el proyecto en un ejecutable (`.exe`), basta con ejecutar el `export` desde Godot con los parámetros de `export_presets_DCClass.cfg`. Alternativamente, se puede definir manualmente los siguientes parámetros en el menú de exportación de Godot:

```
# Options
Binary Format:
    Embed PCK : true

#Resources
Filters to export non-resources files/folders:
    *.dcc
```