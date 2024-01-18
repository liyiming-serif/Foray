#define scr_balloon_ai_add
///scr_balloon_ai_add(aimp)
//req: neutral_speed, turn, gun_turn
var aimp = argument[0];
alert_range = ds_map_find_value(aimp, "alert_range");
accuracy_coeff = ds_map_find_value(aimp, "accuracy_coeff");
aggro_chance = ds_map_find_value(aimp, "aggro_chance");
aggro_interval = room_speed/ds_map_find_value(aimp, "aggro_checks_per_sec");
player_noticed = false;
is_aggro = false;
alarm[aggro_alarm] = aggro_interval;
scr_ai_set_avoidance(neutral_speed, turn);
//set accuracy for firing wpn
if(scr_instance_exists(gid)){
    gun_turn -= gun_turn*(1-7/gid.recoil);
    og_accuracy = accuracy_coeff*gid.accuracy;
    accuracy = og_accuracy;
}

#define scr_balloon_ai_navigate
///scr_balloon_navigate(x, y, turn_modifier=1, speed_modifier=1)

//STATELESS AVOIDANCE FUNCTION
//NEEDS: axy, foresight, turn func, avoid_arc
//(target_id, alert_range can be refactored out)
//TODO: make both avoid functions generic if more ship ai reuses logic

var tx = argument[0];
var ty = argument[1];
var tm = 1;
if(argument_count > 2){
    tm = argument[2];
}
var sm = 1;
if(argument_count > 3){
    sm = argument[3];
}
var pd, dd, sx, sy, i, adir, adiff, pa, da;

//check if should chase player because they're nearby
if(scr_instance_exists(target_id) &&
    distance_to_point(target_id.x,target_id.y)<alert_range*0.6){
    
    pd = point_direction(x,y,target_id.x,target_id.y);
    dd = abs(angle_difference(direction,pd));
    if(dd < 60){
        player_noticed = true;
    }
}

//hiding behind armor; don't move
if(scr_instance_exists(aid) && aid.visible){
    speed = 0;
    return undefined;
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
            if(l>foresight*0.4){
                i = noone;
            }
        }
    }
}
if(!alarm[global.AVOIDANCE_ALARM]){
    ax = 0;
    ay = 0;
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
    if(!alarm[global.AVOIDANCE_ALARM]){
        alarm[global.AVOIDANCE_ALARM] = avoid_arc;
    }
}
if(alarm[global.AVOIDANCE_ALARM]){
    //swerving
    scr_ship_turn(x+ax, y+ay, false, global.SWERVE_TURN_MOD*tm, sm);
}
else{
    //normal flying
    scr_ship_turn(tx, ty, false, tm, sm);
}


#define scr_balloon_ai_aim
///scr_balloon_ai_aim()

//aim if in range
if(scr_instance_exists(target_id) && distance_to_object(target_id)<gid.range[0]*0.6){
    //turn the gun
    var pa = point_direction(x, y, target_id.x, target_id.y);
    var da = angle_difference(pa,gid.image_angle);
    var ta = min(abs(da),gun_turn);
    gid.image_angle += global.game_speed*ta*sign(da);
    gid.image_angle = 
        angle_difference(gid.image_angle, 0); //constrain angle values
    
    //shoot if within angle
    if(abs(da) <= accuracy){
        scr_ship_shoot(gid,"pressed");
    }
}

#define scr_balloon_ai_guard
///scr_balloon_ai_guard()

//TODO: change logic to put up shield friendly bullet is within range

if(aid.state == shield_states.DOWN && scr_balloon_ai_in_danger()){
    //raise armor if target is firing in range
    aid.state = shield_states.GOING_UP;
}
else if(aid.state == shield_states.UP && !scr_balloon_ai_in_danger()){
    //drop armor if target is no longer firing in range
    aid.state = shield_states.GOING_DOWN;
}


#define scr_balloon_hit
///scr_balloon_hit()

if(is_friendly!=other.is_friendly){
    player_noticed = true;
    if(scr_instance_exists(aid) && scr_balloon_amr_is_up()){
        instance_destroy(other);
        part_particles_create(global.partsys,other.x,other.y,global.deflect,1);
        //deflected
        scr_play_sound_metallic(snd_deflect,x,y);
    }
    else{
        scr_ship_hit();
    }
}

#define scr_balloon_ai_in_danger
///scr_balloon_ai_in_danger()

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

//aid must be initialized
return aid.state == shield_states.UP || aid.state == shield_states.GOING_DOWN;

#define scr_balloon_advance_frame
///scr_balloon_advance_frame()

drop_bomb_reload_counter = min(drop_bomb_reload_counter+global.game_speed,
    drop_bomb_reload_speed);

scr_ship_advance_frame();