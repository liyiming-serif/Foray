#define scr_aiplane_add_common
///scr_aiplane_add_common(ai_name)
//req: neutral_speed, base_turn

ai_name = argument[0];
var aimp = ds_map_find_value(global.pilot_ai, ai_name);
show_debug_message("ai_name: "+ai_name);

//Load AI constants from JSON 
range = ds_map_find_value(aimp,"range"); //distance before plane opens fire
og_accuracy = ds_map_find_value(aimp,"accuracy"); //angle diff before plane opens fire
accuracy = og_accuracy;

//Handicap AI
og_base_turn = base_turn;
base_turn *= global.AI_TURN_REDUC;
neutral_speed *= global.AI_SPEED_REDUC;
brake_speed *= global.AI_SPEED_REDUC;
boost_speed *= global.AI_SPEED_REDUC;
curr_speed = neutral_speed;
max_hp = ceil(max_hp*global.AI_HP_REDUC);
achy = ceil(ds_map_find_value(aimp,"achy")*max_hp); //hp threshold for stealing
hp = max_hp;

scr_ai_add_common(aimp);
scr_ai_set_avoidance(neutral_speed, base_turn);

return id;

#define scr_aiplane_navigate
///scr_aiplane_navigate(xtarget, ytarget, turn_modifier=1)

//CALCULATES TRAJECTORY FOR AVOIDING OBSTACLES, THEN TURNS THE PLANE
//NEEDS: AI states, axy, foresight, turn, turn func, avoid_arc, skill, is_friendly

if(show_debug){
    show_debug_message(model_name+".scr_aiplane_navigate()");
}

var xtarget = argument[0];
var ytarget = argument[1];
var ai_turn_mod = 1;
if(argument_count == 3){
    ai_turn_mod = argument[2];
}

var sx, sy, i, adir, adiff, pa, da;

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
        adiff = abs(angle_difference(i.direction,direction));
        if(i.speed>speed*0.5 && adiff<60.0){
            var l = distance_to_object(i);
            if(l>foresight*0.4){
                i = noone;
            }
        }
    }
}
if(state != plane_ai_states.AVOIDING){
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
        //adir = point_direction(i.x-x,i.y-y,sx,sy);
    }
    else{
        //velocity-based
        //FUTURE: skilled enemies should lean INTO oncoming player,
        //to give it the appearance of leading their shot
        /*if(skill>0 && i.is_friendly!=is_friendly){
            adir = direction-sign(adiff)*90;
        }else*/
        adir = direction+sign(adiff)*90;
    }
    ax = lengthdir_x(foresight,adir);
    ay = lengthdir_y(foresight,adir);
    state = plane_ai_states.AVOIDING;
    if(!alarm[avoid_alarm]){
        alarm[avoid_alarm] = avoid_arc;
        //rounds_left = clamp(rounds_left+1,0,max_rounds);
    }
}
if(state == plane_ai_states.AVOIDING){
    //swerving
    scr_c_plane_engine_steer(x+ax, y+ay, ai_turn_mod*global.SWERVE_TURN_MOD);
}
else{
    //normal flying
    scr_c_plane_engine_steer(xtarget, ytarget, ai_turn_mod);
}

#define scr_aiplane_shoot
///scr_aiplane_shoot()

if(show_debug){
    show_debug_message(model_name+".scr_aiplane_shoot()");
}

if(state==plane_ai_states.FIRING && scr_plane_shoot("pressed")!=undefined){
    //Decide to transition AI to 'reloading'
    rounds_left--;
    if(rounds_left<=0){
        rounds_left = max_rounds;
        state = plane_ai_states.RELOADING;
        if(!alarm[1]){
            alarm[1] = reload_speed;
        }
    }
}

#define scr_aiplane_aim
///scr_aiplane_aim()

if(show_debug){
    show_debug_message(model_name+".scr_aiplane_aim()");
}

///check player is within nimbus
var pd = point_distance(target_id.x,target_id.y,x,y);
if(pd<=range){
    //check player is within shooting range
    var pa = point_direction(x,y,target_id.x,target_id.y);
    var da = abs(angle_difference(pa,direction));
    if(da <= accuracy){
        state = plane_ai_states.FIRING;
        return true;
    }
}
return false;