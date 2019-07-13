#define scr_skymine_create
///scr_skymine_create(x, y, launch_dir, launch_vel, chase_player=false)
var xv = argument[0];
var yv = argument[1];
var launch_dir = argument[2];
var launch_vel = argument[3]*global.game_speed;
var chp = false;
if(argument_count>4){
    chp = argument[4];
}

with(instance_create(xv,yv,obj_skymine)){
    //launch the balloon
    direction = launch_dir;
    speed = launch_vel;
    
    //initiallize stats
    var mp = ds_map_find_value(global.balloons, "skymine");
    
    friction = ds_map_find_value(mp, "fric");
    hp = ds_map_find_value(mp, "max_hp");
    dmg = ds_map_find_value(mp, "dmg");
    range = ds_map_find_value(mp, "range");
    threat = ds_map_find_value(mp,"threat");
    chase_player = chp;
    
    //optional behavior: chase the player like Blooper
    if(chase_player){
        chase_vel = ds_map_find_value(mp,"chase_vel");
        chase_freq = ds_map_find_value(mp,"chase_freq");
        alarm[0] = chase_freq;
        scr_ship_instantiate(false,ds_map_find_value(mp, "update_target_time"));
    }
    else{
        scr_ship_instantiate(false);
    }
    
    image_speed = 0.5;
    
    return id;
}

#define scr_skymine_queue
///scr_skymine_queue(x, y)

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

#define scr_skymine_hit
///scr_skymine_hit()

if(is_friendly!=other.is_friendly && hp>0 && invincibility<=0 && abs(speed)<=friction){
    //get pushed around
    speed = other.dmg*global.game_speed;
    direction = other.direction;
}
scr_ship_hit();
#define scr_skymine_chase
///scr_skymine_chase()

//Runs only once per alarm
if(!chase_player || !scr_instance_exists(global.player_id)){
    return undefined;
}

if(!scr_instance_exists(target_id)){
    target_id = global.player_id;
}

//look ahead and check for any allies in the way
var l, sp, pd, i;
sp =  chase_vel*global.game_speed;
pd = point_direction(x,y,target_id.x,target_id.y);
l = sp*sp/(2*friction);

i = collision_line(x,y,lengthdir_x(l,pd)+x,lengthdir_y(l,pd)+y,obj_ship_parent,false,true);

//nothing in the way: move
if(i==noone || i.is_friendly){
    speed = sp;
    direction = pd;
}

alarm[0] = chase_freq;