///scr_missile_target_city()

if(scr_instance_exists(global.city_id)){
    target_id = global.city_id;
    return true;
}
else {
    return false;
}
