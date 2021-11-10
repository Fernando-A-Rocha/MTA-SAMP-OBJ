# SAMP MAP LOADER (Fernando Edition)
Add support to load your favourite SA-MP maps into the MTA-SA!

## Exports 
### sampobj
* `createSAMPObject(model_id,x,y,z,rx,ry,rz)` 
    * note the mode_id can be either sa stock object or an id from samp_model.
* `setObjectMaterial(object,mat_index,model_id,lib_name,txd_name,color)`
* `AddSimpleModel(virtualworld, baseid, newid, dffname, txdname)`
    * used to add new objects passing a base model id, the new samp id and the dff + txd names

## Issues & todos in future
* Currently the material color is somehow bugged, especially the one contains the alpha materials.
* Drawdistance issue, due to the engine limitation the max distances viewdistance of a normal object is 300 unit, if your map contains the wide areas of custom samp objects, the far distances objects might not visible.
* High Memory Useage, due to the MTA current don't have the support of server-side defined object ids, therefore inorder to keep the original samp model id works i did a big mapping array to keep the mta-allocated ids & orignal samp ids in relation. however the down-side is the high RAM use, it might needs to takes some further optimzation in the furtue.
* Currently no `SetObjectMaterialText`
