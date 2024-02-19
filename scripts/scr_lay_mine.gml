///scr_lay_mine()
//req: , mine_hp_reduc

//check cooldown & spawn limit
if(shoot_counter<shoot_rate || global.spawn_cap>2){
    return undefined;
}
shoot_counter = 0;

//Actually spawn mine
var dir, vel;
dir = image_angle+random_range(-accuracy,accuracy);
//spawn in player's direction if possible
if(scr_instance_exists(global.player_id)){
    dir = point_direction(x,y,global.player_id.x,global.player_id.y);
    dir += random_range(-accuracy,accuracy);
}
vel = global.game_speed*((muzzle_vel)+random_range(-muzzle_vel_var,muzzle_vel_var));
var b = scr_instance_create(x,y,obj_skymine,dir,false,false);
b.max_hp *= mine_hp_reduc;
b.hp *= mine_hp_reduc;
b.speed = vel;
scr_play_sound(snd_spawn_skymine,x,y);
return b;
