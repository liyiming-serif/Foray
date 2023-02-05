///scr_flamethrower_step()

//super.step()
event_inherited();

if(!is_wpn_on){
    //extinguish flame
    if(scr_instance_exists(projectile_id)){
        if (variable_instance_exists(projectile_id,"linger_alarm")) {
            if(!projectile_id.alarm[projectile_id.linger_alarm]) {
                projectile_id.alarm[projectile_id.linger_alarm] = projectile_id.linger;
            }
        }
        else{
            instance_destroy(projectile_id);
        }
    }
}

is_wpn_on = false;
