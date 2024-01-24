#define scr_c_engine_turn
///scr_c_engine_turn(x, y, should_face_dir, turn_modifier=1, speed_modifier=1)

//Generic script for turning ships towards a point,
//and whether to change image_angle to match dir
//Req: curr_speed, turn

var tx = argument[0];
var ty = argument[1];
var should_face_dir = argument[2];
var tm = turn;
var sm = curr_speed;

//Apply a flat turn multiplier so ships spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count > 3){
    tm *= argument[3];
}
//Optional: apply a modifier w/out affecting 'speed' property.
if(argument_count > 4){
    sm *= argument[4];
}

var pa = point_direction(x,y,tx,ty);
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);

direction += global.game_speed*ta*sign(da);
direction = angle_difference(direction,0); //constrain angle values
speed = global.game_speed*sm;
if(should_face_dir){
    image_angle = direction;
}

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));

#define scr_c_engine_turn_away
///scr_c_engine_turn_away(x, y, should_face_dir, turn_modifier=1, speed_modifier=1)

//TODO: COMBINE W C_ENGINE_TURN
//Generic script for turning ships away from a point,
//and whether to change image_angle to match dir
//Req: curr_speed, turn

var tx = argument[0];
var ty = argument[1];
var should_face_dir = argument[2];
var tm = turn;
var sm = curr_speed;

//Apply a flat turn multiplier so ships spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count > 3){
    tm *= argument[3];
}
//Optional: apply a modifier w/out affecting 'speed' property.
if(argument_count > 4){
    sm *= argument[4];
}

var pa = point_direction(tx,ty,x,y);
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);

direction += global.game_speed*ta*sign(da);
direction = angle_difference(direction,0); //constrain angle values
speed = global.game_speed*sm;
if(should_face_dir){
    image_angle = direction;
}

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));