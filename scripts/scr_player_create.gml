#define scr_player_create
///scr_player_create(x, y, dir, model_name, wpn_name)
var xv = argument0;
var yv = argument1;
var dir = argument2;
var model_name = argument3;
var wpn_name = argument4;

//PLAYER CONSTRUCTOR:
with(instance_create(xv,yv,obj_player)){
    scr_plane_instantiate(dir,model_name,wpn_name,true);

    global.player_id = id;
    obj_cursor.modifier = modifier; //update cursor color palette
    return id;
}

#define scr_player_bail
///scr_player_bail(target_id)
var tid = argument[0]

has_pilot=false;
tid.has_pilot = false; //target plane bails too

//play buckling animation for old plane
sprite_index = spr_plane1_buckle;
image_index = 0;
l_bound_frame = 0;
r_bound_frame = image_number+1;

//creation code for player avatar
with(instance_create(x,y,obj_player_avatar)){
    global.player_id = id;
    is_friendly = true;
    
    image_speed = 0.4;
    jump_frame = 3;
    land_frame = 9;

    pid = other.id;    
    target_id = tid;
    has_jumped = false;
    
    if(target_id.y<y){
        sprite_index = spr_char_back;
    }
}
