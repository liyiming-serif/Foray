///scr_c_plane_engine_brake()
if(!is_rolling){
    is_braking = true;
    is_boosting = false;
    curr_speed = clamp(curr_speed-global.ACC_SPEED,brake_speed,boost_speed);
}
