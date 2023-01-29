///scr_set_avoidance(speed, turn, avoid_state_alarm)

//set foresight and avoid_arc based on speed and turn stats of the ship
//ADDS: foresight, avoid_arc, axy
var sp = argument[0];
var tn = argument[1]*global.SWERVE_TURN_MOD;

avoid_state_alarm = argument[2];

ax = 0;
ay = 0;
//time it takes to turn a certain angle
avoid_arc = ceil(67.5/tn);
//distance covered by one avoid arc
foresight = 0.4*avoid_arc*sp;
