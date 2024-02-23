///scr_c_palette_add(modifier=auto)

modifier = 0;
if(argument_count == 0){
    var cmp = ds_map_find_value(mp,"c_palette");
    modifier = ds_map_find_value(cmp,"color");
}
else{
    modifier = argument[0];
}

rt_modifier = modifier/255.0;
palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
row_ref = shader_get_uniform(shader_pal_swap, "row");

scr_c_add("c_palette");
