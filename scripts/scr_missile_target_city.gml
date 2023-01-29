#define scr_missile_target_city
///scr_missile_target_city()

if(scr_instance_exists(global.city_id)){
    target_id = global.city_id;
    return true;
}
else {
    return false;
}

#define scr_missile_target_player
///scr_missile_target_player()

if(scr_instance_exists(global.player_id)){
    target_id = global.player_id;
    return true;
}
else {
    return false;
}