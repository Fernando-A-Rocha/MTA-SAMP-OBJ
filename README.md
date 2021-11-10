# SA-MP Object Loader

## Load your favourite SA-MP maps into MTA:SA

### Credits

* Original creator: [gta191977649](https://github.com/gta191977649)
* Extended by: [Fernando](https://github.com/Fernando-A-Rocha) (this fork)
* SA-MP Objects by Rockstar & SA-MP devs

### How to use

* place map files in [sampobj/maps](sampobj/maps) and models in [sampobj/models](sampobj/models)
* **map.pwn** files in meta.xml under `<!-- samp maps -->`
* custom models **dff + txd + col** in meta.xml under `<!-- samp models -->`
* list of **maps to load** in [maps/map_loader.lua](sampobj/maps/map_loader.lua)
* useful **commands**: `/listmaps`, `/gotomap`, `/tdo` *(test draw objects)*

### Example Maps and Models

* this resource comes with a few **test maps** that contain custom models for you to see how it works
* check the `.pwn map files` and the `corresponding models` in the respective folders
* they are loaded in [maps/map_loader.lua](sampobj/maps/map_loader.lua)

### How to generate a .col from a .dff file

* tutorial [here](sampobj/models/_TUTORIAL.md)

### Exported functions

* `createSAMPObject(model_id,x,y,z,rx,ry,rz)` 
    * note the model_id can be either SA default object or an id from SAMP
* `setObjectMaterial(object,mat_index,model_id,lib_name,txd_name,color)`
    * assigns a default SA texture to an object's texture by material id
    * lib_name is currently ignored (not needed in MTA)
* `AddSimpleModel(virtualworld, baseid, newid, dffname, txdname)`
    * adds new objects by passing a base model id, the new samp id and the dff + txd names
    * virtualworld is currently ignored

### Issues & todos in future

* Currently the material color is somehow bugged, especially the one contains the alpha materials.
* Drawdistance issue, due to the engine limitation the max distances viewdistance of a normal object is 300 unit, if your map contains the wide areas of custom samp objects, the far distances objects might not visible.
* High Memory Useage, due to the MTA current don't have the support of server-side defined object ids, therefore inorder to keep the original samp model id works i did a big mapping array to keep the mta-allocated ids & orignal samp ids in relation. however the down-side is the high RAM use, it might needs to takes some further optimzation in the furtue.
* Currently no `SetObjectMaterialText`
