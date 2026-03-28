# DCClass

The objective of this project is to develop a player and editor for pre-packaged whiteboard-based lessons, with the aim of making it easier to create and edit classes, as well as supporting various features that enhance the student learning experience.

## Features

- Integrated player to view the class with real-time editing updates.
- Groups of elements to facilitate class organization.
- Copy, paste, and delete elements.
- Lines with different thicknesses and colors.
- Support for images.
- Add pauses to the class so students can understand better.
- Slides: Analogous to physical sheets stacked on top of each other.
- Free-Camera to extend the board area.
- In the mobile version, the camera follows the current drawing position to make it easier to follow the class on small screens.

## Installation

### Requirements

- FFmpeg 7.1.1 (Only needed for the editor version)

### Release

File|Description
:---|:---
[DCClass.exe](https://github.com/FelipeFbh/DCClass/releases/latest) | Editor version for Windows.
[DCClass.x86_64](https://github.com/FelipeFbh/DCClass/releases/latest) | Editor version for Linux.
[DCClass-Mobile.exe](https://github.com/FelipeFbh/DCClass/releases/latest) | Dedicated version for playing classes on mobile screens on Windows.

## Development Requirements

- Godot 4.5
- FFmpeg 7.1.1

## How to Build

To build the project into an executable (`.exe`), just run the Godot export using the settings from `export_presets.cfg`.

## Contributors

See the [CONTRIBUTORS](./CONTRIBUTORS) file to know the list of contributors to this project.

## License

DCClass is licensed under the [MIT License](./LICENSE).

This project was forked from [POODLE](https://github.com/PuntitOwO/poodle), which is licensed under the [MIT License](https://github.com/PuntitOwO/poodle/blob/main/LICENSE.md).

See [THIRD_PARTY_LICENSES](./THIRD_PARTY_LICENSES) for details.
