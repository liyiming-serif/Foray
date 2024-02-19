///scr_c_ignition step()

if(!is_wpn_on){
    //deactivate/detonate wpn
    if(scr_instance_exists(projectile_id)){
        instance_destroy(projectile_id);
        if(variable_instance_exists(projectile_id,"linger_alarm")) {
            if(!projectile_id.alarm[projectile_id.linger_alarm]) {
                projectile_id.alarm[projectile_id.linger_alarm] = projectile_id.linger;
            }
        }
        else{
            instance_destroy(projectile_id);
        }
    }
}

//reset wpn
is_wpn_on = false;
