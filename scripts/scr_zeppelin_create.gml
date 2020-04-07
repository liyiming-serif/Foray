#define scr_zeppelin_create
///scr_zeppelin_create(x,y,front_wpn,left_wpn,right_wpn,dir_offset=0)

var xv = argument[0];
var yv = argument[1];
var front_wpn = argument[2];
var left_wpn = argument[3];
var right_wpn = argument[4];
var d_o = 0;
if(argument_count<5){
    var d_o = argument[5];
}

with(instance_create(xv,yv,obj_zeppelin)){
    //initiallize stats
    var mp = ds_map_find_value(global.balloons, "zeppelin");
    
    hp = ds_map_find_value(mp, "max_hp");
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    
    //set initial course
    direction = d_o;
    image_angle = direction;
    
    //mount wpns
    gid[0] = scr_wpn_create(x,y,0,front_wpn,false);
    gid[1] = scr_wpn_create(x,y,0,left_wpn,false);
    gid[2] = scr_wpn_create(x,y,0,right_wpn,false);
    gid[3] = scr_wpn_create(x,y,0,"mine_layer",false);
    
    //min_range determines nimbus
    min_range = 0;
    for(var i=0; i<array_length_1d(gid)-1; i++){
        if(scr_instance_exists(gid[i])){
            if(min_range==0 || gid[i].range[0]<min_range){
                min_range = gid[i].range[0];
            }
        }
    }
    min_range += sprite_width; //offset the zeppelin's own size
    
    scr_ship_instantiate(false,mp);
    
    //callbacks
    death_seq_cb = scr_ship_explode_large;
    
    /*
    engine_sound = audio_play_sound_on(engine_sound_emitter,snd_balloon_propeller,true,0);
    audio_sound_pitch(engine_sound,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));
    */
    return id;
}

#define scr_zeppelin_update_wpns
///scr_zeppelin_update_wpns()

//Update weapon position and image angle. Call during the end step.
var r, t;
//front wpn
if(scr_instance_exists(gid[0])){
    r = sprite_width-sprite_xoffset;
    t = image_angle;
    scr_ship_update_wpn(r,t,gid[0]);
}
//left wpn
if(scr_instance_exists(gid[1])){
    r = sprite_yoffset;
    t = image_angle+90;
    scr_ship_update_wpn(r,t,gid[1]);
}
//right wpn
if(scr_instance_exists(gid[2])){
    r = sprite_height-sprite_yoffset;
    t = image_angle-90;
    scr_ship_update_wpn(r,t,gid[2]);
}
//mine layer
if(scr_instance_exists(gid[3])){
    r = sprite_xoffset-12;
    t = image_angle+180;
    scr_ship_update_wpn(r,t,gid[3]);
}


#define scr_zeppelin_aim
///scr_zeppelin_aim()

//aim if in range
if(scr_instance_exists(target_id) && distance_to_object(target_id)<min_range){
    //fire wpn depending on angle
    var pa = point_direction(x, y, target_id.x, target_id.y);
    var da = angle_difference(pa,image_angle);
    
    if(da >= -45 && da < 45){ //front
        scr_ship_shoot(gid[0],"pressed");
    }
    else if(da >= 45 && da < 135){ //left
        scr_ship_shoot(gid[1],"pressed");
    }
    else if(da >= 135 || da < -135){ //back mine-layer
        scr_ship_shoot(gid[3],"pressed");
    }
    else if(da >= -135 && da < -45){ //right
        scr_ship_shoot(gid[2],"pressed");
    }
}

#define scr_zeppelin_turn
///scr_zeppelin_turn()

//Turn the blimp towards dest
if(scr_instance_exists(global.city_id)){
    scr_ship_turn(global.city_id.x, global.city_id.y, true);
}
else{
    scr_ship_turn(room_width/2, room_width/2, true);
}


#define scr_zeppelin_navigate
///scr_zeppelin_navigate()

//TODO: set new target once old target has been destroyed