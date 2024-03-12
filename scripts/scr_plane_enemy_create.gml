#define scr_plane_enemy_create
///scr_plane_enemy_create(x, y, dir, model_name)
var xv = argument[0];
var yv = argument[1];
var dir = argument[2];
var model_name = argument[3];

var d_ai = ds_map_find_value(
    ds_map_find_value(global.models, model_name), "default_ai");
    
var enemy_obj_ind = scr_plane_enemy_get_obj(d_ai);

return scr_instance_create(xv,yv,enemy_obj_ind,dir,false,model_name);

#define scr_plane_enemy_get_obj
///scr_plane_enemy_get_obj(ai_name)

var obj_name = "obj_enemy_"+argument[0];

return asset_get_index(obj_name);