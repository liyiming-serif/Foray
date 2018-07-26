///scr_shoot()

if(shoot_counter >= shoot_rate){
    shoot_counter = 0;
    var b = instance_create(x,y,obj_bullet);
    b.direction = image_angle+random_range(-shoot_variance,shoot_variance);
    b.speed = speed + 7;
    b.image_angle = b.direction;
    b.alarm[0] = shoot_range+random_range(-shoot_range_variance, shoot_range_variance);
    
    part_type_life(global.flare1, room_speed*0.15, room_speed*0.15);
    part_type_direction(global.flare1,b.direction,b.direction,0,0);
    part_type_orientation(global.flare1,-shoot_variance,shoot_variance,0,0,true);
    part_type_speed(global.flare1,speed,speed,0,0);
    part_particles_create(global.partsys,x,y,global.flare1,1);
    alarm[11] = room_speed*0.05;
    sprite_index = spr_plane1_shoot;
    return b;
}
else{
    shoot_counter += 1;
    return noone;
}
