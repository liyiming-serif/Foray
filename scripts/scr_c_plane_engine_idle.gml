///scr_c_plane_engine_idle()
//TODO: refactor this. copy-pasted from point_turn
var ideal_turn, da;
da = angle_difference(direction,image_angle);
ideal_turn = min(abs(da),base_turn)*sign(da);
turn = clamp(ideal_turn,
    turn-turn_accel*global.game_speed,
    turn+turn_accel*global.game_speed);
image_angle += global.game_speed*turn_d;
speed = global.game_speed*curr_speed;
audio_stop_sound(engine_sound);
