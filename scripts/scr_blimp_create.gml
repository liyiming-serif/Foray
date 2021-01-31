#define scr_blimp_create
///scr_blimp_create(x,y,direction)
var xv = argument[0];
var yv = argument[1];
var dir = argument[2];

with(instance_create(xv,yv,obj_blimp)){
    //initiallize stats
    var mp = ds_map_find_value(global.balloons, "blimp");
    scr_ship_instantiate(false,mp);
    
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    
    //set initial course
    direction = d_o;
    image_angle = direction;
    
    //mount wpns
    gid[0] = scr_wpn_create(x,y,0,"city_missile_gun",false);
    gid[1] = scr_wpn_create(x,y,0,"player_missile_gun",false); //left
    gid[2] = scr_wpn_create(x,y,0,"player_missile_gun",false); //right
    
    //ai params
    scr_set_avoidance(curr_speed, turn);
    player_noticed = false;
    is_fleeing = false;
    state = blimp_ai_states.POSITIONING;
    
    return id;
}

#define scr_blimp_position
///scr_blimp_position()

//control blimp movement

#define scr_blimp_flee
///scr_blimp_flee()

#define scr_blimp_aim_city
///scr_blimp_aim_city()

//control blimp firing


#define scr_blimp_aim_player
///scr_blimp_aim_player()


#define scr_blimp_update_wpns
///scr_blimp_update_wpns()

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
#define scr_blimp_idle
///scr_blimp_idle()