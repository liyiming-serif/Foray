#define scr_wpn_equip
///scr_wpn_equip(x, y, obj_ind, dir, wpn_name, is_friendly, dmg_mod=1)

//Used for creating a generic gun from JSON.
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
    argument[4],
    argument[5])){
  
    //AI mods
    if(argument_count == 7){
        dmg_mod = argument[6];
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