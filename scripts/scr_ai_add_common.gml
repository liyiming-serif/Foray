///scr_ai_add_common(aimp)

var aimp = argument[0];
update_target_time = ds_map_find_value(aimp,"update_target_time");
if(!is_friendly){
    target_id = global.player_id;
    alarm[update_target_time_alarm] = update_target_time;
}
