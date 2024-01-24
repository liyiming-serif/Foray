///scr_ai_navigate(x, y, away, turn_modifier, speed_modifier)

//STATELESS AVOIDANCE FUNCTION
//NEEDS: axy, foresight, avoid_arc

var tx = argument[0];
var ty = argument[1];
var away = argument[2];
var tm = argument[3];
var sm = argument[4];

var pd, dd, sx, sy, i, adir, adiff, pa, da;

/*clear detour route if avoidance state alarm not active
if(!alarm[global.AVOIDANCE_ALARM]){
    ax = 0;
    ay = 0;
}*/

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
    if(!alarm[global.AVOIDANCE_ALARM]){
        alarm[global.AVOIDANCE_ALARM] = avoid_arc;
    }
}
if(alarm[global.AVOIDANCE_ALARM]>0){
    //swerving
    if(away){
        scr_c_engine_turn_away(x+ax, y+ay, true, global.SWERVE_TURN_MOD*tm, sm);
    }
    else{
        scr_c_engine_turn(x+ax, y+ay, true, global.SWERVE_TURN_MOD*tm, sm);
    }
}
else{
    //normal flying
    if(away){
        scr_c_engine_turn_away(tx, ty, true, tm, sm);
    }
    else{
        scr_c_engine_turn(tx, ty, true, tm, sm);
    }
}
