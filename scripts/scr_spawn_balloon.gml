#define scr_spawn_balloon
///scr_spawn_balloon(wpn_ind=rand)

var wpn_ind = argument[0];

;
if(argument_count==1){
    wpn_ind = argument[0];
}
else{
    //random generate wpn_ind
    var poss_wpns;
    poss_wpns[0] = "obj_cannon";
    poss_wpns[1] = "obj_light_mg";
    poss_wpns[2] = "obj_airtillery";
    wpn_ind = scr_spawn_choose_wpn(poss_wpns);
}
scr_spawn_balloon_helper(false, wpn_ind);

scr_add_design_pattern("scr_spawn_balloon");

#define scr_spawn_amr_balloon
///scr_spawn_amr_balloon(wpn_ind=rand)

var wpn_ind;
if(argument_count==1){
    wpn_ind = argument[0];
}
else{
    //random generate wpn_ind
    var poss_wpns;
    poss_wpns[0] = "obj_cannon";
    poss_wpns[1] = "obj_light_mg";
    poss_wpns[2] = "obj_burst_cannon";
    wpn_ind = scr_spawn_choose_wpn(poss_wpns);
}
scr_spawn_balloon_helper(true, wpn_ind);

scr_add_design_pattern("scr_spawn_amr_balloon");

#define scr_spawn_unarmed_balloon
///scr_spawn_unarmed_balloon()

scr_spawn_balloon_helper(false, undefined);
scr_add_design_pattern("scr_spawn_unarmed_balloon");

#define scr_spawn_balloon_helper
//scr_spawn_balloon_helper(is_armored, wpn_ind)

//select wpn
var is_amred = argument[0];
var wpn_ind = argument[1];

//set course across the center of the map
var pos = scr_get_point_on_border();
var pd = point_direction(pos[0],pos[1],room_width/2,room_height/2);
var rad = min(room_width,room_height)*2/5;
var dest_x = room_width/2+lengthdir_x(rad,pd);
var dest_y = room_height/2+lengthdir_y(rad,pd);
var b = scr_instance_create(pos[0],pos[1],obj_balloon,
    0,false,wpn_ind,is_amred,undefined,dest_x,dest_y);
if(scr_instance_exists(b.gid)){
    scr_add_seen_wpn(wpn_ind);
}


#define scr_spawn_choose_wpn
///scr_spawn_choose_wpn(poss_wpns)
//ret: wpn_ind

var poss_wpns = argument[0];

var wpn_w = 0;
var poss_seen_wpns;
for(i=0; i<array_length_1d(poss_wpns); i++){
    if(ds_map_exists(global.seen_wpns, poss_wpns[i])){
        wpn_w += ds_map_find_value(global.wpn_weights, poss_wpns[i]);
        if(!is_array(poss_seen_wpns)){
            poss_seen_wpns[0] = poss_wpns[i];
        }
        else{
            poss_seen_wpns[array_length_1d(poss_seen_wpns)] = poss_wpns[i];
        }
    }
}
//weighted random roll go!
var r = irandom(wpn_w-1);
for(i=0; i<array_length_1d(poss_seen_wpns); i++){
    //wpn selected!
    if(r<ds_map_find_value(global.wpn_weights,poss_seen_wpns[i])){
        return asset_get_index(poss_seen_wpns[i]);
    }
    else{
        r -= ds_map_find_value(global.wpn_weights,poss_seen_wpns[i]);
    }
}
//error!
return undefined;