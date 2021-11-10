# How to generate a .col from a .dff model

## this is for using `AddSimpleModel` to load a custom object

* use kdff [(download here)](kdffgui.zip)
* based on tutorial in RCRP forums [(here)](https://forum.redcountyrp.com/threads/adding-collisions-and-vertex-colors-to-models-using-kdff.199930/)
* 1 - launch kdffgui.exe
* 2 - import the dff using the dff button
* 3 - leave `Optimize` box checked then press `Make Col`
    * Empty: no collision
    * Box: simple box collision (very optimized)
    * Mesh Faces: matches all polygons
* 4 - you have your .col file! don't overwrite existing .dff like the tutorial suggests