#define scr_blimp_create
///scr_blimp_create(x,y,direction)
var xv = argument[0];
var yv = argument[1];
var dir = argument[2];

with(instance_create(xv,yv,obj_blimp)){
    //initiallize stats
    var mp = ds_map_find_value(global.airships, "blimp");
    scr_ship_instantiate(false,mp);
    
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    
    //set initial course
    direction = dir;
    image_angle = direction;
    
    //mount wpns
    gid[0] = scr_wpn_create(x,y,0,"city_missile_gun",false);
    gid[1] = scr_wpn_create(x,y,0,"player_missile_gun",false); //left
    gid[2] = scr_wpn_create(x,y,0,"player_missile_gun",false); //right
    
    //ai params
    //increase sight modifier for oblong shape
    scr_set_avoidance(curr_speed, turn, 0, 1);
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

#define scr_blimp_position
///scr_blimp_position()

if(!scr_instance_exists(global.city_id)){
    return undefined;
}

// :On switch to 'positioning' AI state
if(prev_state != blimp_ai_states.POSITIONING){
    active_city_range = irandom_range(city_range[0], city_range[1]);
}

//control blimp movement
scr_blimp_navigate(global.city_id.x, global.city_id.y, false, 0.5, 0.5);
///check city is within range
var pd = point_distance(global.city_id.x, global.city_id.y, x, y);
if(pd<=active_city_range){
    state = blimp_ai_states.TARGETING_CITY;
}

#define scr_blimp_flee
///scr_blimp_flee()

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

scr_blimp_navigate(target_id.x, target_id.y, true);

#define scr_blimp_navigate
///scr_blimp_navigate(x, y, away, turn_modifier=1, speed_modifier=1))

//STATELESS AVOIDANCE FUNCTION
//NEEDS: axy, foresight, avoid_arc
//TODO: make both avoid functions generic if more ship ai reuses logic

var tx = argument[0];
var ty = argument[1];
var away = argument[2];
var tm = 1;
if(argument_count > 3){
    tm = argument[3];
}
var sm = 1;
if(argument_count > 4){
    sm = argument[4];
}

var pd, dd, sx, sy, i, adir, adiff, pa, da;

//clear detour route if avoidance state alarm not active
if(!alarm[avoid_state_alarm]){
    ax = 0;
    ay = 0;
}

//sensing obstacles
sx = lengthdir_x(speed*foresight,direction);
sy = lengthdir_y(speed*foresight,direction);
i = collision_line(x,y,sx+x,sy+y,obj_obstacle_parent,false,true);
//don't dodge if obstacle is 1)moving away 2)too fast 3)not imminently close 4)rolling 
if(i!=noone){
    if(variable_instance_exists(i, "roll_invuln") && i.roll_invuln>0){
        i = noone;
    }
    else {
        if(i.speed>speed*0.5 && abs(angle_difference(i.direction,direction))<30.0){
            var l = distance_to_object(i);
            if(l>foresight){
                i = noone;
            }
        }
    }
}

//avoiding obstacles
if(i!=noone){
    //calculate avoidance trajectory
    adiff = angle_difference(direction,i.direction);
    if(i.speed<speed*0.5 || adiff==0 || adiff==180 || adiff==-180){
        //position-based
        pa = point_direction(x,y,i.x,i.y);
        da = angle_difference(pa,direction);
        adir = direction-sign(da)*90;
    }
    else{
        //velocity-based
        adir = direction+sign(adiff)*90;
    }
    ax = lengthdir_x(foresight,adir);
    ay = lengthdir_y(foresight,adir);
    if(!alarm[avoid_state_alarm]){
        alarm[avoid_state_alarm] = avoid_arc;
    }
}
if(alarm[avoid_state_alarm]>0){
    //swerving
    if(away){
        scr_ship_turn_away(x+ax, y+ay, true, global.SWERVE_TURN_MOD*tm, sm);
    }
    else{
        scr_ship_turn(x+ax, y+ay, true, global.SWERVE_TURN_MOD*tm, sm);
    }
    image_blend = c_olive;
}
else{
    //normal flying
    if(away){
        scr_ship_turn_away(tx, ty, true, tm, sm);
    }
    else{
        scr_ship_turn(tx, ty, true, tm, sm);
    }
    image_blend = c_white;
}

#define scr_blimp_aim_city
///scr_blimp_aim_city()

if(!scr_instance_exists(global.city_id) || !scr_instance_exists(gid[0])){
    return undefined;
}

///check city is within range
var pd = point_distance(global.city_id.x, global.city_id.y, x, y);
if(pd<=active_city_range){
    scr_ship_shoot(gid[0], "pressed");
}
else {
    //control blimp movement
    scr_ship_turn(global.city_id.x, global.city_id.y, true);
}

#define scr_blimp_aim_player
///scr_blimp_aim_player()

//fire side missles at player
if(scr_instance_exists(target_id)){
    var b, w, alt_w;
    //decide shoot left/right
    w = scr_blimp_get_dom_wpn(is_left_dom_wpn);
    alt_w = scr_blimp_get_dom_wpn(!is_left_dom_wpn);
    
    //dom wpn
    if(scr_instance_exists(gid[w])){
        b = scr_ship_shoot(gid[w], "pressed");
    }
    //alt wpn
    else if(scr_instance_exists(gid[alt_w])){
        b = scr_ship_shoot(gid[alt_w], "pressed");
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

#define scr_blimp_idle
///scr_blimp_idle()
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