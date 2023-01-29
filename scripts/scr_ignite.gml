///scr_ignite()

is_wpn_on = true;

if(!scr_instance_exists(projectile_id)){ //create flame
    var f = scr_flame_plume_create(x+lengthdir_x(barrel_len,image_angle),y+lengthdir_y(barrel_len,image_angle),bullet_type,is_friendly);
    f.curr_speed = 0;
    f.direction = direction;
    f.image_angle = image_angle;
    f.dmg = dmg;
    projectile_id = f;
}
else{ //existing flame
    projectile_id.x = lengthdir_x(barrel_len,image_angle);
    projectile_id.y = lengthdir_y(barrel_len,image_angle);
    projectile_id.direction = direction;
    projectile_id.image_angle = image_angle;
    
    //produce recoil flash+animation
    rt_modifier = (modifier+1.0)/256.0;
    alarm[11] = recoil;
    l_bound_frame = shoot_frame;
    u_bound_frame = image_number;
}

return projectile_id;
