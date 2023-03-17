#define scr_tutorial_create
///scr_tutorial_create(obj_following, conditional, sprite_index, display_text="")

var obj = argument[0];

with(instance_create(obj.x, obj.y, obj_tutorial)){
    obj_following = obj;
    conditional = argument[1];
    sprite_index = argument[2];
    display_text = "";
    if(argument_count > 3){
        display_text = argument[3];
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

#define scr_tutorial_has_stolen
///scr_tutorial_has_stolen()

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
#define scr_tutorial_has_rolled
///scr_tutorial_has_rolled()

return keyboard_check_pressed(global.roll_key);
