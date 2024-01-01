///scr_fire_missile()

//req components: c_auto

//check cooldown
if(shoot_counter < shoot_rate){
    return undefined;
}
shoot_counter = 0;

//find missile data
var mp = ds_map_find_value(global.projectiles, projectile);

//actually create missile
var p = scr_instance_create(
    x,
    y,
    projectile_ind,
    is_friendly);
//set trajectory
p.direction = direction;
p.image_angle = p.direction;
p.ttl = random_range(range[0],range[1])/p.curr_speed; //time to live

p.dmg = dmg;
return p;
