![Banner](https://i.imgur.com/8cfN2d9.png)

### Please read everything - thank you 💖

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

### ⚠️ Warning ⚠️

* This resource is still rather experimental! Help is much appreciated
* **Minimum MTA versions** (from [https://nightly.mtasa.com/](https://nightly.mtasa.com/))
* Client: `1.5.9-9.21026.0`
* Server: `1.5.9-9.21024.0`

### How to install

* Get the latest stable release: [here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/releases/latest)
* Create a `[samp]` folder in your server's resources, and place the downloaded `sampobj` resource folder inside

### How to use

* Place map files in [sampobj/maps](sampobj/maps) and models in [sampobj/models](sampobj/models)
* List map files (**name.pwn**) in meta.xml under `<!-- samp maps -->`
* And custom models (**dff + txd + col**) in meta.xml under `<!-- samp models -->`
* Define **maps to load** in [maps/_maplist.lua](sampobj/maps/_maplist.lua)
* Configure how you want to see debug messages in [scripts/_debug.lua](sampobj/scripts/_debug.lua)
* Launch your server and `start sampobj` to initiate the resource

### What if my custom model only has dff + txd, how do I get the col?

* Check this tutorial [here](sampobj/models/_TUTORIAL.md)

### Commands

* `/listmaps`: lists all maps defined in mapList and their status
* `/gotomap`: teleports you to a map's TP position defined in mapList
* `/tdo`: (test draw objects) displays object IDs and their replaced textures with material indexes
* `/loadmap` *(server)*: loads a map by ID for all players
* `/unloadmap` *(server)*: unloads a map by ID for all players

### Examples

* This resource comes with a few **test maps** that contain custom models for you to see how it works
* Check the `.pwn map files` and the `corresponding models` in the respective folders

### Main functions

* `CreateNewObject(model_id,x,y,z,rx,ry,rz)` 
    * note the model_id can be either default SA object or a SA-MP id
* `SetObjectMaterial(object,mat_index,model_id,lib_name,txd_name,color)`
    * assigns a default SA texture to an object's texture by material id
    * lib_name is currently ignored (MTA doesn't need it to find the texture)
* `AddSimpleModel(virtualworld, baseid, newid, dffname, txdname)`
    * adds new objects by passing a base model id, the new samp id and the dff + txd names
    * virtualworld is currently ignored (models will exist in every world)

### Issues

* `SetObjectMaterialText` is not yet supported
* `Material Color` is not yet supported
* `Materials with Alpha (Transparency)` won't render properly
* `AddSimpleModel` doesn't support a SA-MP model as base ID (`engineRequestModel` limitation)
* High memory usage: MTA currently donesn't support of server-side model allocation, they have to be allocated clientside, which takes up some memory client-side.

### Help & Bugs

* If you need support, contact **Nando#7736** on Discord
* Please report any bugs using **GitHub Issues**

### 🚀 Todo 🚀

* Add support for creating objects outside of the resource (exported functions; proper memory allocation), so that you can use it as a library and create your own scripts with `sampobj`
* Add async loading to prevent huge freezes when loading a lot of objects

### Where can I get TextureStudio to make SA-MP maps?

* There will soon be an alternative to **TextureStudio** on MTA with better UI and controls (instead of the huge amount commands you need to know to use the SA-MP version, which make mapping quite inefficient)
* It is true that MTA Map Editor never had a way to replace a texture on an object with a certain GTA:SA texture
* This resource implements that, and I believe this feature can one day be available on the MTA Map Editor
* But if you want, you can still download [SA-MP TextureStudio (v1.9c)](https://github.com/Crayder/Texture-Studio/releases/tag/v1.9c)