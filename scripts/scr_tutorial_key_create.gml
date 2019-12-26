#define scr_tutorial_key_create
///scr_tutorial_key_create(obj_following, condition, display_text="")

var obj = argument[0];

with(instance_create(obj.x, obj.y, obj_tutorial)){
    obj_following = obj;
    keyboard_cmd = argument[1];
    if(argument_count > 2){
        display_text = argument[2];
        sprite_index = spr_tutorial_key;
    }
    else{ //hack: if there's no text on the key, it must be a mouse cmd
        sprite_index = spr_tutorial_mouse;
    }
}

#define scr_tutorial_mouse_create
///scr_tutorial_mouse_create(obj_following, mouse_cmd, display_text="")

var obj = argument[0];

with(instance_create(obj.x, obj.y, obj_tutorial_mouse)){
    obj_following = obj;
    mouse_cmd = argument[1];
    if(argument_count > 2){
        display_text = argument[2];
    }
}
#define scr_tutorial_has_boosted

#define scr_tutorial_has_braked

#define scr_tutorial_has_shot

#define scr_tutorial_has_commandeered

#define scr_tutorial_has_paused
