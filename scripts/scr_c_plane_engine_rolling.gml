///scr_c_plane_engine_rolling()

//speed adjuster func similar to boost, brake, & neutral
is_braking = false;
is_boosting = false;

//lerp the roll dash speed
if(roll_invuln > 0){
    curr_speed = roll_speed;
}
else {
    var t_remaining = 1-((image_index-roll_end_frame)/(image_number-1-roll_end_frame));
    curr_speed = lerp(boost_speed, roll_speed, t_remaining);
}
