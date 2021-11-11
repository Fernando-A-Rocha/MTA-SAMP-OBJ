# SA-MP Map Loader

## Load your favourite SA-MP maps into MTA:SA

### Credits

* Original creator: [gta191977649](https://github.com/gta191977649)
* Extended by: [Fernando](https://github.com/Fernando-A-Rocha) (this fork)
* SA-MP Objects by Rockstar & SA-MP devs

### How to use

* Place map files in [sampobj/maps](sampobj/maps) and models in [sampobj/models](sampobj/models)
* List map files (**name.pwn**) in meta.xml under `<!-- samp maps -->`
* And custom models (**dff + txd + col**) in meta.xml under `<!-- samp models -->`
* Define **maps to load** in [maps/_maplist.lua](sampobj/maps/_maplist.lua)
* useful **commands**: `/listmaps`, `/gotomap`, `/tdo` *(test draw objects)*

### Examples

* This resource comes with a few **test maps** that contain custom models for you to see how it works
* Check the `.pwn map files` and the `corresponding models` in the respective folders

### What if my custom model only has dff + txd, how do I get the col?

* Check this tutorial [here](sampobj/models/_TUTORIAL.md)

### Exported functions

* `createSAMPObject(model_id,x,y,z,rx,ry,rz)` 
    * note the model_id can be either SA default object or an id from SAMP
* `setObjectMaterial(object,mat_index,model_id,lib_name,txd_name,color)`
    * assigns a default SA texture to an object's texture by material id
    * lib_name is currently ignored (not needed in MTA)
* `AddSimpleModel(virtualworld, baseid, newid, dffname, txdname)`
    * adds new objects by passing a base model id, the new samp id and the dff + txd names
    * virtualworld is currently ignored

### Issues

* Currently no `SetObjectMaterialText` support
* Currently ``Material Color`` is somehow bugged, especially if it contains the alpha materials
* High memory usage: MTA currently donesn't support of server-side model allocation, they have to be allocated clientside, which takes up a lot of memory.

### Todo

* `AddSimpleModel` doesn't support a SAMP model as base ID
* Only allocate SAMP ids that loaded maps are going to use (to save memory), a temporary solution until server-side model allocation comes.
