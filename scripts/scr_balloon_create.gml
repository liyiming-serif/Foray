#define scr_balloon_create
///scr_balloon_create(x,y,wpn_name,is_armored,path,dest_x=x,dest_y=y)
var xv = argument[0];
var yv = argument[1];
var wpn_name = argument[2];

with(instance_create(xv,yv,obj_balloon)){
    //initiallize stats
    var mp = ds_map_find_value(global.balloons, "balloon");
    
    scr_ship_instantiate(false,mp);
    
    hp = ds_map_find_value(mp, "max_hp");
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    gun_turn = ds_map_find_value(mp, "gun_turn");
    alert_range = ds_map_find_value(mp, "alert_range");
    
    is_armored = argument[3];
    future_path = argument[4]; //TODO: scripted balloons can follow predetermined paths
    if(argument_count>5){
        dest_x = argument[5];
        dest_y = argument[6];
        in_position = false;
    }
    else{
        in_position = true;
    }
    
    //mount weapons
    gid[0] = scr_wpn_create(x,y,0,wpn_name,false);
    gid[1] = 0;
    if(scr_instance_exists(gid[0])){
        gun_turn -= gun_turn*(1-7/gid[0].recoil);
        gid[0].image_angle = 270;
        og_accuracy = ds_map_find_value(mp,"accuracy_coeff")*gid[0].accuracy;
        accuracy = og_accuracy;
    }
    if(is_armored){
        //create armor
        gid[1] = instance_create(x,y,obj_balloon_amr);
        
        gid[1].state = shield_states.DOWN;
        gid[1].anim_time = ds_map_find_value(mp, "amr_anim_time");
        gid[1].up_lag = ds_map_find_value(mp, "amr_up_lag");
        gid[1].down_lag = ds_map_find_value(mp, "amr_down_lag");
        //hack: armor needs at least balloon's anim length
        //future: if it needs to know more, pass balloon ref to armor
        gid[1].balloon_frames = image_number;
    }
    
    image_speed = 0.4;
    
    debug = "";
    return id;
}



#define scr_balloon_navigate
///scr_balloon_navigate()

if(scr_instance_exists(gid[1]) && gid[1].visible){
    //hiding behind armor
    speed = 0;
}
else if(!in_position){
    move_towards_point(dest_x,dest_y,curr_speed*global.game_speed);
    if(distance_to_point(dest_x,dest_y)<speed){
        in_position = true;
        speed = 0;
    }
}
else{
    speed = 0;
}

//TODO: scripted balloons can fallow predetermined paths

#define scr_balloon_aim
///scr_balloon_aim()

//aim if in range
if(scr_instance_exists(target_id) && distance_to_object(target_id)<gid[0].range[0]*0.6){
    //turn the gun
    var pa = point_direction(x, y, target_id.x, target_id.y);
    var da = angle_difference(pa,gid[0].image_angle);
    var ta = min(abs(da),gun_turn);
    gid[0].image_angle += global.game_speed*ta*sign(da);
    
    //shoot if within angle
    if(abs(da) <= accuracy){
        scr_ship_shoot(gid[0],"pressed");
    }
}

#define scr_balloon_guard
///scr_balloon_guard()

//TODO: change logic to put up shield friendly bullet is within range

if(gid[1].state == shield_states.DOWN && scr_balloon_firing_in_range()){
    //raise armor if target is firing in range
    gid[1].state = shield_states.GOING_UP;
}
else if(gid[1].state == shield_states.UP && !scr_balloon_firing_in_range()){
    //drop armor if target is no longer firing in range
    gid[1].state = shield_states.GOING_DOWN;
}


#define scr_balloon_hit
///scr_balloon_hit()

if(scr_instance_exists(gid[1]) && scr_balloon_amr_is_up()){
    if(is_friendly!=other.is_friendly){
        instance_destroy(other);
        part_particles_create(global.partsys,other.x,other.y,global.deflect,1);
    }
}
else{
    scr_ship_hit();
}

#define scr_balloon_update_wpns
///scr_balloon_update_wpns()

//Update weapon position. Call during the end step.

if(scr_instance_exists(gid[0])){
    scr_ship_update_wpn(6,gid[0].image_angle,gid[0],false);
}

if(scr_instance_exists(gid[1]) && gid[1].visible){
    gid[1].x = x;
    gid[1].y = y;
    if(scr_balloon_amr_is_up()){
        gid[1].image_index = image_index;
    }
}

#define scr_balloon_debug
draw_text(x-120,y-64,debug);
scr_ship_shade();

#define scr_balloon_firing_in_range
///scr_balloon_firing_in_range()

if(scr_instance_exists(target_id) &&
    distance_to_object(target_id)<alert_range &&
    mouse_check_button(mb_left)){
    
    return true;
}
else{
    return false;
}

#define scr_balloon_amr_is_up
///scr_balloon_amr_is_up()

//gid[1] must be instantiated
return gid[1].state == shield_states.UP || gid[1].state == shield_states.GOING_DOWN;