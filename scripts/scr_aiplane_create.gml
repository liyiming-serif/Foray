#define scr_aiplane_create
 ///scr_aiplane_create(x, y, dir, model_name, skill)
var xv = argument[0];
var yv = argument[1];
var dir = argument[2];
var model_name = argument[3];
var m_map = ds_map_find_value(global.models, model_name);
var ai_name = ds_map_find_value(m_map, "default_pilot_ai");

var mp = ds_map_find_value(global.pilot_ai,ai_name);
var obj = asset_get_index(ds_map_find_value(mp,"obj_ind"));

//CONSTRUCTOR:
with(instance_create(xv,yv,obj)){
    //Load AI constants from JSON 
    skill = argument[4]-1;
    range = ds_list_find_value(ds_map_find_value(mp,"range"),skill); //distance before plane opens fire
    og_accuracy = ds_list_find_value(ds_map_find_value(mp,"accuracy"),skill); //angle diff before plane opens fire
    accuracy = og_accuracy;
    var utt = ds_map_find_value(mp,"update_target_time"); //update_target_time
    scr_plane_instantiate(dir,model_name,false,ds_list_find_value(utt,skill));
    
    //Handicap AI
    og_base_turn = base_turn;
    base_turn *= global.AI_TURN_REDUC;
    neutral_speed *= global.AI_SPEED_REDUC;
    min_speed *= global.AI_SPEED_REDUC;
    max_speed *= global.AI_SPEED_REDUC;
    curr_speed = neutral_speed;
    max_hp = ceil(max_hp*global.AI_HP_REDUC);
    achy = ceil(ds_list_find_value(ds_map_find_value(mp,"achy"),skill)*max_hp); //hp threshold for stealing
    hp = max_hp;
    
    //entry point for AI FSM
    var create_script = asset_get_index(ds_map_find_value(mp,"create_script"));
    script_execute(create_script, mp);
    scr_set_avoidance(neutral_speed, base_turn, 0);
    
    return id;
}

#define scr_aiplane_navigate
///scr_aiplane_navigate(xtarget, ytarget, turn_modifier=1)

//CALCULATES TRAJECTORY FOR AVOIDING OBSTACLES, THEN TURNS THE PLANE
//NEEDS: AI states, axy, foresight, turn, turn func, avoid_arc, skill, is_friendly

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
        //NOTE: skilled enemies will lean INTO oncoming player,
        //to give it the appearance of leading their shot
        if(skill>0 && i.is_friendly!=is_friendly){
            adir = direction-sign(adiff)*90;
        }
        else{
            adir = direction+sign(adiff)*90;
        }
    }
    ax = lengthdir_x(foresight,adir);
    ay = lengthdir_y(foresight,adir);
    state = plane_ai_states.AVOIDING;
    if(!alarm[global.AVOIDANCE_ALARM]){
        alarm[global.AVOIDANCE_ALARM] = avoid_arc;
        //rounds_left = clamp(rounds_left+1,0,max_rounds);
    }
}
if(state == plane_ai_states.AVOIDING){
    //swerving
    scr_plane_steer(x+ax, y+ay, ai_turn_mod*global.SWERVE_TURN_MOD);
}
else{
    //normal flying
    scr_plane_steer(xtarget, ytarget, ai_turn_mod);
}

#define scr_aiplane_shoot
///scr_aiplane_shoot()

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

#define scr_aiplane_hit
///scr_aiplane_hit()

var php = hp;
scr_plane_hit();
if(hp<=achy && php>achy){     
    var pa = point_direction(x,y,global.player_id.x,global.player_id.y);
    scr_plane_gen_weakspot(degtorad(angle_difference(pa,image_angle)));
    //make it easier to aim
    //base_turn *= global.AI_TURN_REDUC;
}
