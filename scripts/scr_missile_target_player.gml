///scr_missile_target_player()

if(scr_instance_exists(global.player_id)){
    target_id = global.player_id;
    return true;
}
else {
    return false;
}
