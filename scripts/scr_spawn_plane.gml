#define scr_spawn_plane
///scr_spawn_plane(model_name, ai=default)

var obj_ind, pos, dir, dir_ref, mn, ai;
mn = argument[0];
//need AI to know which enemy plane obj to create
if(argument_count == 2){
    ai = argument[1];
}
else{
    ai = ds_map_find_value(
        ds_map_find_value(global.models, mn), "default_ai");
}
obj_ind = asset_get_index(ds_map_find_value(
    ds_map_find_value(global.pilot_ai, ai), "obj_ind"));

//set x, y
pos = scr_get_point_on_border();
//set dir such that plane enters perpendicular to player
dir = point_direction(pos[0],pos[1],room_width/2,room_height/2);
if(scr_instance_exists(global.player_id)){
    dir_ref[0] = point_direction(pos[0],pos[1],global.player_id.x,global.player_id.y)+90;
    dir_ref[1] = point_direction(pos[0],pos[1],global.player_id.x,global.player_id.y)-90;
    if(abs(angle_difference(dir,dir_ref[0])) < abs(angle_difference(dir,dir_ref[1]))){
        dir = dir_ref[0];
    } 
    else{
        dir = dir_ref[1];
    }
}

//actually create plane
return scr_instance_create(pos[0],pos[1],obj_ind,dir,false,mn,ai);

#define scr_spawn_plane_cmc3
///scr_spawn_plane_cmc3()
var mn = choose("bessie", "altair");
scr_spawn_plane(mn);
scr_add_design_pattern("scr_spawn_plane_cmc3");

#define scr_spawn_plane_cmc4
///scr_spawn_plane_cmc4()
var mn = choose("firnas","magnolia","pasque");
scr_spawn_plane(mn);
scr_add_design_pattern("scr_spawn_plane_cmc4");

#define scr_spawn_plane_cmc5
///scr_spawn_plane_cmc5()
var mn = choose("deneb","earl","gypsophila");
scr_spawn_plane(mn);
scr_add_design_pattern("scr_spawn_plane_cmc5");