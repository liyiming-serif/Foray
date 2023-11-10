///scr_c_hull_collide_with_projectile()

if(is_friendly==other.is_friendly) return undefined;
if(invincibility>0) return undefined;
if(hp<=0) return undefined;

//apply dmg + initiate death seq if hp <= 0
hp -= other.dmg;
if(hp <= 0){
    if(variable_instance_exists(id,"shot_down_cb")){
        script_execute(shot_down_cb);
    }
    else{
        instance_destroy();
    }
}

//flash white + apply iframes
hitstun = log2(other.dmg+1)*2.2;
invincibility = other.hit_invuln;
