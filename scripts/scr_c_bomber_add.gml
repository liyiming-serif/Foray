///scr_c_bomber_add(cmp)

var cmp = argument[0];

drop_bomb_reload_speed = ds_map_find_value(mp, "drop_bomb_reload_speed");
drop_bomb_reload_counter = 0;
