///scr_c_hull_add(mp)

//decode json properties
//ADDS: max_hp, hp, hp_bar_width, hit_stun, invincibility

var mp = argument[0];
var cmp = ds_map_find_value(mp, "c_hull");

if(is_undefined(cmp)){
    return undefined;
}

//hp
max_hp = ds_map_find_value(mp, "max_hp");
hp = max_hp;
hp_bar_width = ds_map_find_value(mp,"hp_bar_width");
if(hp_bar_width==undefined){
    hp_bar_width = sprite_width;
}

//collision
hitstun = 0;
invincibility = 0;
