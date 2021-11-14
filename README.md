![Banner](https://i.imgur.com/8cfN2d9.png)

## About

Please read everything! Scroll down for contact info - thank you 💖

### Credits

* Original creator: [gta191977649](https://github.com/gta191977649)
* Extended by: [Fernando](https://github.com/Fernando-A-Rocha) (this fork)
* SA-MP Objects by Rockstar & SA-MP devs

### Features

* Load native TextureStudio exported maps (reads Pawn code)
* SA-MP Map loading can be controlled on the server (e.g. admin panel for loading maps)
* Smart memory allocation (only loads the SA-MP objects that loaded maps use)
* Many debug/error messages & comments to help you understand the code
* Easily customizable & extendable

### ⚠️ Disclaimer ⚠️

* This resource is still rather experimental (see below how you can help)
* See all current `known issues` and `planned features/changes` in the [Issues](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/issues) tab

## Install

### Prerequisites

1. Check the current reported issues [here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/issues)

    * It's important to see if this resource suits your needs


2. Make sure you have the right MTA client (game) version

    * Download **Windows nightly installer** from [here](https://nightly.mtasa.com/)
    * Client: `1.5.9-9.21026.0` (*Minimum*)

3. Make sure you have the right MTA server version

    * Download **Windows or Linux server only installer** from [here](https://nightly.mtasa.com/)
    * Server: `1.5.9-9.21024.0` (*Minimum*)

### Installation

1. Get the latest stable release: [here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/releases/latest)

2. Unzip the source code and move the `[samp]` folder to your server's resources

3. Check if it's installed correctly by trying to start it: `start sampobj` in **server console** or in-game

    * You should get `start: Resource 'sampobj' started`
    * If you cannot start the resource, check if the server has the right version by typing `ver` in **server console**

## Tutorial

### Debugging

* Configure how you want to see the custom debug messages in [scripts/_debug.lua](%5Bsamp%5D/sampobj/scripts/_debug.lua)
  * These help you understand what you are doing and see error/warning/info messages

### SA-MP Maps

* This resource comes with a few **test maps** (some contain added object modelss) for you to see how it works

1. Place map file in [sampobj/maps](%5Bsamp%5D/sampobj/maps)
    * Check the list of supported Pawn functions [here](#main-functions)
    * Must be a series of function calls, see the example maps [here](%5Bsamp%5D/sampobj/maps)

2. List map files (**name.pwn**) in [sampobj/meta.xml](%5Bsamp%5D/sampobj/meta.xml) under `<!-- samp maps -->`
    * This allows the resource to send these files to the client when they join so the maps can be loaded

3. (Optional) Place custom model files in [sampobj/meta.xml](%5Bsamp%5D/sampobj/meta.xml) under `<!-- samp models -->`
    * This is required if your map has any `added objects` using `AddSimpleModel` 
    * Must have dot dff, txd and col files for each new object (dff and col must have the same name)
    * If you don't have a collision file for your model check [this tutorial](%5Bsamp%5D/sampobj/models/_TUTORIAL.md)

4. (Optional) List custom model files (**dff + txd + col**) in [sampobj/meta.xml](%5Bsamp%5D/sampobj/meta.xml) under `<!-- samp models -->`
    * This allows the resource to send these files to the client when they join so the models can be loaded when requested in a map file

5. Define **maps to load** in [maps/_maplist.lua](%5Bsamp%5D/sampobj/maps/_maplist.lua)
    * Easy Lua code editing, the existing example maps code should inspire you

6. Use `start sampobj` to initiate the resource or `restart sampobj`

### Commands

* `/listmaps`: lists all maps defined in mapList and their status
* `/gotomap`: teleports you to a map's TP position defined in mapList
* `/tdo`: (test draw objects) displays object IDs and their replaced textures with material indexes
* `/loadmap` *(server)*: loads a map by ID for all players
* `/unloadmap` *(server)*: unloads a map by ID for all players

### Main Functions

* `CreateNewObject(model_id,x,y,z,rx,ry,rz)` 
    * model_id can be either default SA object or a SA-MP id

* `SetObjectMaterial(object,mat_index,model_id,lib_name,txd_name,color)`
    * assigns a default SA texture to an object's texture by material id
    * lib_name is currently ignored (MTA doesn't need it to find the texture)

* `AddSimpleModel(virtualworld, baseid, newid, dffname, txdname)`
    * adds new objects by passing a base model id, the new samp id and the dff + txd names
    * virtualworld is currently ignored (models will exist in every world)

## Help & Bugs

* **For support contact** `Nando#7736` **on Discord**
* Please report any bugs using **GitHub Issues** ([here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/issues)), and check for any already submitted bug reports
* If you want to contribute you can fork this repository & submit PRs

## Miscellaneous

### How do I get a collision file for my model (.dff)?

* Check this tutorial [here](%5Bsamp%5D/sampobj/models/_TUTORIAL.md)
* 
### Where can I get TextureStudio to make SA-MP maps?

* There will soon be an alternative to **TextureStudio** on MTA with better UI and controls (instead of the huge amount commands you need to know to use the SA-MP version, which make mapping quite inefficient)
* It is true that MTA Map Editor never had a way to replace a texture on an object with a certain GTA:SA texture
* This resource implements that, and I believe this feature can one day be available on the MTA Map Editor
* But if you want, you can still download [SA-MP TextureStudio (v1.9c)](https://github.com/Crayder/Texture-Studio/releases/tag/v1.9c)
