///scr_ai_add_common()

var aimp = ds_map_find_value(mp, "ai");
update_target_time = ds_map_find_value(aimp,"update_target_time");
if(!is_friendly){
    target_id = global.player_id;
    alarm[update_target_time_alarm] = update_target_time;
}
