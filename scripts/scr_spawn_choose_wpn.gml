///scr_spawn_choose_wpn(poss_wpns)
//ret: wpn_ind

var poss_wpns = argument[0];

var wpn_w = 0;
var poss_seen_wpns = 0;
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

//edge case: no wpns available, ship becomes unarmed
if(!is_array(poss_seen_wpns)){
    return undefined;
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
