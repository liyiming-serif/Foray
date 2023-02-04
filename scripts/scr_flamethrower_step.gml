///scr_flamethrower_step()

//super.step()
event_inherited();

if(!is_wpn_on){
    //extinguish flame
    if(scr_instance_exists(projectile_id)){
        instance_destroy(projectile_id);
    }
}
is_wpn_on = false;
