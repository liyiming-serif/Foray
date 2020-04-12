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
