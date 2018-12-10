#define scr_player_create
///scr_player_create(x, y, dir, model)

//CONSTRUCTOR:
with(instance_create(argument0,argument1,obj_player)){
    direction = argument2;
    scr_plane_create(argument3);
    is_buckle = false; //can't perform ANY action that would change sprite (i.e. shoot)
    global.player_id = id;
    obj_cursor.rt_modifier = rt_modifier; //update cursor color palette
    return id;
}

#define scr_player_bail
///scr_player_bail(target_id)

scr_plane_bail();

//creation code for player avatar
with(instance_create(x,y,obj_player_avatar)){
    global.player_id = id;
    
    image_speed = 0.25;
    jump_frame = 4;
    land_frame = 6;
    
    target_id = argument0;
    target_coords[0] = target_id.x+lengthdir_x(target_id.speed*jump_frame/image_speed,target_id.direction);
    target_coords[1] = target_id.y+lengthdir_y(target_id.speed*jump_frame/image_speed,target_id.direction);
    
    if(target_coords[1]<y){
        sprite_index = spr_char_back;
    }
}
