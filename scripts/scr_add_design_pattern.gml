#define scr_add_design_pattern
///scr_add_design_pattern(callback_name)

var cb_name, k, v;
cb_name = argument[0];
k = asset_get_index(cb_name);
v = ds_map_find_value(global.design_pattern_weights,cb_name);

if(!ds_map_exists(global.seen_enemies,k) && v!=undefined){
    ds_map_add(global.seen_enemies,k,v);
}

#define scr_remove_design_pattern
///scr_remove_design_pattern(callback_name)

var cb_name, k, v;
cb_name = argument[0];
k = asset_get_index(cb_name);

if(ds_map_exists(global.seen_enemies,k)){
    ds_map_delete(global.seen_enemies,k);
}

#define scr_add_seen_wpn
///scr_add_seen_wpn(wpn_ind)

var wpn_ind = argument[0];

if(!ds_map_exists(global.seen_wpns,object_get_name(wpn_ind))){
    ds_map_add(global.seen_wpns,object_get_name(wpn_ind),1);
}

#define scr_remove_seen_wpn
///scr_remove_seen_wpn(wpn_ind)

var wpn_ind = argument[0];
var wpn_name = object_get_name(wpn_ind);

if(ds_map_exists(global.seen_wpns,wpn_name)){
    ds_map_delete(global.seen_wpns,wpn_name);
}
