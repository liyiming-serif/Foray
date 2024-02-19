///scr_c_bullet_step()
//req: range(ttl)

//adjust speed based on game_speed
speed = global.game_speed*(curr_speed);
ttl = max(0,ttl-global.game_speed);

///out of range: kms+spawn miss part
if(ttl<=0){
    if(variable_instance_exists(id,"miss_part")){
        part_type_direction(miss_part,direction,direction,0,0);
        part_type_orientation(miss_part,0,0,0,0,true);
        part_particles_create(global.partsys,x,y,miss_part,1);
    }
    instance_destroy();
}
