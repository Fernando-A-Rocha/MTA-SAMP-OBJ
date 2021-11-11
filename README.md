# SA-MP Map Loader

## Load your favourite SA-MP maps into MTA:SA

### Credits

* Original creator: [gta191977649](https://github.com/gta191977649)
* Extended by: [Fernando](https://github.com/Fernando-A-Rocha) (this fork)
* SA-MP Objects by Rockstar & SA-MP devs

### Features

* Load native TextureStudio exported maps (.pwn format)
* SA-MP Map loading is controlled by the server
* Smart memory allocation (only loads the SA-MP objects that loaded maps use)
* Many debug/error messages & comments to help you understand what's happening
* Easily customizable & extendable

### How to use

* Place map files in [sampobj/maps](sampobj/maps) and models in [sampobj/models](sampobj/models)
* List map files (**name.pwn**) in meta.xml under `<!-- samp maps -->`
* And custom models (**dff + txd + col**) in meta.xml under `<!-- samp models -->`
* Define **maps to load** in [maps/_maplist.lua](sampobj/maps/_maplist.lua)

### Commands

* `/listmaps`: lists all maps defined in mapList and their status
* `/gotomap`: teleports you to a map's TP position defined in mapList
* `/tdo`: (test draw objects) displays object IDs and their replaced textures with material indexes
* `/unloadmap` *(server)*: unloads a map by ID for all players
* `/loadmap` *(server)*: loads a map by ID for all players

### What if my custom model only has dff + txd, how do I get the col?

* Check this tutorial [here](sampobj/models/_TUTORIAL.md)

### Where can I get TextureStudio to make SA-MP maps?

* There will soon be an alternative to **TextureStudio** on MTA with better UI and controls (instead of the huge amount commands you need to know to use the SA-MP version)
* It is true that MTA Map Editor never had way to replace a texture on an object with a certain GTA:SA texture
* This resource implements that, and I believe this feature can one day be available on the MTA Map Editor
* But if you want, you can still download [SA-MP TextureStudio (v1.9c)](https://github.com/Crayder/Texture-Studio/releases/tag/v1.9c)

### Examples

* This resource comes with a few **test maps** that contain custom models for you to see how it works
* Check the `.pwn map files` and the `corresponding models` in the respective folders

### Main functions

* `CreateNewObject(model_id,x,y,z,rx,ry,rz)` 
    * note the model_id can be either SA default object or an id from SA-MP
* `SetObjectMaterial(object,mat_index,model_id,lib_name,txd_name,color)`
    * assigns a default SA texture to an object's texture by material id
    * lib_name is currently ignored (MTA doesn't need it to find the texture)
* `AddSimpleModel(virtualworld, baseid, newid, dffname, txdname)`
    * adds new objects by passing a base model id, the new samp id and the dff + txd names
    * virtualworld is currently ignored

### Issues

* `SetObjectMaterialText` is not yet supported
* `Material Color` is not yet supported
* `AddSimpleModel` doesn't support a SA-MP model as base ID
* High memory usage: MTA currently donesn't support of server-side model allocation, they have to be allocated clientside, which takes up a lot of memory.
