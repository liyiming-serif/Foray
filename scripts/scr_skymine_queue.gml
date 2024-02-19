#define scr_skymine_queue
///scr_skymine_queue(x, y, chase_player=false)

//Defer creating a skymine until (x,y) is outside the player's view.
//Useful for scheduled waves, so mines don't appear out of thin air.
var tuple;
tuple[0] = argument[0];
tuple[1] = argument[1];
if(argument_count == 3){
tuple[2] = argument[2];
}
else{
tuple[2] = false;
}

ds_list_add(global.skymine_queue, tuple);

#define scr_skymine_collide_with_projectile
///scr_skymine_collide_with_projectile()

if(is_friendly!=other.is_friendly && hp>0 && invuln<=0 && abs(speed)<=friction){
    //get pushed around
    speed = other.dmg*global.game_speed;
    direction = other.direction;
}
scr_c_hull_collide_with_projectile();

#define scr_skymine_ai_chase
///scr_skymine_ai_chase()

//Runs only once per alarm
if(!chase_player || !scr_instance_exists(global.player_id)){
    return undefined;
}

if(!scr_instance_exists(target_id)){
    target_id = global.player_id;
}

//look ahead and check for any solids/allies in the way
var l, sp, pd, i, can_move;
sp =  chase_vel*global.game_speed;
pd = point_direction(x,y,target_id.x,target_id.y);
l = sp*sp/(2*friction);

i = collision_line(x,y,lengthdir_x(l,pd)+x,lengthdir_y(l,pd)+y,obj_obstacle_parent,false,true);
can_move = true;
if(i!=noone){
    if(!variable_instance_exists(i, "is_friendly") || i.is_friendly == is_friendly){
        can_move = false;
    }
}

//nothing in the way: move
if(can_move){
    speed = sp;
    direction = pd;
}

alarm[chase_alarm] = chase_freq;

#define scr_skymine_collide_with_plane
///scr_skymine_collide_with_plane()
if(variable_instance_exists(other, "roll_invuln") && other.roll_invuln>0){
    return undefined;
}

if(other.is_friendly != is_friendly ){
    points = 0;
    scr_play_sound(snd_detonation,x,y,);
    instance_destroy();
}