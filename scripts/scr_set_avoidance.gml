///scr_set_avoidance(speed, turn, avoid_state_alarm, sight_modifier=0.4)

//set foresight and avoid_arc based on speed and turn stats of the ship
//ADDS: foresight, avoid_arc, axy
var sp = argument[0];
var tn = argument[1]*global.SWERVE_TURN_MOD;

avoid_state_alarm = argument[2];
var smod = 0.4;
if(argument_count == 4){
    smod = argument[3];
}

ax = 0;
ay = 0;
//time it takes to turn a certain angle
avoid_arc = ceil(67.5/tn);
//distance covered by one avoid arc
foresight = smod*avoid_arc*sp;
