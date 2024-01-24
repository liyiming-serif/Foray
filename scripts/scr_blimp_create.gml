#define scr_blimp_create
///scr_blimp_create(x,y,direction)
var xv = argument[0];
var yv = argument[1];
var dir = argument[2];

with(instance_create(xv,yv,obj_blimp)){
    //initiallize stats
    var mp = ds_map_find_value(global.ships, "blimp");
    scr_ship_init(false,mp);
    
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    
    //set initial course
    direction = dir;
    image_angle = direction;
    
    //mount wpns
    gid[0] = scr_wpn_equip(x,y,obj_city_missile_gun,0,false);
    gid[1] = scr_wpn_equip(x,y,obj_player_missile_gun,0,false); //left
    gid[2] = scr_wpn_equip(x,y,obj_player_missile_gun,0,false);//right
    
    //ai params
    //increase sight modifier for oblong shape
    scr_ai_set_avoidance(neutral_speed, turn, 1);
    flee_duration = ds_map_find_value(mp,"flee_duration");
    fleeing_timer = flee_duration;
    city_range[0] = ds_list_find_value(ds_map_find_value(mp,"city_range"),0);
    city_range[1] = ds_list_find_value(ds_map_find_value(mp,"city_range"),1);
    alert_range = ds_map_find_value(mp, "alert_range");
    active_city_range = irandom_range(city_range[0], city_range[1]);
    state = blimp_ai_states.POSITIONING;
    prev_state = blimp_ai_states.POSITIONING;
    is_left_dom_wpn = choose(true, false);
    
    return id;
}

#define scr_blimp_ai_position
///scr_blimp_ai_position()

if(!scr_instance_exists(global.city_id)){
    return undefined;
}

// :On switch to 'positioning' AI state
if(prev_state != blimp_ai_states.POSITIONING){
    active_city_range = irandom_range(city_range[0], city_range[1]);
}

//control blimp movement
scr_blimp_ai_navigate(global.city_id.x, global.city_id.y, false, 0.5, 0.5);
///check city is within range
var pd = point_distance(global.city_id.x, global.city_id.y, x, y);
if(pd<=active_city_range){
    state = blimp_ai_states.TARGETING_CITY;
}

#define scr_blimp_ai_flee
///scr_blimp_ai_flee()

if(!scr_instance_exists(target_id)){
    return undefined;
}

// player far away
if(fleeing_timer == 0){
    var pd = point_distance(target_id.x,target_id.y,x,y);
    if(pd >= alert_range*1.2){
        state = blimp_ai_states.POSITIONING;
    }
}
fleeing_timer = max(fleeing_timer-global.game_speed, 0);

scr_blimp_ai_navigate(target_id.x, target_id.y, true);

#define scr_blimp_ai_navigate
///scr_blimp_ai_navigate(x, y, away, turn_modifier=1, speed_modifier=1)

var tm = 1;
if(argument_count > 3){
    tm = argument[3];
}
var sm = 1;
if(argument_count > 4){
    sm = argument[4];
}
scr_ai_navigate(argument[0],argument[1],argument[2],tm,sm);

//DEBUGGING
if(alarm[global.AVOIDANCE_ALARM]>0){
    //swerving
    image_blend = c_olive;
}
else{
    //normal flying
    image_blend = c_white;
}

#define scr_blimp_ai_aim_city
///scr_blimp_ai_aim_city()

if(!scr_instance_exists(global.city_id) || !scr_instance_exists(gid[0])){
    return undefined;
}

///check city is within range
var pd = point_distance(global.city_id.x, global.city_id.y, x, y);
if(pd<=active_city_range){
    scr_wpn_fire(gid[0], "pressed");
}
else {
    //control blimp movement
    scr_c_engine_turn(global.city_id.x, global.city_id.y, true);
}

#define scr_blimp_ai_aim_player
///scr_blimp_ai_aim_player()

//fire side missles at player
if(scr_instance_exists(target_id)){
    var b, w, alt_w;
    //decide shoot left/right
    w = scr_blimp_get_dom_wpn(is_left_dom_wpn);
    alt_w = scr_blimp_get_dom_wpn(!is_left_dom_wpn);
    
    //dom wpn
    if(scr_instance_exists(gid[w])){
        b = scr_wpn_fire(gid[w], "pressed");
    }
    //alt wpn
    else if(scr_instance_exists(gid[alt_w])){
        b = scr_wpn_fire(gid[alt_w], "pressed");
    }
    
    //alternate left/right missle cannons
    if(b != undefined){
        is_left_dom_wpn = !is_left_dom_wpn;
    }
}

#define scr_blimp_update_wpns
///scr_blimp_update_wpns()

//Update weapon position and image angle. Call during the end step.
var r, t;

scr_blimp_calibrate_wpns();
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

#define scr_blimp_ai_retreat
///scr_blimp_ai_retreat()

//TODO: implement similar to flee but w/ out target_id

#define scr_blimp_calibrate_wpns
///scr_blimp_calibrate_wpns()

if (scr_blimp_is_targeting_player(state) &&
    !scr_blimp_is_targeting_player(prev_state)){
    var w, alt_w;
    
    w = scr_blimp_get_dom_wpn(is_left_dom_wpn);
    alt_w = scr_blimp_get_dom_wpn(!is_left_dom_wpn);
    
    //calibrate dom wpn
    if(scr_instance_exists(gid[w])){
        with(gid[alt_w]){
            shoot_counter = ceil(shoot_rate*0.2);
        }
    }
    //calibrate alt wpn
    if(scr_instance_exists(gid[alt_w])){
        with(gid[alt_w]){
            shoot_counter = 0;
        }
    }
}

#define scr_blimp_is_targeting_player
///scr_blimp_is_targeting_player(ai_state)
var aist = argument[0];
switch(aist){
    case blimp_ai_states.POSITIONING:
    case blimp_ai_states.TARGETING_CITY:
        return false;
        break;
    case blimp_ai_states.TARGETING_PLAYER:
    case blimp_ai_states.FLEEING:
        return true;
        break;
}
return false;

#define scr_blimp_get_dom_wpn
///scr_blimp_get_dom_wpn(is_left_wpn)
var is_left_dom = argument[0];

if(is_left_dom){
    return 1;
}
else{
    return 2;
}