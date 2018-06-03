///scr_shoot()

if(shoot_counter >= shoot_rate){
    shoot_counter = 0;
    var b = instance_create(x,y,obj_bullet);
    b.direction = direction+random_range(-shoot_variance,shoot_variance);
    b.speed = speed + 7;
    b.image_angle = b.direction;
    b.alarm[0] = shoot_range+random_range(-shoot_range_variance, shoot_range_variance);
    return b;
}
else{
    shoot_counter += 1;
}
