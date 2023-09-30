///scr_hittable_collide_with_projectile()

if(is_friendly==other.is_friendly) return undefined;
if(invincibility>0) return undefined;
if(hp<=0) return undefined;

//apply dmg + initiate death seq if hp <= 0
hp -= other.dmg;
if(hp <= 0){
    //TODO: generalize death seq?
    instance_destroy();
}

//flash white
hitstun = log2(other.dmg+1)*2.2;
invincibility = other.hit_invuln;
