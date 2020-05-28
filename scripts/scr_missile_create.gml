#define scr_missile_create
///scr_missile_create(x,y,missile_type)

var xv = argument[0];
var yv = argument[1];
var type = argument[2];
//Wrapper around instance_create that also inits JSON properties
var mp = ds_map_find_value(global.projectilesque, type);
//projectile not found, returning null id
if(mp==undefined){
    return undefined;
}

with(instance_create(xv, yv, asset_get_index(ds_map_find_value(mp,"obj_ind")))){
    direction = dir;
    
    //deserialize json: ship
    curr_speed = ds_map_find_value(mp, "speed");
    turn = ds_map_find_value(mp, "turn");
    scr_ship_instantiate(false,mp);
    //deserialize json: projectile
    hit_part = variable_global_get(ds_map_find_value(mp,"hit_part"));
    miss_part = variable_global_get(ds_map_find_value(mp,"miss_part"));
    
    //missile types
    switch(type){
        case "player_missile":
            target_id = global.player_id;
            break;
        case "city_missile":
            target_id = global.city_id;
            airtime = ds_map_find_value(mp, "airtime");
            break;
    }
    if(!scr_instance_exists(target_id)){
        instance_destroy();
        return undefined;
    }
    
    return id;
}



#define scr_missile_turn
///scr_missile_turn()

//Turn the missile towards target
if(scr_instance_exists(target_id)){
    scr_ship_turn(target_id.x, target_id.x, true);
}
else{
    //target missed: explode
    if(variable_instance_exists(id,"miss_part")){
        part_type_direction(miss_part,direction,direction,0,0);
        part_type_orientation(miss_part,0,0,0,0,true);
        part_particles_create(global.partsys,x,y,miss_part,1);
    }
    instance_destroy();
}