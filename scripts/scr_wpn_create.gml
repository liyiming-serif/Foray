#define scr_wpn_create
///scr_wpn_create(x, y, dir, wpn_name, is_friendly, dmg_mod=1)

//Used for creating a generic gun from JSON.
//Additional JSON properties should be read in wpn obj's create event.

var mp = ds_map_find_value(global.weapons,argument[3]);
//wpn not found, returning null id
if(mp==undefined){
    return 0;
}

with(instance_create(argument[0],argument[1],asset_get_index(ds_map_find_value(mp,"obj_ind")))){
    //graphical
    var v = ds_map_find_value(mp,"spr_ind");
    if(v!=undefined){
        sprite_index = asset_get_index(v);
        
        //animation
        anim_speed = ds_map_find_value(mp,"anim_speed");
        image_speed = anim_speed;
        
        shoot_frame = ds_map_find_value(mp,"shoot_frame");
        l_bound_frame = 0;
        u_bound_frame = shoot_frame;
    
        //palette swap shader
        modifier = ds_map_find_value(mp,"palette");
        rt_modifier = modifier/256.0;
        palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
        row_ref = shader_get_uniform(shader_pal_swap, "row");
    }
    else{
        anim_speed = 0; 
        
        shoot_frame = 0;
        l_bound_frame = 0;
        u_bound_frame = 0;
        
        modifier = 0;
        rt_modifier = 0;
        palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
        row_ref = shader_get_uniform(shader_pal_swap, "row");
    }

    key = argument[3];
    is_friendly = argument[4];
    image_angle = argument[2];
    image_angle_prev = image_angle;
    dx = 0;
    dy = 0;
    av = 0;
    
    //optional dmg modifier
    display_dmg = 1;
    if(argument_count==6){
        display_dmg = argument[5];
    }
    
    var sr = ds_map_find_value(mp,"shoot_rate");
    if(sr!=undefined){
        shoot_rate = sr;
    }
    
    var m = ds_map_find_value(mp,"muzzle_vel");
    if(m!=undefined){
        muzzle_vel = m;
    }
    
    var r = ds_map_find_value(mp,"range");
    if(r!=undefined){
        range[0] = ds_list_find_value(ds_map_find_value(mp,"range"),0);
        range[1] = ds_list_find_value(ds_map_find_value(mp,"range"),1);
    }

    if(ds_map_exists(mp,"barrel_len")){
        barrel_len = ds_map_find_value(mp,"barrel_len");
    }
    else{
        barrel_len = sprite_width;
    }
    
    //AI mods
    if(!is_friendly){
        if(variable_instance_exists(id, "muzzle_vel")){
            muzzle_vel *= global.AI_SHOT_SP_REDUC;
        }
        
        accuracy *= global.AI_SHOT_ACC_REDUC;
        if(variable_instance_exists(id, "shoot_rate")){
            shoot_rate *= global.AI_SHOT_RATE_REDUC;
        }
        
        if(r!=undefined){
            range[0] *= global.AI_SHOT_RANGE_REDUC;
            range[1] *= global.AI_SHOT_RANGE_REDUC;
        }
    }
    
    //callbacks
    on_click_cb = asset_get_index(ds_map_find_value(mp,"on_click_cb"));
    pressed_cb = asset_get_index(ds_map_find_value(mp,"pressed_cb"));
    on_release_cb = asset_get_index(ds_map_find_value(mp,"on_release_cb"));
    
    //optional parameters
    v = ds_map_find_value(mp,"muzzle_flare");
    if(v!=undefined){
        muzzle_flare = variable_global_get(v);
    }
    v = ds_map_find_value(mp,"rounds");
    if(v!=undefined){
        max_rounds = v;
        rounds = max_rounds;
    }
    v = ds_map_find_value(mp,"reload_rate");
    if(v!=undefined){
        reload_rate = v;
        reload_counter = reload_rate;
        reload_counter_prev = reload_counter;
        
        wpn_sound_emitter = audio_emitter_create();
        audio_emitter_falloff(wpn_sound_emitter,
            global.SOUND_FALLOFF_REF_DIST,
            global.SOUND_FALLOFF_MAX_DIST,
            global.SOUND_FALLOFF_FACTOR);
        charge_sound = audio_play_sound_on(wpn_sound_emitter, snd_charging, true, 0);
        audio_pause_sound(charge_sound);
    }
    v = ds_map_find_value(mp,"charge_part");
    if(v!=undefined){
        charge_part = variable_global_get(ds_list_find_value(v,0));
        charge_part_life[0] = ds_list_find_value(v,1);
        charge_part_life[1] = ds_list_find_value(v,2);
        charge_part_frames = 0;
    }
    v = ds_map_find_value(mp,"sweep_angle");
    if(v!=undefined){
        sweep_angle = v;
    }
    v = ds_map_find_value(mp,"muzzle_vel_var");
    if(v!=undefined){
        muzzle_vel_var = v;
    }
    v = ds_map_find_value(mp,"hp_reduc");
    if(v!=undefined){
        hp_reduc = v;
    }
    
    return id;
}

#define scr_shoot
///scr_shoot()
//Generic shooting callback. Can be expanded and customized.
//req: shoot_rate, shoot_frame, dx, dy

//check cooldown
if(shoot_counter < shoot_rate){
    return undefined;
}
shoot_counter = 0;
//produce recoil flash+animation
rt_modifier = (modifier+1.0)/255.0;
alarm[global.MUZZLE_FLASH] = recoil;
//animate wpn firing
l_bound_frame = shoot_frame;
u_bound_frame = image_number;

/*COMPUTE DIRECTIONAL INFLUENCE*/

//compute linear velocity w/ respect to fire angle
var refx, refy, lv;
refx = lengthdir_x(1,image_angle);
refy = lengthdir_y(1,image_angle);
lv = dot_product(dx,dy,refx,refy);

//actually create bullet
var b = scr_projectile_create(x+lengthdir_x(barrel_len,image_angle),y+lengthdir_y(barrel_len,image_angle),bullet_type,is_friendly);
if(is_friendly){
    b.direction = image_angle+2*av+random_range(-accuracy,accuracy);
}
else{
    b.direction = image_angle+av+random_range(-accuracy,accuracy);
}
b.curr_speed = muzzle_vel + lv;
b.image_angle = b.direction;
b.ttl = random_range(range[0],range[1])/muzzle_vel; //time to live
b.dmg = dmg;

//produce muzzle flare [optional]
if(variable_instance_exists(id,"muzzle_flare")){
    part_type_direction(muzzle_flare,b.direction,b.direction,0,0);
    part_type_orientation(muzzle_flare,0,0,0,0,true);
    part_type_speed(muzzle_flare,lv,lv,0,0);
    part_particles_create(global.partsys,b.x,b.y,muzzle_flare,1);
}

return b;

#define scr_lay_mine
///scr_lay_mine()

//check cooldown & spawn limit
if(shoot_counter<shoot_rate || global.spawn_cap>2){
    return undefined;
}
shoot_counter = 0;

//Actually spawn mine
var dir, vel;
dir = image_angle+random_range(-accuracy,accuracy);
//spawn in player's direction if possible
if(scr_instance_exists(global.player_id)){
    dir = point_direction(x,y,global.player_id.x,global.player_id.y);
    dir += random_range(-accuracy,accuracy);
}
vel = global.game_speed*((muzzle_vel)+random_range(-muzzle_vel_var,muzzle_vel_var));
var b = scr_skymine_create(x,y,dir,vel);
b.hp *= hp_reduc;
scr_play_sound(snd_spawn_skymine,x,y);
return b;

#define scr_do_nothing
///scr_do_nothing()

//placeholder script to save on error-checking
return undefined;
#define scr_wpn_shade
///scr_wpn_shade()

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
if(sprite_index != -1){
    shader_set(shader_pal_swap);
    shader_set_uniform_f(row_ref, rt_modifier);
    texture_set_stage(palette_ref, global.palette_texture);
    draw_self();
    shader_reset();
}

#define scr_wpn_advance_frame
///scr_wpn_advance_frame()
if(sprite_index != undefined){
    if(image_index>=u_bound_frame){
        image_index = l_bound_frame;
    }
    else if(image_index<l_bound_frame){
        image_index = l_bound_frame;
    }
}

#define scr_cannon_shoot
///scr_cannon_shoot()

var b = scr_shoot();
if(b!=undefined){
    b.image_angle = 0;
}
return b;

#define scr_charge_shoot
///scr_charge_shoot()

if(rounds<=0){
    //update emitter
    audio_emitter_position(wpn_sound_emitter,x,y,0);
    audio_emitter_velocity(wpn_sound_emitter,hspeed,vspeed,0);
    
    //reload finished
    if(reload_counter<=0){
        reload_counter = reload_rate;
        rounds = max_rounds;
        return undefined;
    }
    else{
    //reloading...
        reload_counter = max(0,reload_counter-global.game_speed);
        //optional: create charge effect
        if(variable_instance_exists(id,"charge_part")){
            if(charge_part_frames<=0){
                charge_part_frames = min(reload_counter,random_range(charge_part_life[0],charge_part_life[1]));
                
                //create charge particle
                var sp = point_distance(0,0,dx,dy);
                var dir = point_direction(0,0,dx,dy);
                part_type_direction(charge_part,dir,dir,0,0);
                part_type_orientation(charge_part,image_angle,image_angle,0,0,false);
                part_type_speed(charge_part,sp,sp,0,0);
                part_type_life(charge_part,charge_part_frames,charge_part_frames);
                var xl, yl;
                xl = x+lengthdir_x(barrel_len,image_angle);
                yl = y+lengthdir_y(barrel_len,image_angle);
                part_particles_create(global.partsys,xl,yl,charge_part,1);
            }
            else{
                //current charge particle still exists
                charge_part_frames--;
            }
        }
        return undefined;
    }
}
else{
    //fire! (hardcoded to on_release)
    var b = script_execute(on_release_cb);
    if(b!=undefined){
        rounds--;
    }
    return b;
}

#define scr_charge_scatter
///scr_charge_scatter()

//Wrapper around scr_shoot that shoots in an even spread
//Only capatible with charge_shooting
var og_angle = image_angle;

image_angle += ((rounds-0.5)/max_rounds)*sweep_angle - sweep_angle/2;
var b = scr_shoot();

image_angle = og_angle;
return b;
#define scr_wpn_end_step
///scr_wpn_end_step()

//update linear and angular velocity
av = angle_difference(image_angle,image_angle_prev);
dx = x-xprevious;
dy = y-yprevious;

#define scr_wpn_anim_end
///scr_wpn_anim_end()

//finish shooting animation
if(sprite_index != undefined){
    l_bound_frame = 0;
    u_bound_frame = shoot_frame;
}

