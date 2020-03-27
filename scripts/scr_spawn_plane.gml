#define scr_spawn_plane
///scr_spawn_plane(model_name, skill)

var pos, dir, dir_ref, plane, cmc, cb, model_name, skill;
model_name = argument[0];
skill = argument[1];

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

plane = scr_aiplane_create(pos[0],pos[1],dir,model_name,"mg","mg_chaser",skill);
with(plane){
    cmc = round(display_speed)+round(display_turn)+round(display_dmg);
}

cb = "scr_spawn_plane_cmc"+string(cmc);
scr_add_design_pattern(cb);

#define scr_spawn_plane_cmc3
///scr_spawn_plane_cmc3()
var model_name = choose("al_awaidh");
scr_spawn_plane(model_name,1);

#define scr_spawn_plane_cmc4
///scr_spawn_plane_cmc4()
var model_name = choose("jenny","asteroid_blues","camel");
scr_spawn_plane(model_name,choose(1,2));

#define scr_spawn_plane_cmc5
///scr_spawn_plane_cmc5()
var model_name = choose("fomalhaut","red_baroness");
scr_spawn_plane(model_name,2);