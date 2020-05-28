#define scr_balloon_create
///scr_balloon_create(x,y,wpn_name,is_armored)
var xv = argument[0];
var yv = argument[1];
var wpn_name = argument[2];

with(instance_create(xv,yv,obj_balloon)){
    //initiallize stats
    var mp = ds_map_find_value(global.balloons, "balloon");
    
    scr_ship_instantiate(false,mp);
    
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    gun_turn = ds_map_find_value(mp, "gun_turn");
    alert_range = ds_map_find_value(mp, "alert_range");
    drop_bomb_reload_speed = ds_map_find_value(mp, "drop_bomb_reload_speed");
    drop_bomb_reload_counter = 0;
    is_armored = argument[3];
    
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
    
    //ai and target selection
    aggro_chance = ds_map_find_value(mp, "aggro_chance");
    aggro_interval = room_speed/ds_map_find_value(mp, "aggro_checks_per_sec");
    player_noticed = false;
    is_aggro = false;
    alarm[1] = aggro_interval;
    scr_set_avoidance(curr_speed, turn);
    
    image_speed = 0.4;

    /*
    engine_sound = audio_play_sound_on(engine_sound_emitter,snd_balloon_propeller,true,0);
    audio_sound_pitch(engine_sound,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));
    audio_emitter_gain(engine_sound_emitter, global.SOUND_BALLOON_GAIN_SHIFT);
    audio_emitter_pitch(engine_sound_emitter, global.SOUND_BALLOON_PITCH_SHIFT);
    */
    return id;
}



#define scr_balloon_navigate
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
if(scr_instance_exists(target_id) && distance_to_object(target_id)<alert_range*0.6){
    pd = point_direction(x,y,target_id.x,target_id.y);
    dd = abs(angle_difference(direction,pd));
    if(dd < 60){
        player_noticed = true;
    }
}

//hiding behind armor; don't move
if(scr_instance_exists(gid[1]) && gid[1].visible){
    speed = 0;
    return undefined;
}

//sensing obstacles
sx = lengthdir_x(speed*foresight,direction);
sy = lengthdir_y(speed*foresight,direction);
i = collision_line(x,y,sx+x,sy+y,obj_ship_parent,false,true);
//don't dodge if obstacle is 1)moving away 2)too fast 3)not imminently close
if(i!=noone){
    if(i.speed>speed*0.5 && abs(angle_difference(i.direction,direction))<30.0){
        var l = distance_to_object(i);
        if(l>foresight*0.4){
            i = noone;
        }
    }
}
if(!alarm[global.AVOID_STATE_ALARM]){
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
    if(!alarm[global.AVOID_STATE_ALARM]){
        alarm[global.AVOID_STATE_ALARM] = avoid_arc;
    }
}
if(alarm[global.AVOID_STATE_ALARM]){
    //swerving
    scr_ship_turn(x+ax, y+ay, false, global.SWERVE_TURN_MOD*tm, sm);
}
else{
    //normal flying
    scr_ship_turn(tx, ty, false, tm, sm);
}


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

if(is_friendly!=other.is_friendly){
    player_noticed = true;
    if(scr_instance_exists(gid[1]) && scr_balloon_amr_is_up()){
        instance_destroy(other);
        part_particles_create(global.partsys,other.x,other.y,global.deflect,1);
        //deflected
        scr_play_sound_metallic(snd_deflect,x,y);
    }
    else{
        scr_ship_hit();
    }
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
#define scr_balloon_advance_frame
///scr_balloon_advance_frame()

drop_bomb_reload_counter = min(drop_bomb_reload_counter+global.game_speed,
    drop_bomb_reload_speed);

scr_ship_advance_frame();