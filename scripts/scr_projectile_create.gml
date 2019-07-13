#define scr_projectile_create
///scr_projectile_create(x,y,projectile_name,is_friendly)

//Wrapper around instance_create that also inits JSON properties
var mp = ds_map_find_value(global.projectiles,argument[2]);
//projectile not found, returning null id
if(mp==undefined){
    return 0;
}

with(instance_create(argument[0],argument[1],asset_get_index(ds_map_find_value(mp,"obj_ind")))){
    //required JSON params
    is_friendly = argument[3];
    anim_speed = ds_map_find_value(mp,"anim_speed");
    if(anim_speed!=undefined){
        image_speed = anim_speed;
    }
    hit_part = variable_global_get(ds_map_find_value(mp,"hit_part"));
    
    //palette swap shader
    if(is_friendly){
        //BETA: load palette based on dmg stat
        modifier = ds_map_find_value(mp,"palette1");
    }
    else{
        modifier = 129;
    }
    rt_modifier = modifier/256.0;
    palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
    row_ref = shader_get_uniform(shader_pal_swap, "row");
    
    //optional parameters
    var v = ds_map_find_value(mp,"miss_part");
    if(v!=undefined){
        miss_part = variable_global_get(v);
    }
    
    return id;
}

#define scr_projectile_shade
///scr_projectile_shade()

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
shader_set(shader_pal_swap);
shader_set_uniform_f(row_ref, rt_modifier);
texture_set_stage(palette_ref, global.palette_texture);
draw_self();
shader_reset();
#define scr_projectile_step
///scr_projectile_step()
//generic step event for a projectile

//adjust speed based on game_speed
speed = global.game_speed*(curr_speed);
ttl = max(0,ttl-global.game_speed);

///out of range: kms+spawn miss part
if(ttl<=0){
    if(variable_instance_exists(id,"miss_part")){
        part_type_direction(miss_part,direction,direction,0,0);
        part_type_orientation(miss_part,0,0,0,0,true);
        part_particles_create(global.partsys,x,y,miss_part,1);
    }
    instance_destroy();
}