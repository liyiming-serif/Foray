///scr_c_amr_add()

var cmp = ds_map_find_value(mp, "c_amr");

//create armor
var a = instance_create(x,y,obj_balloon_amr);
//set armor data
a.state = shield_states.DOWN;
a.anim_time = ds_map_find_value(cmp, "amr_anim_time");
a.up_lag = ds_map_find_value(cmp, "amr_up_lag");
a.down_lag = ds_map_find_value(cmp, "amr_down_lag");
//hack: armor needs at least balloon's anim length
//future: if it needs to know more, pass balloon ref to armor
a.balloon_frames = image_number;

scr_c_add("c_amr");
return a;
