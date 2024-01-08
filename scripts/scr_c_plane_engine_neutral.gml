///scr_c_plane_engine_neutral()
if(!is_rolling){
    is_braking = false;
    is_boosting = false;
    if(curr_speed<neutral_speed){//too slow
        curr_speed = clamp(curr_speed+global.ACC_SPEED,brake_speed,neutral_speed);
    }
    else if(curr_speed>neutral_speed){//too fast
        curr_speed = clamp(curr_speed-global.AIR_FRIC,neutral_speed,boost_speed);
    }
}
