///scr_c_amr_add(cmp)

var cmp = argument[0];

//create armor
aid = 0;
if(is_armored){
    aid = instance_create(x,y,obj_balloon_amr);
    
    //load Json data
    aid.state = shield_states.DOWN;
    aid.anim_time = ds_map_find_value(cmp, "amr_anim_time");
    aid.up_lag = ds_map_find_value(cmp, "amr_up_lag");
    aid.down_lag = ds_map_find_value(cmp, "amr_down_lag");
    //hack: armor needs at least balloon's anim length
    //future: if it needs to know more, pass balloon ref to armor
    aid.balloon_frames = image_number;
}
