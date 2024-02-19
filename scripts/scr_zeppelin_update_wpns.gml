#define scr_zeppelin_update_wpns
///scr_zeppelin_update_wpns()

//Update weapon position and image angle. Call during the end step.
var r, t;
//front wpn
if(scr_instance_exists(gid[0])){
    r = sprite_width-sprite_xoffset;
    t = image_angle;
    scr_ship_update_wpn(r,t,gid[0]);
}
//left wpn
if(scr_instance_exists(gid[1])){
    r = sprite_yoffset;
    t = image_angle+90;
    scr_ship_update_wpn(r,t,gid[1]);
}
//right wpn
if(scr_instance_exists(gid[2])){
    r = sprite_height-sprite_yoffset;
    t = image_angle-90;
    scr_ship_update_wpn(r,t,gid[2]);
}
//mine layer
if(scr_instance_exists(gid[3])){
    r = sprite_xoffset-12;
    t = image_angle+180;
    scr_ship_update_wpn(r,t,gid[3]);
}


#define scr_zeppelin_aim
///scr_zeppelin_aim()

//aim if in range
if(scr_instance_exists(target_id) && distance_to_object(target_id)<min_range){
    //fire wpn depending on angle
    var pa = point_direction(x, y, target_id.x, target_id.y);
    var da = angle_difference(pa,image_angle);
    
    if(da >= -45 && da < 45){ //front
        scr_wpn_fire(gid[0],"pressed");
    }
    else if(da >= 45 && da < 135){ //left
        scr_wpn_fire(gid[1],"pressed");
    }
    else if(da >= 135 || da < -135){ //back mine-layer
        scr_wpn_fire(gid[3],"pressed");
    }
    else if(da >= -135 && da < -45){ //right
        scr_wpn_fire(gid[2],"pressed");
    }
}

#define scr_zeppelin_turn
///scr_zeppelin_turn()

//Turn the blimp towards dest
if(scr_instance_exists(global.city_id)){
    scr_c_engine_turn(global.city_id.x, global.city_id.y-36, true);
}
else{
    scr_c_engine_turn(room_width/2, room_width/2, true);
}