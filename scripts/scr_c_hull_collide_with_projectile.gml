///scr_c_hull_collide_with_projectile()

if(is_friendly==other.is_friendly) return undefined;
if(hp<=0) return undefined;

var is_sp_dmg = variable_instance_exists(other,"sp_dmg");
var is_piercing = variable_instance_exists(other,"invuln") ||
    variable_instance_exists(other,"sp_invuln");
//trigger destroy on non-piercing projectiles
if(!is_piercing){
    instance_destroy(other);
}

//apply dmg + invuln + flash white
if(is_sp_dmg){
    //hit invuln: exit early
    if(sp_invuln>0) return undefined;
    
    hp -= other.sp_dmg;
    if(is_piercing){
        sp_invuln = other.sp_invuln;
    }
    hitstun = log2(other.sp_dmg+1)*2.2;
}
else{
    //hit invuln: exit early
    if(invuln>0) return undefined;
    
    hp -= other.dmg;
    if(is_piercing){
        invuln = other.invuln;
    }
    hitstun = log2(other.dmg+1)*2.2;
}

//initiate death seq if hp <= 0
if(hp <= 0){
    if(variable_instance_exists(id,"shot_down_cb")){
        script_execute(shot_down_cb);
    }
    else{
        instance_destroy();
    }
}

//effects
//spawn projectile's hit particle
if(variable_instance_exists(other,"hit_part")){
    part_type_direction(other.hit_part,other.direction,other.direction,0,0);
    part_type_orientation(other.hit_part,0,0,0,0,true);
    part_particles_create(global.partsys,other.x,other.y,other.hit_part,1);
}

//audio
scr_play_sound(snd_hitting,x,y);
