#define scr_ship_instantiate
///scr_ship_instantiate(is_friendly, ds_map, update_target_time=-1)

//SUPERCLASS CONSTRUCTOR: don't call directly
//hitstun and invincibility frames
is_friendly = argument[0];
var mp = argument[1];

hitstun = 0;
invincibility = 0;
threat = ds_map_find_value(mp,"threat");

//HACK
points = ds_map_find_value(mp, "score");

//update target time
if(!is_friendly){
    var utt = ds_map_find_value(mp,"update_target_time");
    if(utt != undefined){
        update_target_time = utt;
    }
    else if(argument_count==3){
        update_target_time = argument[2];
    }
    else{
        return undefined;
    }
    target_id = global.player_id;
    alarm[10] = update_target_time;
}

//audio
sound_emitter = audio_emitter_create();
audio_emitter_falloff(sound_emitter,
    global.SOUND_FALLOFF_REF_DIST,
    global.SOUND_FALLOFF_MAX_DIST,
    global.SOUND_FALLOFF_FACTOR);

#define scr_ship_advance_frame
///scr_ship_advance_frame()

//countdown hitstun and invincibility
hitstun = max(hitstun-global.game_speed, 0);
invincibility = max(invincibility-global.game_speed,0);

//update emitter
audio_emitter_position(sound_emitter,x,y,0);
audio_emitter_velocity(sound_emitter,hspeed,vspeed,0);

#define scr_ship_hit
///scr_ship_hit()

//Abstract function for when a ship collides with a projectile.

if(hp<=0) return undefined;

if(is_friendly!=other.is_friendly){

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
    if(!other.is_friendly){
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
audio_emitter_free(sound_emitter);

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