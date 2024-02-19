///scr_charge_volley()

if(rounds<=0){
    //update emitter
    audio_emitter_position(wpn_sound_emitter,x,y,0);
    audio_emitter_velocity(wpn_sound_emitter,hspeed,vspeed,0);
    
    //reload finished
    if(reload_counter<=0){
        reload_counter = reload_rate;
        rounds = max_rounds;
        return undefined;
    }
    else{
    //reloading...
        reload_counter = max(0,reload_counter-global.game_speed);
        //optional: create charge effect
        if(variable_instance_exists(id,"charge_part")){
            if(charge_part_frames<=0){
                charge_part_frames = min(reload_counter,random_range(charge_part_life[0],charge_part_life[1]));
                
                //create charge particle
                var sp = point_distance(0,0,dx,dy);
                var dir = point_direction(0,0,dx,dy);
                part_type_direction(charge_part,dir,dir,0,0);
                part_type_orientation(charge_part,image_angle,image_angle,0,0,false);
                part_type_speed(charge_part,sp,sp,0,0);
                part_type_life(charge_part,charge_part_frames,charge_part_frames);
                var xl, yl;
                xl = x+lengthdir_x(barrel_len,image_angle);
                yl = y+lengthdir_y(barrel_len,image_angle);
                part_particles_create(global.partsys,xl,yl,charge_part,1);
            }
            else{
                //current charge particle still exists
                charge_part_frames--;
            }
        }
        return undefined;
    }
}
else{
    //fire! (hardcoded to on_release)
    var b = script_execute(on_release_cb);
    if(b!=undefined){
        rounds--;
    }
    return b;
}
