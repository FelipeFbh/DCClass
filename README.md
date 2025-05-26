# DCClass
> **Memorista Actual:** Felipe Olivares
> **Profesor Guía:** Luis Mateu B.
> **Contribuidores:** Felipe Olivares, Luis Mateu B. y Puntito (_Christopher Marín_)

## Introducción
El objetivo del proyecto se centra en desarrollar un reproductor y editor para clases envasadas, con la finalidad de acercar la experiencia educativa remota a un formato interactivo y en vivo.

## Objetivo
Diseñar e implementar un editor de clases para el prototipo de la aplicación [POODLE](./README_POODLE.md). Además, de continuar con su desarrollo.

## Guía de Uso - DEV
1. En el el menú principal, accede al editor mediante la opción "Editor -> Open Editor".
2. Una vez en la menú del editor, selecciona la clase a editar.
3. Encontrarás bocetos en la carpeta `/wip`, por ejemplo, el archivo "new_class.poodle".
4. Para crear una nueva clase, edita directamente la carpeta `/wip/new_class/`: modifica el archivo `index.json` para insertar manualmente las entidades que vienen desde `/resources/`.
5. Finaliza el proceso ejecutando el script `export_class.py`. Este comando exportará la clase una vez que la carpeta `new_class` esté completa.