#define scr_spawn_plane
///scr_spawn_plane(model_name)

var pos, dir, dir_ref, plane, cmc, cb, model_name;
model_name = argument[0];

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
return scr_plane_enemy_create(pos[0],pos[1],dir,model_name);

#define scr_spawn_plane_cmc3
///scr_spawn_plane_cmc3()
var model_name = choose("bessie", "altair");
scr_spawn_plane(model_name);
scr_add_design_pattern("scr_spawn_plane_cmc3");

#define scr_spawn_plane_cmc4
///scr_spawn_plane_cmc4()
var model_name = choose("firnas","magnolia","pasque");
scr_spawn_plane(model_name);
scr_add_design_pattern("scr_spawn_plane_cmc4");

#define scr_spawn_plane_cmc5
///scr_spawn_plane_cmc5()
var model_name = choose("deneb","earl","gypsophila");
scr_spawn_plane(model_name);
scr_add_design_pattern("scr_spawn_plane_cmc5");
