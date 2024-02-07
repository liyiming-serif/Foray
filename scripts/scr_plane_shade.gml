#define scr_plane_shade
///scr_plane_shade()

//cast shadow
scr_cast_shadow();

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
if (is_stealable && image_index%3>1.5){ //apply red/warn flash
    if(global.AB_USE_CHARGE_STEAL && is_targeted){
        shader_set(shader_flash);
        shader_set_uniform_f_array(flash_color_ref, global.C_FLASH_WARN_NORM);
    }
    else{
        shader_set(shader_hurt_flash);
    }
}
else if (hitstun>0){ //apply white flash
    shader_set(shader_hit_flash);
}
else{ //apply palette swap shader
    shader_set(shader_pal_swap);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(row_ref, rt_modifier); 
}
draw_self();
shader_reset();

#define scr_plane_advance_frame
///scr_plane_advance_frame()

///Update components
scr_c_loop();

//emit far contrail if boosting
trail_counter = min(trail_counter+1,global.TRAIL_RATE);
if(is_boosting && trail_counter>=global.TRAIL_RATE){
    var px, py;
    px = x+lengthdir_x(-32,image_angle);
    py = y+lengthdir_y(-32,image_angle);
    part_type_direction(global.trail_far,image_angle,image_angle,0,0);
    part_type_orientation(global.trail_far,0,0,0,0,true);
    part_type_speed(global.trail_far,speed,speed,0,0);
    part_particles_create(global.partsys,px,py,global.trail_far,1);
    trail_counter = 0;
}

//evaluate hp and produce dmg indicators
for(var i=array_length_1d(global.DMG_THRESHOLDS)-1; i>=0; i--;){
    if(smoke_counter<global.SMOKE_RATE){
        smoke_counter++;
        break;
    } //smoke not ready yet
    if(hp<max_hp*global.DMG_THRESHOLDS[i]){
        var px, py;
        px = x+irandom_range(-sprite_width/2,sprite_width/2);
        py = y+irandom_range(-sprite_height/2,sprite_height/2);
        part_type_direction(global.dmg_ind[i],image_angle,image_angle,0,0);
        part_type_orientation(global.dmg_ind[i],0,0,0,0,true);
        part_type_speed(global.dmg_ind[i],speed*0.6,speed*0.6,0,0);
        part_particles_create(global.partsys,px,py,global.dmg_ind[i],1);
        smoke_counter = 0;
        break;
    } //produce smoke particle
}

//advance frame
if(image_index>=u_bound_frame && hp > 0){
    //special rolling conditions
    if(is_rolling){
        if(roll_invuln>0){
            l_bound_frame = roll_start_frame;
        }
        else{
            l_bound_frame = roll_end_frame;
            u_bound_frame = image_number;
        }
    }
    
    image_index = l_bound_frame;
}
else if(image_index<l_bound_frame){
    image_index = l_bound_frame;
}

//rolling mechanics
if(is_rolling){
    scr_c_plane_engine_rolling();
}

//draw depth
if(is_rolling){
    depth = -2;
}
else{
    depth = 0;
}

//countdown rolling maneuver
roll_invuln = max(0, roll_invuln-global.game_speed);
roll_cool = max(0, roll_cool-global.game_speed);

//charge stealing: reset charge progress when not aiming
if(global.AB_USE_CHARGE_STEAL && !is_targeted){
    steal_progress = 0;
}


#define scr_plane_crash
///scr_plane_crash()

//reset tint and shaders
angles = -1;

//set crash sprite
sprite_index = spr_plane1_land;
image_index = 0;
l_bound_frame = 0;
u_bound_frame = image_number+1;
image_speed = 0.2;

//set crash course
direction += random_range(-10, 10);

//stop other animation seqs
alarm[11] = -1;

//create explosion particle
part_particles_create(global.partsys,x,y,global.boom_air,1);

//gc wpn only
scr_ship_gc_wpns();

//switch to crashing sound
audio_stop_sound(engine_sound);
scr_play_sound(snd_explosion_m,x,y);
crashing_sound = scr_play_sound(snd_falling,x,y);


#define scr_plane_steal
///scr_plane_steal()

//Run the moment the player avatar's jump anim finishes and this plane
//becomes the active player.

//create player plane
var nw_plane = scr_player_create(x,y,direction,key);
nw_plane.speed = speed;
//play buckling animation for new plane
nw_plane.sprite_index = spr_plane1_buckle;
nw_plane.image_index = 0;
nw_plane.l_bound_frame = 0;
nw_plane.u_bound_frame = nw_plane.image_number+1;
//start tint green coroutine
nw_plane.timeline_index = tl_steal_coroutine;
nw_plane.timeline_position = 24;
nw_plane.timeline_running = true;
//invuln during recovery frames
nw_plane.invuln = global.SPAWN_INVULN*0.5;
//inherit old plane's hp
nw_plane.hp = hp;
//restore a bit of hp and double invuln frames if stealing new plane
switch(object_index){
    case obj_enemy:
    case obj_enemy_pyro:
        nw_plane.invuln = global.SPAWN_INVULN;
        nw_plane.timeline_position = 0;
        nw_plane.hp = min(hp+max_hp*0.7, max_hp);
        break;
    default:
        break;
}

//destroy old stolen plane
instance_destroy();

#define scr_plane_gen_weakspot
///scr_plane_gen_weakspot(starting_angle, angle_variance=0)

is_stealable = true;
reticle_scale = 3;

if(global.AB_USE_ANGLE_STEAL){
    var w;
    
    //TODO: calculate width of angles based on model quality
    w = pi;
    
    starting_angle = argument[0];
    if(argument_count > 1){
        starting_angle += random_range(-argument[1], argument[1]);
    }
    
    angles[0] = starting_angle-w/2;
    if(angles[0]<-pi){
        angles[0]+=2*pi;
    }
    
    angles[1] = angles[0]+w;
    if(angles[1]>pi){
        angles[1]-=2*pi;
    }
}

#define scr_plane_shoot
///scr_plane_shoot(cb_type)

//TEMP: planes *cannot* shoot while rolling
if(is_rolling){
    return undefined;
}

//wrapper around executing gid callbacks for reducing copied code
var cb, ret;
cb = argument[0];
ret= scr_wpn_fire(gid,cb);
if(ret!=undefined){
    //change plane to shooting sprite
    sprite_index = spr_plane1_shoot;
    alarm[11] = gid.recoil;
}
return ret;

#define scr_plane_gc
//scr_plane_gc

scr_play_sound(snd_explosion_m,x,y);

//clean up all sounds under emitter
audio_stop_sound(engine_sound);
if(variable_instance_exists(id,"crashing_sound")){
    audio_stop_sound(crashing_sound);
}

//dispose function for all ships
scr_ship_gc();