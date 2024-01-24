#define scr_wpn_equip
///scr_wpn_equip(x, y, obj_ind, dir, is_friendly, dmg_mod=1)

//Helper for creating a generic gun from JSON.
//Additional JSON properties should be read in wpn obj's create event.

var mp = ds_map_find_value(global.weapons,argument[3]);
//wpn not found, returning null id
if(mp==undefined){
    return 0;
}

with(scr_instance_create(
    argument[0],
    argument[1],
    argument[2],
    argument[3],
    argument[4])){
  
    //AI mods
    if(argument_count == 6){
        dmg_mod = argument[5];
        //apply dmg mod to base wpn dmg
        //since wpn creation already passed
        dmg *= dmg_mod;
        if(variable_instance_exists(id, "sp_dmg")){
            sp_dmg *= dmg_mod;
        }
    }
    if(!is_friendly){
        if(variable_instance_exists(id, "muzzle_vel")){
            muzzle_vel *= global.AI_SHOT_SP_REDUC;
        }
        if(variable_instance_exists(id, "accuracy")){
            accuracy *= global.AI_SHOT_ACC_REDUC;
        }
        if(variable_instance_exists(id, "shoot_rate")){
            shoot_rate *= global.AI_SHOT_RATE_REDUC;
        }
        
        if(variable_instance_exists(id, "range")){
            range[0] *= global.AI_SHOT_RANGE_REDUC;
            range[1] *= global.AI_SHOT_RANGE_REDUC;
        }
    }

    return id;
}

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
#define scr_wpn_fire_sound
///scr_wpn_fire_sound()
//wpn helper function for playing a sound or sound group
//req: shoot_snd
//opt: shoot_snd_num

var s;
if(variable_instance_exists(id,num_sounds)){
    //sound group: shoot_snd is the prefix string
    s = scr_play_sound_randomize(shoot_snd, shoot_snd_num, x, y);
}
else{
    //single sound: shoot_snd is the asset name
    s = scr_play_sound(asset_get_index(shoot_snd), x, y);
}

//reduce sound by 50% if coming from player
if(is_friendly){
    audio_sound_gain(s,0.5,0);
}