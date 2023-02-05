///scr_ignite()

is_wpn_on = true;

//create flame
if(!scr_instance_exists(projectile_id)){
    var f = scr_flame_plume_create(x+lengthdir_x(barrel_len,image_angle),y+lengthdir_y(barrel_len,image_angle),bullet_type,is_friendly);
    f.curr_speed = 0;
    f.direction = direction;
    f.image_angle = image_angle;
    f.dmg = dmg;
    projectile_id = f;
}
else{ //existing flame
    //control non-lingering flame
    if(variable_instance_exists(projectile_id,"linger_alarm")){
        if(!projectile_id.alarm[projectile_id.linger_alarm]){
            projectile_id.x = x+lengthdir_x(barrel_len,image_angle);
            projectile_id.y = y+lengthdir_y(barrel_len,image_angle);
            projectile_id.direction = direction;
            projectile_id.image_angle = image_angle;
        }
    }
    
    //produce recoil flash+animation
    if(!variable_instance_exists(projectile_id,"linger_alarm") ||
        !projectile_id.alarm[projectile_id.linger_alarm]) {
            rt_modifier = (modifier+1.0)/256.0;
            alarm[11] = recoil;
            l_bound_frame = shoot_frame;
            u_bound_frame = image_number;
    }
}

return projectile_id;
