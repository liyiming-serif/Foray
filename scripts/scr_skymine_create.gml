#define scr_skymine_create
///scr_skymine_create(x, y, launch_dir, launch_vel)
var xv = argument0;
var yv = argument1;
var launch_dir = argument2;
var launch_vel = argument3*global.game_speed;
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
    
    image_speed = 0.5;
    
    scr_ship_instantiate(false);
    
    return id;
}

#define scr_skymine_queue
///scr_skymine_queue(x, y)

//Defer creating a skymine until (x,y) is outside the player's view.
//Useful for scheduled waves, so mines don't appear out of thin air.
var tuple;
tuple[0] = argument0;
tuple[1] = argument1;
ds_list_add(global.skymine_queue, tuple);

#define scr_skymine_hit
///scr_skymine_hit()

if(is_friendly!=other.is_friendly && hp>0 && invincibility<=0 && abs(speed)<=friction){
    //get pushed around
    speed = other.dmg*global.game_speed;
    direction = other.direction;
}
scr_ship_hit();