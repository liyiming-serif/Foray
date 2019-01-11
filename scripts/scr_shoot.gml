#define scr_shoot
///scr_shoot()
//TODO: take angular+linear velocity into account
if(shoot_counter < shoot_rate){
    return noone;
}
shoot_counter = 0;
//compute angular velocity
var 

//actually create bullet
var b = instance_create(x+lengthdir_x(barrel,image_angle),y+lengthdir_y(12,image_angle),type);
b.direction = image_angle+random_range(-accuracy,accuracy);
b.speed = speed + sp;
b.image_angle = b.direction;
b.alarm[0] = range;
b.dmg = dmg;
b.isFriendly = isFriendly;

//produce muzzle flare [optional]
if(part_type!=noone){
    part_type_life(part_type, room_speed*0.1, room_speed*0.15);
    part_type_direction(part_type,b.direction,b.direction,0,0);
    part_type_orientation(part_type,0,0,0,0,true);
    part_type_speed(part_type,speed,speed,0,0);
    part_particles_create(global.partsys,x,y,part_type,1);
}

return b;

#define scr_wpn_create
///scr_wpn_create(wpn_name,isFriendly)

//Used for instantiating a generic gun from JSON.
//Additional properties must be read in wpn obj's create event.

var mp = ds_map_find_value(global.WEAPONS,argument0);
isFriendly = argument1;
image_angle_prev = image_angle;

//scr_shoot attributes
bullet_type = asset_get_index(ds_map_find_value(mp,"projectile_ind"));
shoot_rate = ds_map_find_value(mp,"shoot_rate");
shoot_counter = 0;
recoil = ds_map_find_value(mp,"recoil"); //num frames gun and plane flash from firing
accuracy = ds_map_find_value(mp,"accuracy");
muzzle_vel = ds_map_find_value(mp,"speed");
dmg = ds_map_find_value(mp,"dmg");
lifespan[0] = ds_list_find_value(ds_map_find_value(mp,"lifespan"),0);
lifespan[1] = ds_list_find_value(ds_map_find_value(mp,"lifespan"),1);
if(ds_map_exists(mp,"barrel_len")){
    barrel_len = ds_map_find_value(mp,"barrel_len");
}
else{
    barrel_len = sprite_width;
}

//callbacks
on_click_cb = scr_do_nothing;
pressed_cb = scr_do_nothing;
on_release_cb = scr_do_nothing;

//animation
image_speed = 0;
anim_speed = ds_map_find_value(mp,"anim_speed");
shoot_frame = ds_map_find_value(mp,"shoot_frame");
l_bound_frame = 0;
u_bound_frame = shoot_frame;


#define scr_do_nothing
///scr_do_nothing()

//placeholder script to save on error-checking
return undefined;