#define scr_is_obj_outside_room
///scr_is_obj_outside_room()

//primarily used as ship turning helper

//should be hypoteneuse of the sprite, but that's too compute heavy
var d = max(sprite_width, sprite_height);
if(x < -d || x > room_width+d || y < -d || y > room_height+d){
    return true;
}
else{
    return false;
}

#define scr_is_obj_outside_view
///scr_is_obj_outside_view(place_x = x, place_y = y)

//primarily used for determining position of grounded objects
//optional: use hypothetical x and y coordinates

var tx = x;
var ty = y;
if(argument_count >= 2){
    var tx = argument[0];
    var ty = argument[1];
}
var vc, view_bottom, view_right, spr_top, spr_bottom, spr_left, spr_right;

vc = scr_view_current();
view_bottom = view_hview[vc]+view_yview[vc];
view_right = view_wview[vc]+view_xview[vc];
spr_top = ty-sprite_yoffset;
spr_bottom = ty+sprite_height-sprite_yoffset;
spr_left = tx-sprite_xoffset;
spr_right = tx+sprite_width-sprite_xoffset;
if(spr_right<view_xview[vc] || spr_left>view_right
    || spr_bottom<view_yview[vc] || spr_top>view_bottom){
    
    return true;    
}
else{
    return false;
}