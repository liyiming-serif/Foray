///scr_wpn_set_sprite(flash=false)

var f_on;
if(argument_count > 0){
    f_on = argument[0];
}
else{
    f_on = false;
}

if(f_on){
    var spr_name = sprite_get_name(object_get_sprite(object_index));
    spr_name += "_flash";
    if(asset_get_index(spr_name) != -1){
        sprite_index = asset_get_index(spr_name);
    }
    else{
        sprite_index = -1;
    }
}
else{
    sprite_index = object_get_sprite(object_index);
}
