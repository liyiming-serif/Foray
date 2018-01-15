///scr_shoot()

if(shoot_counter >= shoot_rate){
    shoot_counter = 0;
    var b = instance_create(x,y,obj_bullet);
    b.direction = direction;
    b.speed = speed + 7;
    b.image_angle = image_angle;
    return b;
}
else{
    shoot_counter += 1;
}
