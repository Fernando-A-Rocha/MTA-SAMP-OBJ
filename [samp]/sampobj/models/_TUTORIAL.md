# How to generate a .col from a .dff model

## this is for using `AddSimpleModel` to load a custom object

* use kdff [(download here)](/kdffgui.zip)
* based on this tutorial by Earl [(here)](/kdff-guide_backup.png):
* 1 - launch kdffgui.exe
* 2 - import the dff using the dff button
* 3 - leave `Optimize` box checked
* 4 - choose an option:
    * Empty: no collision
    * Box: simple box collision (very optimized)
    * Mesh Faces: matches all polygons
* 5 - press `Make Col` to generate your .col file
* 4 - don't overwrite existing .dff to have it integrate your new collision (not necessary)