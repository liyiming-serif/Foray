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
///scr_is_obj_outside_view(place_x=x, place_y=y, view_border=0)

//primarily used for determining position of grounded objects
//optional: use hypothetical x and y coordinates
//optional: shrink(+) or grow(-) the border to check for the obj

var tx = x;
var ty = y;
var bord = 0;
if(argument_count >= 2){
    tx = argument[0];
    ty = argument[1];
}
if(argument_count >= 3){
    bord = argument[2];
}
var vc,v_top,v_bottom,v_left,v_right,spr_top,spr_bottom,spr_left,spr_right;

vc = scr_view_current();
v_top = view_yview[vc]+bord;
v_bottom = view_hview[vc]+view_yview[vc]-bord;
v_left = view_xview[vc]+bord
v_right = view_wview[vc]+view_xview[vc]-bord;
spr_top = ty-sprite_yoffset;
spr_bottom = ty+sprite_height-sprite_yoffset;
spr_left = tx-sprite_xoffset;
spr_right = tx+sprite_width-sprite_xoffset;
if(spr_right<v_left || spr_left>v_right || spr_bottom<v_top || spr_top>v_bottom){
    return true;
}
else{
    return false;
}