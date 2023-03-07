#define scr_spawn_plane
///scr_spawn_plane(model_name, skill, ai_name)

var pos, dir, dir_ref, plane, cmc, cb, model_name, skill, ai_name;
model_name = argument[0];
skill = argument[1];
ai_name = argument[2];
pos = scr_get_point_on_border();
//chose dir such that plane enters perpendicular to player
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

plane = scr_aiplane_create(pos[0],pos[1],dir,model_name,ai_name,skill);
with(plane){
    cmc = round(display_speed)+round(display_turn)+round(display_dmg);
}

cb = "scr_spawn_plane_cmc"+string(cmc);
scr_add_design_pattern(cb);

#define scr_spawn_plane_cmc3
///scr_spawn_plane_cmc3(ai_name)
var ai_name = argument[0];
var model_name = choose("altair");
scr_spawn_plane(model_name,1,ai_name);

#define scr_spawn_plane_cmc4
///scr_spawn_plane_cmc4(ai_name)
var ai_name = argument[0];
var model_name = choose("bessie","firnas","camel");
scr_spawn_plane(model_name,choose(1,2),ai_name);

#define scr_spawn_plane_cmc5
///scr_spawn_plane_cmc5(ai_name)
var ai_name = argument[0];
var model_name = choose("deneb","earl");
scr_spawn_plane(model_name,2,ai_name);
