///scr_fire_missile()

//check cooldown
if(shoot_counter < shoot_rate){
    return undefined;
}
shoot_counter = 0;
//actually create missile
var b = scr_missile_create(x,y,image_angle,bullet_type,is_friendly);
b.ttl = random_range(range[0],range[1])/b.curr_speed; //time to live
b.dmg = dmg;
return b;
