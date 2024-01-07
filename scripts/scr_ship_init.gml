#define scr_ship_init
///scr_ship_init(is_friendly, ds_map)

//SUPERCLASS CONSTRUCTOR: don't call directly
is_friendly = arg_buff[0];
mp = arg_buff[1];

//LOAD COMPONENTS
scr_c_hull_add(ds_map_find_value(mp,"c_hull"));
scr_c_engine_add(ds_map_find_value(mp,"c_engine"));

//common: callbacks
var v;
v = ds_map_find_value(mp,"shot_down_cb");
if(v != undefined){
    shot_down_cb = asset_get_index(v);
}
v = ds_map_find_value(mp,"crash_cb");
if(v != undefined){
    crash_cb = asset_get_index(v);
}

//common: spawning
threat = ds_map_find_value(mp,"threat");

//TODO: finish ai
var aimp = ds_map_find_value(mp,"ai");
update_target_time = ds_map_find_value(aimp,"update_target_time");
if(!is_friendly){
    target_id = global.player_id;
    alarm[update_target_time_alarm] = update_target_time;
}



#define scr_ship_advance_frame
///scr_ship_advance_frame()

//countdown hitstun and invuln
scr_c_hull_step();

//update emitter
audio_emitter_position(engine_sound_emitter,x,y,0);
audio_emitter_velocity(engine_sound_emitter,hspeed,vspeed,0);

#define scr_ship_turn
///scr_ship_turn(x, y, should_face_dir, turn_modifier=1, speed_modifier=1)

//Generic script for turning ships towards a point,
//and whether to change image_angle to match dir
//Req inst variables: curr_speed, turn

var tx = argument[0];
var ty = argument[1];
var should_face_dir = argument[2];
var tm = turn;
var sm = curr_speed;

//Apply a flat turn multiplier so ships spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count > 3){
    tm *= argument[3];
}
//Optional: apply a modifier w/out affecting 'speed' property.
if(argument_count > 4){
    sm *= argument[4];
}

var pa = point_direction(x,y,tx,ty);
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);

direction += global.game_speed*ta*sign(da);
direction = angle_difference(direction,0); //constrain angle values
speed = global.game_speed*sm;
if(should_face_dir){
    image_angle = direction;
}

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));

#define scr_ship_turn_away
///scr_ship_turn_away(x, y, should_face_dir, turn_modifier=1, speed_modifier=1)

//Generic script for turning ships away from a point,
//and whether to change image_angle to match dir
//Req inst variables: curr_speed, turn

var tx = argument[0];
var ty = argument[1];
var should_face_dir = argument[2];
var tm = turn;
var sm = curr_speed;

//Apply a flat turn multiplier so ships spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count > 3){
    tm *= argument[3];
}
//Optional: apply a modifier w/out affecting 'speed' property.
if(argument_count > 4){
    sm *= argument[4];
}

var pa = point_direction(tx,ty,x,y);
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);

direction += global.game_speed*ta*sign(da);
direction = angle_difference(direction,0); //constrain angle values
speed = global.game_speed*sm;
if(should_face_dir){
    image_angle = direction;
}

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));

#define scr_ship_hit
///scr_ship_hit()

//TO REFACTOR: player/enemy hit specific code
if(is_friendly){ //player
    //TODO: apply screen shake?
    
    //apply screen flash
    if(id==global.player_id){
        global.flash_red_alpha += post_dmg/15;
    }
    
    //DIFFICULTY MOD: scale dmg down by spawn capacity
    if(!global.is_endless){
        post_dmg = max((1-global.spawn_cap*0.3)*post_dmg,global.MIN_DMG);
    }
}
else{ //enemy
    //DIFFICULY MOD: increase player's atk if outnumbered
    post_dmg *= 1+global.spawn_cap*0.5;
}


#define scr_ship_shade
///scr_ship_shade()

//Shared shading logic across all ships

//cast shadow
scr_cast_shadow();

if(hitstun>0){ //apply hit flash
    shader_set(shader_hit_flash);
}
draw_self();
shader_reset();

#define scr_ship_gc
///scr_ship_gc()
scr_ship_gc_wpns();

//HACK: add score system to discourage player from running away
//TODO: delete this
if(!is_friendly){
    score += points;
}

//gc audio
audio_emitter_free(engine_sound_emitter);

#define scr_ship_gc_wpns
///scr_ship_gc_wpns()
if(!variable_instance_exists(id,"gid")){
    return undefined;
}

if(is_array(gid)){
    for(i=0; i<array_length_1d(gid); i++){
        if(scr_instance_exists(gid[i])){
            instance_destroy(gid[i]);
        }
    }
}
else if(scr_instance_exists(gid)){
    instance_destroy(gid);
}

#define scr_ship_update_wpn
///scr_ship_update_wpn(r,t,gid,rot_locked_by_ship=true)

//Update weapon position and image angle using polar coordinates.
//Call during the end step!

var r = argument[0];
var t = argument[1];
var g = argument[2];
if(!scr_instance_exists(g)){
    return -1;
}

if(argument_count==3 || argument[3]==true){
    g.image_angle = t;
}

g.x = x+lengthdir_x(r,t);
g.y = y+lengthdir_y(r,t);

#define scr_ship_shoot
///scr_ship_shoot(gid, cb_type)

//wrapper around executing gid callbacks for reducing copied code
var g, cb, ret;
g = argument[0];
cb = argument[1];
ret = -1;

with(g){
    switch(cb){
        case "on_click":
            ret = script_execute(on_click_cb);
            break;
        case "pressed":
            ret = script_execute(pressed_cb);
            break;
        case "on_release":
            ret = script_execute(on_release_cb);
            break;
    }
}

return ret;

#define scr_ship_explode_large
///scr_ship_explode_large()

//death cb
part_particles_create(global.partsys,x,y,global.explosion,1);
scr_play_sound(snd_detonation,x,y);
//clean up all sounds under emitter
//audio_stop_sound(engine_sound);

instance_destroy();

#define scr_ship_explode_small
///scr_ship_explode_small()

//death cb
part_particles_create(global.partsys,x,y,global.boom_air,1);
scr_play_sound(snd_explosion_m,x,y);
//clean up all sounds under emitter
//audio_stop_sound(engine_sound);

instance_destroy();

#define scr_ship_draw_ui
///scr_ship_draw_ui()

//draw any ui attached to the ship

//draw hp bar
if(hp<max_hp && global.player_id != id){
    scr_c_hull_draw_hp_bar();
}