///scr_c_hull_add(cmp)

//decode json properties
//ADDS: max_hp, hp, hp_bar_width, hit_stun, invuln

var cmp = argument[0];

//hp
max_hp = ds_map_find_value(cmp, "max_hp");
hp = max_hp;
hp_bar_width = ds_map_find_value(cmp,"hp_bar_width");
if(hp_bar_width==undefined){
    hp_bar_width = sprite_width;
}

//collision
hitstun = 0;
invuln = 0;
sp_invuln = 0;
crash_invuln = 0;
