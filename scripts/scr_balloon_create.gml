#define scr_balloon_create
///scr_balloon_create(x,y,wpn_name,isArmored,sweep_angle,path,dest_x=x,dest_y=y)
var xv = argument[0];
var yv = argument[1];
var wpn_name = argument[2];

with(instance_create(xv,yv,obj_balloon)){
    //initiallize stats
    var mp = ds_map_find_value(global.balloons, "balloon");
    
    hp = ds_map_find_value(mp, "max_hp");
    curr_speed = ds_map_find_value(mp, "speed");
    gun_turn = ds_map_find_value(mp, "gun_turn");
    
    is_armored = argument[3];
    sweep_angle = argument[4];
    future_path = argument[5];
    if(argument_count>6){
        dest_x = argument[6];
        dest_y = argument[7];
        in_position = false;
    }
    else{
        in_position = true;
    }
    
    //mount weapons
    gid[0] = scr_wpn_create(x,y,0,wpn_name,false);
    if(scr_instance_exists(gid[0])){
        gun_turn -= gun_turn*(1-7/gid[0].recoil);
        gid[0].image_angle = 270;
    }
    if(is_armored){
        //TODO: create armor
    }
    
    image_speed = 0.4;
    
    scr_ship_instantiate(false,ds_map_find_value(mp, "update_target_time"));
    
    debug = "";
    return id;
}



#define scr_balloon_navigate
///scr_balloon_navigate()

if(!in_position){
    move_towards_point(dest_x,dest_y,curr_speed*global.game_speed);
    if(distance_to_point(dest_x,dest_y)<speed){
        in_position = true;
        speed = 0;
    }
}
else{
    speed = 0;
}

//TODO: scripted balloons can fallow pre-determined paths

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
    if(abs(da) <= sweep_angle){
        scr_ship_shoot(gid[0],"pressed");
    }
}

#define scr_balloon_update_wpn
///scr_balloon_update_wpn()

//Update weapon position. Call during the end step.

if(scr_instance_exists(gid[0])){
    scr_ship_update_wpn(6,gid[0].image_angle,gid[0],false);
}

#define scr_balloon_debug
draw_text(x-120,y-64,debug);
scr_ship_shade();