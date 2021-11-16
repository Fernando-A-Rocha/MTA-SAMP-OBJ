![Banner](https://i.imgur.com/8cfN2d9.png)

## About

Please read everything! Scroll down for contact info - thank you 💖

### Credits

* Original creator: [gta191977649](https://github.com/gta191977649)
* Extended by: [Fernando](https://github.com/Fernando-A-Rocha) (this fork)
* SA-MP Objects by Rockstar & SA-MP devs

### Introduction

* Includes a library which lets you add SA-MP objects to the game in your MTA server
    * Reads samp.ide, samp.col and samp.img
    * Allocates new models to add SA-MP objects
    * Smart & optimized memory allocation
    * Many debug/error messages & comments to help you understand the code

* Includes an example resource containing the following:

    * SA-MP Map Loader:
        * Loads native TextureStudio exported maps (reads Pawn code)
        * Controlled in serverside script before sending to client

    * SA-MP Object Spawner:
        * Creates SA-MP objects from a spawnpoints list
        * Lets you spawn a SA-MP object via command

    * New Object Loader & Spawner:
        * Allocates new models from a given list
        * Creates them from a spawnpoints list

* Everything was developed to be easily extendable & customizable by you, so enjoy!

### ⚠️ Disclaimer ⚠️

* This resource is still under active development (see below how you can help)
* See all current `known issues` and `planned features/changes` in the [Issues](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/issues) tab

## Install

### Prerequisites

1. Check the current reported issues [here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/issues)

    * It's important to see if this resource suits your needs
    * Important issue: `sampobj` currently won't work if `editor` (MTA:SA Map Editor) is running


2. Make sure you have the right MTA client (game) version

    * Download **Windows nightly installer** from [here](https://nightly.mtasa.com/)
    * Client: `1.5.9-9.21026.0` (*Minimum*)

3. Make sure you have the right MTA server version

    * Download **Windows or Linux server only installer** from [here](https://nightly.mtasa.com/)
    * Server: `1.5.9-9.21024.0` (*Minimum*)
    * It's recommended that you run this in a default MTA:SA server

### Installation

1. Get the latest stable release: [here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/releases/latest)

2. Unzip the source code and move the `[samp]` folder to your server's resources

3. Inside that folder you should see **2 MTA resources**:

    * `sampobj`: the main library
    * `sampobj-examples`: a few test scripts that use it

4. Check if it's installed correctly by trying to start the test scripts: `start sampobj-examples` in **server console** or in-game

    * You should get `start: Resource 'sampobj' started` (resource `sampobj` will be started automatically)
    * If you cannot start the resource, check if the server has the right version by typing `ver` in **server console**

## Tutorial

### Debugging

Configure how you want to see the custom library debug messages in  [sampobj/scripts/_debug.lua](%5Bsamp%5D/sampobj/scripts/_debug.lua)\
These help you understand what you are doing and see error/warning/info messages

### SA-MP Map Loading

`sampobj-examples/samp_maps` comes with a few **test maps** (some contain added object models) for you to see how it works. Here's how you can add yours:

1. Place map file in [samp_maps/maps](%5Bsamp%5D/sampobj-examples/samp_maps/maps)
    - Check the list of supported Pawn functions [here](#exported-functions)
    - Lines must be a series of function calls, see the existing example Pawn files

2. List map files (**name.pwn**) in [meta.xml](%5Bsamp%5D/sampobj-examples/meta.xml) under `<!-- SA-MP Maps -->`
    - This allows the resource to send these files to the client when they join so the maps can be loaded

3. Place custom model files in [samp_maps/models](%5Bsamp%5D/sampobj-examples/samp_maps/models)
    - This is required if your map has any `added objects` using `AddSimpleModel` 
    - Must have dot `dff, txd and col` files **for each new object**
    - If you don't have a collision file for your model check [this tutorial](TUTORIAL_COL.md)

4. List custom model files (**dff + txd + col**) in [meta.xml](%5Bsamp%5D/sampobj-examples/meta.xml) under `<!-- SA-MP Map Models -->`
    - This is required if your map has any `added objects` using `AddSimpleModel` 
    - This allows the resource to send these files to the client when they join so the models can be loaded when requested in a map file

5. Define **maps to load** in [samp_maps/list.lua](%5Bsamp%5D/sampobj-examples/samp_maps/list.lua) inside `mapList`
    - Read the comments to understand how to define your map

6. Use `start sampobj-examples` to initiate the test resource or `restart sampobj-examples` after changing it

### Simple SA-MP Object Spawner

See the comments in [samp_objects/client.lua](%5Bsamp%5D/sampobj-examples/samp_objects/client.lua) for explanations

### Simple New Object Loader & Spawner

See the comments in [new_objects/client.lua](%5Bsamp%5D/sampobj-examples/new_objects/client.lua) for explanations

### Commands

#### (sampobj) Testing
* `/tdo`: (test draw objects) displays nearby object IDs and their replaced textures with material indexes

#### (sampobj-examples) SA-MP Maps
* `/listmaps`: lists all maps defined in the samp_maps example inside mapList
* `/gotomap`: teleports you to a map's TP position defined in mapList
* `/loadmap` *(server)*: loads a map by ID for all players
* `/unloadmap` *(server)*: unloads a map by ID for all players

#### (sampobj-examples) SA-MP Objects
* `/spawnobject`: creates a an object by ID where you're standing
* `/dobjs`: (destroy objects) destroys SA-MP objects spawned with the samp_objects example

#### (sampobj-examples) New Objects
* `/newmodels`: lists all models defined in the samp_models example inside modelList
* `/dnewobjs`: (destroy new objects) destroys new objects spawned with the samp_objects example

### Exported Functions

* CLIENT: `CreateNewObject(model_id, x,y,z, rx,ry,rz)` 
  * __returns an object element created somewhere__
  * model_id can be either default SA object or a SA-MP id

* CLIENT: `SetObjectMaterial(object, mat_index, model_id, txd_name, color)`
  * __assigns a default SA texture to an object's texture by material id__
  * color currently has no effect
  * *lib_name in SA-MP function is ignored (not needed to find the texture)*

* CLIENT: `AddSimpleModel(baseid, newid, folderPath, fileDff, fileTxd, fileCol)`
  * __adds a new object to the game identified by a new ID that you can then use in__ `CreateNewObject`
  * folderPath is the path to the folder containing the models ([wiki info](https://wiki.multitheftauto.com/wiki/Filepath))
  * fileDff, fileTxd and fileCol have to be file name + extension (example: chair.dff)
  * *virtualworld in SA-MP function is ignored (models will exist in every world)*

* CLIENT: `isSAMPIDQueued(model)`
  * __returns true if the provided SA-MP id has been or will be loaded__

* CLIENT: `queueSAMPID(model, mapid)` 
  * __returns true__
  * sets a SA-MP model id in the `req_object_ids` array for a mapid
  * mapid can be 0 if object doesn't belong to any specific map

* CLIENT: `queueSAMPIDs(ids, mapid)` 
  * __returns true__
  * same purpose as previous function but assigns an array of ids to a mapid directly

* CLIENT: `loadSAMPObjects()` 
  * __returns true__
  * forces SAMP objects in `req_object_ids` to load

* SHARED: `parseTextureStudioMap(filepath)` 
  * __returns the parsed map content and list of new object IDs used or false if file doesn't exist__
  * reads map Pawn code: recognises various functions and stores the calls in arrays

## Help & Bugs

* **For support contact** `Nando#7736` **on Discord**
* Please report any bugs using **GitHub Issues** ([here](https://github.com/Fernando-A-Rocha/MTA-SAMP-OBJ/issues)), and check for any already submitted bug reports
* If you want to contribute you can fork this repository & submit PRs

## Miscellaneous

### How do I get a collision file for my model with .dff?

* Check this tutorial [here](TUTORIAL_COL.md)

### Where can I get TextureStudio to make SA-MP maps?

* There will soon be an alternative to **TextureStudio** on MTA with better UI and controls (instead of the huge amount commands you need to know to use the SA-MP version, which make mapping quite inefficient)
* It is true that MTA Map Editor never had a way to replace a texture on an object with a certain GTA:SA texture
* This resource implements that, and I believe this feature can one day be available on the MTA Map Editor
* But if you want, you can still download [SA-MP TextureStudio (v1.9c)](https://github.com/Crayder/Texture-Studio/releases/tag/v1.9c)
