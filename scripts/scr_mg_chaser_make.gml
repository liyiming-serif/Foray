///scr_mg_chaser_make(ai_map, skill)

var mp = ds_map_find_value(global.pilot_ai,argument[0]);
var opt = ds_map_find_value(mp,"optional");

fuel = ds_list_find_value(ds_map_find_value(opt,"fuel"),skill);
refuel_speed = ds_list_find_value(ds_map_find_value(opt,"refuel_speed"),skill);
