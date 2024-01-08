///scr_c_plane_engine_boost()
if(!is_rolling){
    is_braking = false;
    is_boosting = true;
    curr_speed = clamp(curr_speed+global.ACC_SPEED,brake_speed,boost_speed);
}
