///scr_ai_mg_chaser_make(ai_map)

var mp = argument[0];
var opt = ds_map_find_value(mp,"optional");

max_rounds = ds_list_find_value(ds_map_find_value(opt,"max_rounds"),skill);
reload_speed = ds_list_find_value(ds_map_find_value(opt,"reload_speed"),skill);

//entry point for AI FSM
state = plane_ai_states.CHASING;
rounds_left = max_rounds;
