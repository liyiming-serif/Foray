///scr_fire_city_missile()

//check cooldown
if(shoot_counter < shoot_rate){
    return undefined;
}

//actually create missile
var b = scr_city_missile_create(x,y);
b.direction = image_angle;
b.image_angle = b.direction;
b.ttl = random_range(range[0],range[1])/b.curr_speed; //time to live
b.dmg = dmg;
return b;
