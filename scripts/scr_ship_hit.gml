#define scr_ship_hit
///scr_ship_hit(is_contact)

//Abstract function for when a ship collides with a projectile.

if(hp<=0) return undefined;

if(is_friendly!=other.is_friendly){

    if(invincibility>0){ //destroy bullet and exit early
        instance_destroy(other);
        return undefined;
    }    

    //spawn projectile's hit particle
    if(!is_undefined(other.hit_part)){
        part_type_direction(other.hit_part,other.direction,other.direction,0,0);
        part_type_orientation(other.hit_part,0,0,0,0,true);
        part_particles_create(global.partsys,other.x,other.y,other.hit_part,1);
    }
    
    //flash white
    hitstun = other.dmg*room_speed/30;
    
    //apply dmg + initiate death seq if hp <= 0
    hp -= other.dmg;
    if(hp <= 0){
        if(has_death_seq){
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
#define scr_ship_advance_frame
///scr_ship_advance_frame()

//countdown hitstun and invincibility
hitstun = max(hitstun-global.game_speed, 0);
invincibility = max(invincibility-global.game_speed,0);

#define scr_ship_instantiate
///scr_ship_instantiate(is_friendly)

//SUPERCLASS CONSTRUCTOR: don't call directly
//hitstun and invincibility frames
is_friendly = argument0;
hitstun = 0;
invincibility = 0;
