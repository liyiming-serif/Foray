///scr_c_ignition_add(component_map=auto)

var cmp;
if(argument_count == 0){
    cmp = ds_map_find_value(mp,"c_ignition");
}
else{
    cmp = argument[0];
}

projectile_ind = asset_get_index(ds_map_find_value(cmp,"projectile_ind"));
dmg = ds_map_find_value(cmp, "dmg");
recoil = ds_map_find_value(cmp, "recoil");
accuracy = ds_map_find_value(cmp, "accuracy");

projectile_id = noone;
is_wpn_on = false;
scr_c_add("c_ignition");
