///scr_c_plane_engine_roll()

//Returns whether a new roll was started
if(is_rolling || roll_cool!=0){
    return false;
}

//Start the roll
roll_invuln = roll_duration;
is_rolling = true;

//TODO: Configure direction of dash

sprite_index = spr_plane1_roll;
image_speed = roll_anim_speed;
image_index = 0;
u_bound_frame = roll_end_frame;
l_bound_frame = 0;

return true;
