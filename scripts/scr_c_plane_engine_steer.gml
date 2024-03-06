///scr_c_plane_engine_steer(xtarget, ytarget, turn_modifier=1)

//Steer (calculate turn) of the plane towards a target.

//Find target image angle + direction
var pa, da, da_d;
pa = point_direction(x,y,argument[0],argument[1]);
da = angle_difference(pa,image_angle);
da_d = angle_difference(pa,direction);

//Calculate turn acc modifiers
var tam;
if(roll_invuln > 0){
    tam = 1;
}
else{
    //normal flying, dampen turn acc based on speed
    tam = 1-global.TURN_ACC_DAMPENER*((curr_speed-brake_speed)/(boost_speed-brake_speed));
}


//Calculate turn modifiers
var tm, tm_d;
tm = 1;
tm_d = 1;
//rolling turn boost
if(roll_invuln > 0){
    tm *= global.ROLL_TURN;
    tm_d *= global.ROLL_TURN;
}
else{
    //normal flying, dampen turn limit based on speed
    tm *= 1-global.TURN_DAMPENER*((curr_speed-brake_speed)/(boost_speed-brake_speed));
    tm_d *= 1-global.TURN_DAMPENER*((curr_speed-brake_speed)/(boost_speed-brake_speed));
}
//Apply a flat multiplier so planes spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
    tm_d *= global.TURN_OUTSIDE_ROOM_COEFF;
}
//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count==3){
    tm *= argument[2];
    tm_d *= argument[2];
}
//hairpin turns at low speeds + stabilization
var insta_turn = false;
if(turn<global.TURN_STABLE_THRESH*base_turn){
    insta_turn = true;
}
//Can drift - only affects image angle
if(is_braking){
    tm *= global.DRIFT;
    if(curr_speed > brake_speed){
        insta_turn = true;
    }
}

//Boost after drifting to fly straight
if(is_boosting){
    tm_d *= global.STABILITY;
}

//Apply turn modifiers
var ideal_turn, max_turn;
max_turn = tm*base_turn;
ideal_turn = clamp(da,-max_turn,max_turn);
if(insta_turn){
    turn = ideal_turn;
}
else{
    turn = clamp(ideal_turn,
        turn-turn_accel*tam*global.game_speed,
        turn+turn_accel*tam*global.game_speed);
}

//Set image angle
if(roll_invuln > 0){
    //rolling, lock image angle
}
else {
    image_angle += global.game_speed*turn;
}
image_angle = angle_difference(image_angle, 0); //constrain angle values

//Set direction
var ideal_turn_d, max_turn_d;
max_turn_d = tm_d*base_turn;
ideal_turn_d = clamp(da_d,-max_turn_d,max_turn_d);
if(insta_turn){
    turn_d = ideal_turn_d;
}
else{
    turn_d = clamp(ideal_turn_d,
        turn_d-turn_accel*tam*global.game_speed,
        turn_d+turn_accel*tam*global.game_speed);
}
direction += global.game_speed*turn_d;
direction = angle_difference(direction,0); //constrain angle values


//Set speed
speed = global.game_speed*curr_speed*(1-abs(turn_d)/(base_turn*global.SPEED_DAMPENER));
    
//Change sprite based on turn img angle
if(abs(turn) >= base_turn*SHARP_TURN){
    if(turn>0){
        turn_state = plane_turn_states.LEFT_DRIFT;
    }
    else{
        turn_state = plane_turn_states.RIGHT_DRIFT;
    }
}
else if(abs(turn) >= base_turn*SLIGHT_TURN){
    if(turn>0){
        turn_state = plane_turn_states.LEFT_TURN;
    }
    else{
        turn_state = plane_turn_states.RIGHT_TURN;
    }
}
else{
    turn_state = plane_turn_states.NEUTRAL;
}

//update sound emitter for doppler effect
if(is_friendly){
    var pitch = 1-((boost_speed-curr_speed)/boost_speed)*global.SOUND_PITCH_DAMPENER;
    audio_emitter_pitch(engine_sound_emitter, pitch);
}
var gain = (1-(boost_speed-curr_speed)/boost_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, gain);

