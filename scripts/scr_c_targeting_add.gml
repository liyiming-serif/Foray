///scr_c_targeting_add(component_map=auto)

//decode json properties
//req: mp
//ADDS: ???

cmp = ds_map_find_value(mp,"c_targeting");
target_image_index = 0;
//set target_id
targeting_cb = asset_get_index(ds_map_find_value(cmp, "targeting_cb"));
if(!script_execute(targeting_cb)){
    instance_destroy();
    return undefined;
}
//optional targeting parameters
v = ds_map_find_value(cmp, "warn_range");
if(v != undefined){
    warn_range = v;
}
v = ds_map_find_value(cmp, "targeting_sprite");
if(v != undefined){
    target_sprite = asset_get_index(v);
    target_sprite_ind = 0;
    scr_missile_set_target();
}

scr_c_add("c_targeting");
