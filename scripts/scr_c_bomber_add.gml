///scr_c_bomber_add()
//req: mp
var cmp = ds_map_find_value(mp, "c_bomber");

drop_bomb_reload_speed = ds_map_find_value(cmp, "drop_bomb_reload_speed");
drop_bomb_reload_counter = 0;
