///scr_plane_roll()

//Returns whether a new roll was started
if(is_rolling || roll_cooldown!=0){
    return false;
}

//Start the roll
roll_invuln = rolltime;
is_rolling = true;

sprite_index = spr_plane1_roll;
image_speed = roll_anim_speed;
image_index = 0;
u_bound_frame = roll_end_frame;
l_bound_frame = 0;

return true;
