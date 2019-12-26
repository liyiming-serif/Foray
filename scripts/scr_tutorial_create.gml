#define scr_tutorial_create
///scr_tutorial_create(obj_following, conditional, display_text="")

var obj = argument[0];

with(instance_create(obj.x, obj.y, obj_tutorial)){
    obj_following = obj;
    conditional = argument[1];
    if(argument_count > 2){
        display_text = argument[2];
        sprite_index = spr_tutorial_key;
    }
    else{ //hack: if there's no text on the key, it must be a mouse cmd
        sprite_index = spr_tutorial_mouse;
    }
}

#define scr_tutorial_has_boosted
///scr_tutorial_has_boosted()

return keyboard_check_released(global.boost_key);

#define scr_tutorial_has_braked
///scr_tutorial_has_braked()

return keyboard_check_released(global.brake_key);

#define scr_tutorial_has_shot
///scr_tutorial_has_shot()

return mouse_check_button_released(mb_left);

#define scr_tutorial_has_commandeered
///scr_tutorial_has_commandeered()

var res;

if(!variable_instance_exists(id,"prev_player_id")){
    prev_player_id = global.player_id;
    return false;
}
if(global.player_id!=prev_player_id){
    res = true;
}
else{
    res = false;
}
prev_player_id = global.player_id;
return res;

#define scr_tutorial_has_paused
///scr_tutorial_has_paused()

return keyboard_check_released(global.options_key);
