///scr_c_bullet_add(cmp)

var cmp = argument[0];

//optional parameters
var v;
v = ds_map_find_value(mp,"hit_part");
if(v!=undefined){
    hit_part = variable_global_get(h);
}

v = ds_map_find_value(mp,"miss_part");
if(v!=undefined){
    miss_part = variable_global_get(v);
}
