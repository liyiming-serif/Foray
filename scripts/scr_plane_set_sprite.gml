///scr_plane_set_sprite(state=none)

var spr_name = "spr_plane";
if(is_friendly){
    spr_name += "_a";
}
else{
    spr_name += "_e";
}
spr_name += "_"+chassis;
if(argument_count == 1){
    spr_name += "_"+argument[0];
}

sprite_index = asset_get_index(spr_name);
