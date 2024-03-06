#define scr_shoot
///scr_shoot()
//Generic shooting callback. Can be expanded and customized.
//req: shoot_rate, shoot_frame, dx, dy

//check cooldown
if(shoot_counter < shoot_rate){
    return undefined;
}
shoot_counter = 0;
//produce recoil flash
scr_wpn_set_sprite(true);
alarm[SHOOT_FLASH_ALARM] = recoil;
//animate wpn firing
l_bound_frame = shoot_frame;
u_bound_frame = image_number;

/*COMPUTE DIRECTIONAL INFLUENCE*/
//compute linear velocity w/ respect to fire angle
var refx, refy, lv;
refx = lengthdir_x(1,image_angle);
refy = lengthdir_y(1,image_angle);
lv = dot_product(dx,dy,refx,refy);

//actually create bullet
var b = scr_instance_create(
    x+lengthdir_x(barrel_len,image_angle),
    y+lengthdir_y(barrel_len,image_angle),
    projectile_ind,
    is_friendly);
if(is_friendly){
    b.direction = image_angle+2*av+random_range(-accuracy,accuracy);
}
else{
    b.direction = image_angle+av+random_range(-accuracy,accuracy);
}
b.curr_speed = muzzle_vel + lv;
b.image_angle = b.direction;
b.ttl = random_range(range[0],range[1])/muzzle_vel; //time to live
b.dmg = dmg;

//produce muzzle flare [optional]
if(variable_instance_exists(id,"muzzle_flare")){
    part_type_direction(muzzle_flare,b.direction,b.direction,0,0);
    part_type_orientation(muzzle_flare,0,0,0,0,true);
    part_type_speed(muzzle_flare,lv,lv,0,0);
    part_particles_create(global.partsys,b.x,b.y,muzzle_flare,1);
}

//sound [optional]
if(variable_instance_exists(id,"shoot_snd")){
    scr_wpn_fire_sound();
}

return b;

#define scr_cannon_shoot
///scr_cannon_shoot()

var b = scr_shoot();
if(b!=undefined){
    b.image_angle = 0;
}
return b;

#define scr_charge_scatter
///scr_charge_scatter()

//Wrapper around scr_shoot that shoots in an even spread
//Only capatible with charge_shooting
var og_angle = image_angle;

image_angle += ((rounds-0.5)/max_rounds)*sweep_angle - sweep_angle/2;
var b = scr_shoot();

image_angle = og_angle;
return b;