///scr_c_bullet_add(component_map=auto)

//decode json properties
//req: mp

var cmp;
if(argument_count == 0){
    cmp = ds_map_find_value(mp,"c_bullet");
}
else{
    cmp = argument[0];
}

//optional parameters
var v;
v = ds_map_find_value(cmp,"hit_part");
if(v!=undefined){
    hit_part = variable_global_get(v);
}

v = ds_map_find_value(cmp,"miss_part");
if(v!=undefined){
    miss_part = variable_global_get(v);
}

scr_c_add("c_bullet");
