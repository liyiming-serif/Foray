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