///scr_shoot(type, accuracy, speed, range, dmg, part_type, isFriendly)
var type = argument0;
var accuracy = argument1;
var sp = argument2;
var range = argument3;
var dmg = argument4;
var part_type = argument5;
var isFriendly = argument6;

if(shoot_counter >= shoot_rate){
    shoot_counter = 0;
    //actually create bullet
    var b = instance_create(x+lengthdir_x(16,image_angle),y+lengthdir_y(16,image_angle),type);
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
        part_type_orientation(part_type,-accuracy,accuracy,0,0,true);
        part_type_speed(part_type,speed,speed,0,0);
        part_particles_create(global.partsys,x,y,part_type,1);
    }
    
    return b;
}
else{
    shoot_counter += 1;
    return noone;
}
