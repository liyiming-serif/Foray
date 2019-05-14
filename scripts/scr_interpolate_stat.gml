///scr_interpolate_stat(index, ds_list)

//Get the value of ds_list[index]. If index is a float, interpolate
//between ds_list values. INDEX IS 1 INDEXED!
var ind, ind_floor, ind_ceil, list;

ind = argument[0]-1;
list = argument[1];
ind_floor = floor(ind);
ind_ceil = ceil(ind);
if(ind_floor == ind_ceil){
    return ds_list_find_value(list,ind_floor);
}
else{
    var val_floor, val_ceil;
    val_floor = ds_list_find_value(list,ind_floor);
    val_ceil = ds_list_find_value(list,ind_ceil);
    return lerp(val_floor,val_ceil,frac(ind));
}

