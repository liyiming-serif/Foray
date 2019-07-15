#define scr_ship_instantiate
///scr_ship_instantiate(is_friendly, ds_map, update_target_time=-1)

//SUPERCLASS CONSTRUCTOR: don't call directly
//hitstun and invincibility frames
is_friendly = argument[0];
var mp = argument[1];

hitstun = 0;
invincibility = 0;
threat = ds_map_find_value(mp,"threat");

//update target time
if(!is_friendly){
    var utt = ds_map_find_value(mp,"update_target_time");
    if(utt != undefined){
        update_target_time = utt;
    }
    else if(argument_count==3){
        update_target_time = argument[2];
    }
    else{
        return undefined;
    }
    target_id = global.player_id;
    alarm[10] = update_target_time;
}

#define scr_ship_advance_frame
///scr_ship_advance_frame()

//countdown hitstun and invincibility
hitstun = max(hitstun-global.game_speed, 0);
invincibility = max(invincibility-global.game_speed,0);

#define scr_ship_hit
///scr_ship_hit()

//Abstract function for when a ship collides with a projectile.

if(hp<=0) return undefined;

if(is_friendly!=other.is_friendly){

    if(invincibility>0){ //destroy bullet and exit early
        instance_destroy(other);
        return undefined;
    }    

    //spawn projectile's hit particle
    if(variable_instance_exists(other,"hit_part")){
        part_type_direction(other.hit_part,other.direction,other.direction,0,0);
        part_type_orientation(other.hit_part,0,0,0,0,true);
        part_particles_create(global.partsys,other.x,other.y,other.hit_part,1);
    }
    
    //Apply armor 
    if(variable_instance_exists(id,"amr")){
        other.dmg = max(other.dmg-amr,global.MIN_DMG);
    }
    
    //flash white
    hitstun = other.dmg*room_speed/30;
    
    //player_hit specific code
    //This isn't its own function because it needs to run
    //after dmg calculation, but before dmg application.
    if(!other.is_friendly){
        //TODO: apply screen shake
        //TODO: apply screen flash
        
        //DIFFICULTY MOD: scale dmg down by spawn capacity
        other.dmg = max((1-global.spawn_cap*0.6)*other.dmg,global.MIN_DMG);
    }
    
    //apply dmg + initiate death seq if hp <= 0
    hp -= other.dmg;
    if(hp <= 0){
        if(variable_instance_exists(id,"death_seq_cb")){
            script_execute(death_seq_cb);
        }
        else{
            instance_destroy();
        }
    }
    
    //destroy bullet
    instance_destroy(other);
}

#define scr_ship_shade
///scr_ship_shade()

//Shared shading logic across all ships

if(hitstun>0){ //apply hit flash
    shader_set(shader_hit_flash);
}
draw_self();
shader_reset();
#define scr_ship_gc_wpns
///scr_ship_gc_wpns()
if(is_array(gid)){
    for(i=0; i<array_length_1d(gid); i++){
        if(scr_instance_exists(gid[i])){
            instance_destroy(gid[i]);
        }
    }
}
else if(scr_instance_exists(gid)){
    instance_destroy(gid);
}

#define scr_ship_update_wpn
///scr_ship_update_wpn(r,t,gid,rot_locked_by_ship=true)

//Update weapon position and image angle using polar coordinates.
//Call during the end step!

var r = argument[0];
var t = argument[1];
var g = argument[2];
if(!scr_instance_exists(g)){
    return -1;
}

if(argument_count==3 || argument[3]==true){
    g.image_angle = t;
}

g.x = x+lengthdir_x(r,t);
g.y = y+lengthdir_y(r,t);

#define scr_ship_shoot
///scr_ship_shoot(gid, cb_type)

//wrapper around executing gid callbacks for reducing copied code
var g, cb, ret;
g = argument[0];
cb = argument[1];

with(g){
    switch(cb){
        case "on_click":
            ret = script_execute(on_click_cb);
            break;
        case "pressed":
            ret = script_execute(pressed_cb);
            break;
        case "on_release":
            ret = script_execute(on_release_cb);
            break;
    }
}
return ret;