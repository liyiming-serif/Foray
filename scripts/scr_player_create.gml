#define scr_player_create
///scr_player_create(x, y, dir, model, wpn_name='')

//CONSTRUCTOR:
with(instance_create(argument0,argument1,obj_player)){
    direction = argument2;
    scr_plane_instantiate(argument3);
    //arm the plane
    gid = scr_wpn_create(x,y,direction,argument4,true);

    global.player_id = id;
    obj_cursor.modifier = modifier; //update cursor color palette
    return id;
}

#define scr_player_bail
///scr_player_bail(target_id)

has_pilot=false;
argument[0].has_pilot = false; //target plane bails too

//play buckling animation for old plane
sprite_index = spr_plane1_buckle;
image_index = 0;
l_bound_frame = 0;
r_bound_frame = image_number+1;

//creation code for player avatar
with(instance_create(x,y,obj_player_avatar)){
    global.player_id = id;
    
    image_speed = 0.25;
    jump_frame = 4;
    land_frame = 6;

    pid = other.id;    
    target_id = argument0;
    has_jumped = false;
    
    if(target_id.y<y){
        sprite_index = spr_char_back;
    }
}