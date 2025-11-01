# DCClass

El objetivo del proyecto se centra en desarrollar un reproductor y editor de contenidos para clases envasadas basadas en una pizarra, con la finalidad de facilitar la realización y edición de clases, además de admitir diversas funcionalidades que mejoren la experiencia del estudiante.

## Features

- Reproductor integrado para ver la clase envasada y su edición en vivo.
- Agrupación de elementos mediante grupos para facilitar la organización de la clase.
- Permitir copiar, pegar y eliminar elementos.
- Grabación de audio.
- Trazos con diferentes grosores y colores.
- Soporte para imágenes.
- Control de la reproducción para insertar pausas.
- Slides: Son análogas a hojas físicas que se suporponen.
- Compatibilidad con tabletas gráficas.
- Camara libre para extender el área de la pizarra. Además, permite al docente controlar la vista del estudiante.

## Installation

### Requirements

- FFmpeg 7.1.1 (Only needed for the editor version)

### Release

File|Description
:---|:---
[DCClass.exe](https://github.com/FelipeFbh/DCClass/releases/latest) | Editor version for Windows.
[DCClass-Mobile.exe](https://github.com/FelipeFbh/DCClass/releases/latest) | Dedicated version for playing classes on mobile screens on Windows.

## Development Requirements

- Godot 4.5
- FFmpeg 7.1.1

## How to Build

To build the project into an executable (`.exe`), just run the Godot export using the settings from `export_presets_DCClass.cfg`.

## Contributors

See the [CONTRIBUTORS](./CONTRIBUTORS) file to know the list of contributors to this project.

## License

DCClass is licensed under the [MIT License](./LICENSE).

This project was forked from [POODLE](https://github.com/PuntitOwO/poodle), which is licensed under the [MIT License](https://github.com/PuntitOwO/poodle/blob/main/LICENSE.md).

See [THIRD_PARTY_LICENSES](./THIRD_PARTY_LICENSES) for details.
