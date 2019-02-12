#define scr_wpn_create
///scr_wpn_create(x, y, dir, wpn_name, is_friendly)

//Used for creating a generic gun from JSON.
//Additional JSON properties should be read in wpn obj's create event.

var mp = ds_map_find_value(global.weapons,argument3);

with(instance_create(argument0,argument1,asset_get_index(ds_map_find_value(mp,"obj_ind")))){
    key = argument3;
    is_friendly = argument4;
    image_angle = argument2;
    image_angle_prev = image_angle;
    dx = 0;
    dy = 0;
    av = 0;
    
    //scr_shoot attributes
    bullet_type = asset_get_index(ds_map_find_value(mp,"projectile_ind"));
    shoot_rate = ds_map_find_value(mp,"shoot_rate");
    shoot_counter = 0;
    recoil = ds_map_find_value(mp,"recoil"); //num frames gun and plane flash from firing
    accuracy = ds_map_find_value(mp,"accuracy");
    muzzle_vel = ds_map_find_value(mp,"speed");
    dmg = ds_map_find_value(mp,"dmg");
    range[0] = ds_list_find_value(ds_map_find_value(mp,"range"),0);
    range[1] = ds_list_find_value(ds_map_find_value(mp,"range"),1);
    if(ds_map_exists(mp,"barrel_len")){
        barrel_len = ds_map_find_value(mp,"barrel_len");
    }
    else{
        barrel_len = sprite_width;
    }
    
    //AI mods
    if(!is_friendly){
        muzzle_vel *= global.AI_SHOT_SP_REDUC;
        accuracy *= global.AI_SHOT_ACC_REDUC;
        shoot_rate *= global.AI_SHOT_RATE_REDUC;
        range[0] *= global.AI_SHOT_RANGE_REDUC;
        range[1] *= global.AI_SHOT_RANGE_REDUC;
    }
    
    //callbacks
    on_click_cb = asset_get_index(ds_map_find_value(mp,"on_click_cb"));
    pressed_cb = asset_get_index(ds_map_find_value(mp,"pressed_cb"));
    on_release_cb = asset_get_index(ds_map_find_value(mp,"on_release_cb"));
    
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
    
    return id;
}

#define scr_shoot
///scr_shoot()
//Generic shooting callback. Can be expanded and customized.

if(shoot_counter < shoot_rate){
    return undefined;
}
shoot_counter = 0;
//produce recoil flash+animation
rt_modifier = (modifier+1.0)/256.0;
alarm[11] = recoil;
l_bound_frame = shoot_frame;
u_bound_frame = image_number;

/*COMPUTE DIRECTIONAL INFLUENCE*/

//compute linear velocity w/ respect to fire angle
var refx, refy, lv;
refx = lengthdir_x(1,image_angle);
refy = lengthdir_y(1,image_angle);
lv = dot_product(dx,dy,refx,refy);

//actually create bullet
var b = instance_create(x+lengthdir_x(barrel_len,image_angle),y+lengthdir_y(barrel_len,image_angle),bullet_type);
if(is_friendly){
    b.direction = image_angle+2*av+random_range(-accuracy,accuracy);
}
else{
    b.direction = image_angle+av+random_range(-accuracy,accuracy);
}
b.speed = global.game_speed*(muzzle_vel + lv);
b.image_angle = b.direction;
b.alarm[0] = random_range(range[0],range[1])/muzzle_vel;
b.dmg = dmg;
b.is_friendly = is_friendly;

//produce muzzle flare [optional]
if(muzzle_flare!=undefined){
    part_type_life(muzzle_flare, muzzle_flare_life[0], muzzle_flare_life[1]);
    part_type_direction(muzzle_flare,b.direction,b.direction,0,0);
    part_type_orientation(muzzle_flare,0,0,0,0,true);
    part_type_speed(muzzle_flare,lv,lv,0,0);
    part_particles_create(global.partsys,b.x,b.y,muzzle_flare,1);
}

return b;

#define scr_do_nothing
///scr_do_nothing()

//placeholder script to save on error-checking
return undefined;
#define scr_wpn_shade
///scr_wpn_shade()

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
shader_set(shader_pal_swap);
shader_set_uniform_f(row_ref, rt_modifier);
texture_set_stage(palette_ref, global.palette_texture);
draw_self();
shader_reset();

#define scr_wpn_advance_frame
///scr_wpn_advance_frame()

if(image_index>=u_bound_frame){
    image_index = l_bound_frame;
}
else if(image_index<l_bound_frame){
    image_index = l_bound_frame;
}

#define scr_cannon_shoot
///scr_cannon_shoot()

var b = scr_shoot();
if(b!=undefined){
    b.image_angle = 0;
}
return b;