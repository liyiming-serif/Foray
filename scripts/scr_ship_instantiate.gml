#define scr_ship_instantiate
///scr_ship_instantiate(is_friendly, ds_map, update_target_time=-1)

//SUPERCLASS CONSTRUCTOR: don't call directly
//hitstun and invincibility frames
is_friendly = argument[0];
var mp = argument[1];

//common: hp
max_hp = ds_map_find_value(mp, "max_hp");
hp = max_hp;
hp_bar_width = ds_map_find_value(mp,"hp_bar_width");
if(hp_bar_width==undefined){
    hp_bar_width = sprite_width;
}
//common: callbacks
var dsn = ds_map_find_value(mp,"death_seq_cb");
if(dsn != undefined){
    death_seq_cb = asset_get_index(dsn);
}
//common: collision
hitstun = 0;
invincibility = 0;
//common: spawning
threat = ds_map_find_value(mp,"threat");

//TODO: remove scoring
points = ds_map_find_value(mp, "score");

//Enemies: locate targets
if(!is_friendly){
    //player
    var utt = ds_map_find_value(mp,"update_target_time");
    if(utt != undefined){
        update_target_time = utt;
    }
    else if(argument_count==3){
        update_target_time = argument[2];
    }
    if(variable_instance_exists(id,"update_target_time")){
        target_id = global.player_id;
        alarm[10] = update_target_time;
    }
}

//audio
engine_sound_emitter = audio_emitter_create();
audio_emitter_falloff(engine_sound_emitter,
    global.SOUND_FALLOFF_REF_DIST,
    global.SOUND_FALLOFF_MAX_DIST,
    global.SOUND_FALLOFF_FACTOR);

#define scr_ship_advance_frame
///scr_ship_advance_frame()

//countdown hitstun and invincibility
hitstun = max(hitstun-global.game_speed, 0);
invincibility = max(invincibility-global.game_speed,0);

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
speed = global.game_speed*sm;
if(should_face_dir){
    image_angle = direction;
}

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));

#define scr_ship_hit
///scr_ship_hit(friendly_fire=false)

//Abstract function for when a ship collides with a projectile.

if(hp<=0) return undefined;

var ff = false;
if(argument_count==1){
    ff = argument[0];
}
if(is_friendly!=other.is_friendly || ff){

    if(invincibility>0){ //destroy bullet and exit early
        instance_destroy(other);
        scr_play_sound(snd_deflect,x,y);
        return undefined;
    }    

    //spawn projectile's hit particle
    if(variable_instance_exists(other,"hit_part")){
        part_type_direction(other.hit_part,other.direction,other.direction,0,0);
        part_type_orientation(other.hit_part,0,0,0,0,true);
        part_particles_create(global.partsys,other.x,other.y,other.hit_part,1);
    }
    
    //Apply armor 
    if(variable_instance_exists(id,"amr")){
        other.dmg = max(other.dmg-amr,global.MIN_DMG);
    }
    
    //flash white
    hitstun = log2(other.dmg+1)*2.2;
    
    //player hit specific code
    if(is_friendly){
        //TODO: apply screen shake?
        
        //apply screen flash
        if(id==global.player_id){
            global.flash_red_alpha += other.dmg/15;
        }
        
        //DIFFICULTY MOD: scale dmg down by spawn capacity
        if(!global.is_endless){
            other.dmg = max((1-global.spawn_cap*0.3)*other.dmg,global.MIN_DMG);
        }
    }
    else{ //enemy hit specific code
        //DIFFICULY MOD: increase player's atk if outnumbered
        other.dmg *= 1+global.spawn_cap*0.5;
    }
    
    //apply dmg + initiate death seq if hp <= 0
    hp -= other.dmg;
    if(hp <= 0){
        if(variable_instance_exists(id,"death_seq_cb")){
            script_execute(death_seq_cb);
        }
        else{
            instance_destroy();
        }
    }
    
    //audio
    scr_play_sound(snd_hitting,x,y);
    
    //destroy bullet
    instance_destroy(other);
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
#define scr_set_avoidance
///scr_set_avoidance(speed, turn)

//set foresight and avoid_arc based on speed and turn stats of the ship
//ADDS: foresight, avoid_arc, axy
var sp = argument[0];
var tn = argument[1]*global.SWERVE_TURN_MOD;

ax = 0;
ay = 0;
//time it takes to turn a certain angle
avoid_arc = ceil(67.5/tn);
//distance covered by one avoid arc
foresight = 0.4*avoid_arc*sp;
#define scr_ship_draw_ui
///scr_ship_draw_ui()

//draw any ui attached to the ship

//draw hp bar
if(hp<max_hp && global.player_id != id){
    var amt, w, h, px, py, uipos;
    amt = 100*hp/max_hp;
    w = hp_bar_width;
    h = global.ENEMY_HBAR_THICKNESS;
    px = x-w/2;
    py = y-sprite_yoffset-h;
    uipos = scr_game_to_gui(px,py);
    draw_healthbar(uipos[0],uipos[1],uipos[0]+w,uipos[1]+h,amt,global.C_ENEMY_BACK_HBAR,global.C_ENEMY_MIN_HBAR,global.C_ENEMY_MAX_HBAR,0,true,false);
}
