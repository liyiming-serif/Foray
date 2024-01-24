//scr_c_hull_collide_with_skymine()
//really more plane_collide_with_skymine

//NOTE: skymine will destroy self

//hit invuln: exit early
if(invuln>0) return undefined;

//apply dmg + invuln + flash white
hp -= other.dmg;
hitstun = log2(other.dmg+1)*2.2;

//initiate death seq if hp <= 0
if(hp <= 0){
    if(variable_instance_exists(id,"shot_down_cb")){
        script_execute(shot_down_cb);
    }
    else{
        instance_destroy();
    }
}
