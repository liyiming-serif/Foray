///scr_c_hull_add(mp)

var mp = argument[0];
if(is_undefined(mp)){
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
