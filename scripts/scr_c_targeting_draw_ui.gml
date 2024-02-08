///scr_c_targeting_draw_ui()

if(!variable_instance_exists(id,"target_sprite") ||
    !variable_instance_exists(id,"target_sprite_ind") ||
    !variable_instance_exists(id,"target_sprite_xoff") ||
    !variable_instance_exists(id,"target_sprite_yoff") ||
    !variable_instance_exists(id,"warn_range") ||
    !ds_map_exists(global.target_slots, object_get_name(object_index)) ||
    !scr_instance_exists(target_id)){
    
    return undefined;
}

var tpos, wr, can_draw_target, ol, ol_len, ol_i;

target_sprite_ind = (target_sprite_ind+0.4)%sprite_get_number(target_sprite);

//decide whether to draw warn target
can_draw_target = false;
//within distance?
wr = point_distance(x,y,target_id.x,target_id.y) > warn_range;
//list of targeting objects closing in on the same target
ol = global.target_slots[? object_get_name(id.object_index)];
ol_len = ds_list_size(ol);
//instance's place in the object list
ol_i = ds_list_find_index(ol,id);
if(wr){
    if(ol_len < global.MAX_DRAWN_TARGETS || ol_i != -1){
        can_draw_target = true;
    }
}
//just entered warning range, add inst to table
if(can_draw_target && ol_i == -1){
    ds_list_add(global.target_slots[? object_get_name(object_index)],id);
}
//just left warning range, remove inst from table
if(!can_draw_target && ol_i != -1){
    ds_list_delete(global.target_slots[? object_get_name(object_index)], ol_i);
}

if(can_draw_target){
    tpos = scr_game_to_gui(target_id.x+target_sprite_xoff, target_id.y+target_sprite_yoff);
    draw_sprite(target_sprite,target_sprite_ind,tpos[0],tpos[1]);
}
