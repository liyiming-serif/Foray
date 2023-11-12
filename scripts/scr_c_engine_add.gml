///scr_c_engine_add(mp, sight_modifier=0.4)


//set variables needed for avoidance code
//ADDS: foresight, avoid_arc, ax, ay
var sp = argument[0];
var tn = argument[1]*global.SWERVE_TURN_MOD;

var smod = 0.4;
if(argument_count == 2){
    smod = argument[1];
}

ax = 0;
ay = 0;
//time it takes to turn a certain angle
avoid_arc = ceil(67.5/tn);
//distance covered by one avoid arc
foresight = smod*avoid_arc*sp;
