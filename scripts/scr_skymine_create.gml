#define scr_skymine_create
///scr_skymine_create(x, y, launch_dir, launch_vel, chase_player=false)
var xv = argument[0];
var yv = argument[1];
var launch_dir = argument[2];
var launch_vel = argument[3]*global.game_speed;
var chp = false;
if(argument_count>4){
    chp = argument[4];
}

with(instance_create(xv,yv,obj_skymine)){
    //launch the balloon
    direction = launch_dir;
    speed = launch_vel;
    
    //initiallize stats
    var mp = ds_map_find_value(global.airships, "skymine");
    
    friction = ds_map_find_value(mp, "fric");
    dmg = ds_map_find_value(mp, "dmg");
    alert_range = ds_map_find_value(mp, "alert_range");
    chase_player = chp;
    
    scr_ship_init(false,mp);
    
    //optional behavior: chase the player like Blooper
    if(chase_player){
        chase_vel = ds_map_find_value(mp,"chase_vel");
        chase_freq = ds_map_find_value(mp,"chase_freq");
        hp *= ds_map_find_value(mp,"chase_hp_reduc");
        alarm[0] = chase_freq;
        threat = ds_map_find_value(mp, "chasing_threat");
        
        //audio_emitter_falloff(engine_sound_emitter,
            //global.SOUND_SKYMINE_FALLOFF_REF_DIST,
            //global.SOUND_SKYMINE_FALLOFF_MAX_DIST,
            //global.SOUND_FALLOFF_FACTOR);
        //engine_sound = audio_play_sound_on(engine_sound_emitter,snd_skymine_engine,true,0);
        //audio_sound_pitch(engine_sound,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));
    }
    
    image_speed = 0.5;
    
    return id;
}

#define scr_skymine_queue
///scr_skymine_queue(x, y, chase_player=false)

//Defer creating a skymine until (x,y) is outside the player's view.
//Useful for scheduled waves, so mines don't appear out of thin air.
var tuple;
tuple[0] = argument[0];
tuple[1] = argument[1];
if(argument_count == 3){
tuple[2] = argument[2];
}
else{
tuple[2] = false;
}

ds_list_add(global.skymine_queue, tuple);

#define scr_skymine_hit
///scr_skymine_hit()

if(is_friendly!=other.is_friendly && hp>0 && invuln<=0 && abs(speed)<=friction){
    //get pushed around
    speed = other.dmg*global.game_speed;
    direction = other.direction;
}
scr_ship_hit();

#define scr_skymine_chase
///scr_skymine_chase()

//Runs only once per alarm
if(!chase_player || !scr_instance_exists(global.player_id)){
    return undefined;
}

if(!scr_instance_exists(target_id)){
    target_id = global.player_id;
}

//look ahead and check for any solids/allies in the way
var l, sp, pd, i, can_move;
sp =  chase_vel*global.game_speed;
pd = point_direction(x,y,target_id.x,target_id.y);
l = sp*sp/(2*friction);

i = collision_line(x,y,lengthdir_x(l,pd)+x,lengthdir_y(l,pd)+y,obj_obstacle_parent,false,true);
can_move = true;
if(i!=noone){
    if(!variable_instance_exists(i, "is_friendly") || i.is_friendly == is_friendly){
        can_move = false;
    }
}

//nothing in the way: move
if(can_move){
    speed = sp;
    direction = pd;
}

alarm[0] = chase_freq;
