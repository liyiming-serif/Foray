#define scr_city_warning_create
///scr_city_warning_create()

obj_hud_artist.warning_alarm = global.CITY_WARNING_DURATION;

#define scr_city_warning_move
//scr_city_warning_move(city_warning_sprite)
//returns: array [x,y]
var ret, vc, v_top, v_bottom, v_left, v_right, spr, s_top, s_bottom, s_left, s_right;

if(!scr_instance_exists(global.city_id) || !scr_is_obj_outside_view(
    global.city_id.x, global.city_id.y, global.CITY_WARNING_SENSITIVITY)){
    
    return -1;
}

vc = scr_view_current();
v_top = view_yview[vc]+global.CITY_WARNING_BORDER;
v_bottom = view_hview[vc]+view_yview[vc]-global.CITY_WARNING_BORDER;
v_left = view_xview[vc]+global.CITY_WARNING_BORDER;
v_right = view_wview[vc]+view_xview[vc]-global.CITY_WARNING_BORDER;

spr = argument[0];
s_top = sprite_get_yoffset(spr);
s_bottom = sprite_get_height(spr)-sprite_get_yoffset(spr);
s_left = sprite_get_xoffset(spr);
s_right = sprite_get_width(spr)-sprite_get_xoffset(spr);

ret[0] = clamp(global.city_id.x,v_left+s_left,v_right-s_right);
ret[1] = clamp(global.city_id.y,v_top+s_top,v_bottom-s_bottom);
return scr_game_to_gui(ret[0], ret[1]);
