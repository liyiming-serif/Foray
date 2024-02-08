#define scr_c_targeting_add
///scr_c_targeting_add(component_map=auto)

//decode json properties
//req: mp
var cmp;
if(argument_count == 0){
    cmp = ds_map_find_value(mp,"c_targeting");
}
else{
    cmp = argument[0];
}

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
    scr_c_targeting_set();
}

scr_c_add("c_targeting");

#define scr_c_targeting_set
///scr_missile_set_target()
//configure target sprite
if(!variable_instance_exists(id,"target_sprite") || !scr_instance_exists(target_id)){
    return undefined;
}

var xcorn, ycorn;
xcorn = -target_id.sprite_xoffset;
ycorn = -target_id.sprite_yoffset;

target_sprite_xoff = irandom_range(xcorn,xcorn+sprite_get_width(target_id.sprite_index));
target_sprite_yoff = irandom_range(ycorn,ycorn+sprite_get_height(target_id.sprite_index));

//set global missile table
if(!ds_map_exists(global.target_slots, object_get_name(object_index))){
    ds_map_add(global.target_slots, object_get_name(object_index), ds_list_create());
}
