///scr_c_engine_add(mp)

//decode json properties
//ADDS: neutral_speed, turn, curr_speed

var mp = argument[0];
var cmp = ds_map_find_value(mp, "c_hull");

if(is_undefined(cmp)){
    return undefined;
}

neutral_speed = ds_map_find_value(cmp, "speed");
turn = ds_map_find_value(cmp, "turn");
curr_speed = neutral_speed;
