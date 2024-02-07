#define scr_c_engine_turn
///scr_c_engine_turn(x, y, turn_modifier=1, speed_modifier=1, turn_away=false)

//Generic script for turning ships towards a point
//Req: curr_speed, turn

var tx = argument[0];
var ty = argument[1];
var tm = turn;
var sm = curr_speed;

//Apply a flat turn multiplier so ships spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count > 2){
    tm *= argument[2];
}
//Optional: apply a modifier w/out affecting 'speed' property.
if(argument_count > 3){
    sm *= argument[3];
}

var turn_away = false;
//Optional: turn away
if(argument_count > 4){
    turn_away = argument[4];
}

var pa;
if(turn_away){
    pa = point_direction(tx,ty,x,y);
}
else{
    pa = point_direction(x,y,tx,ty);
}
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);

direction += global.game_speed*ta*sign(da);
direction = angle_difference(direction,0); //constrain angle values
speed = global.game_speed*sm;
if(face_dir){
    image_angle = direction;
}

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));

#define scr_c_engine_turn_away
///scr_c_engine_turn_away(x, y, turn_modifier=1, speed_modifier=1)

//Overlay script for turning ships away from a point
//Req: curr_speed, turn

//Prepare args
var tx = argument[0];
var ty = argument[1];
//Optional: apply a modifier w/out affecting 'turn' property.
var tm = 1;
if(argument_count > 2){
    tm *= argument[2];
}
//Optional: apply a modifier w/out affecting 'speed' property.
var sm = 1;
if(argument_count > 3){
    sm *= argument[3];
}

scr_c_engine_turn(tx,ty,tm,sm,true);