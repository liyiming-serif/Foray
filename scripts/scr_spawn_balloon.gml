#define scr_spawn_balloon
///scr_spawn_balloon(wpn_ind)

var wpn_ind = argument[0];

scr_spawn_balloon_helper(false, wpn_ind);


scr_add_design_pattern("scr_spawn_balloon");

#define scr_spawn_amr_balloon
///scr_spawn_amr_balloon(wpn_ind)

var wpn_ind = argument[0];
scr_spawn_balloon_helper(true, wpn_ind);


scr_add_design_pattern("scr_spawn_amr_balloon");

#define scr_spawn_balloon_helper
//scr_spawn_balloon_helper(is_armored, wpn_name)

//select wpn
var is_amred = argument[0];
var wpn_ind = argument[1];

if(false){
    //TODO: move this to the spawn callers
    var cannon_cdf = 0.7;
    var mg_cdf = 0.8;
    var airtillery_cdf = 0.95;
    var burst_cannon_cdf = 1;
    var rng = random(1);
    
    if(rng<cannon_cdf){
        wpn_name = "cannon";
    }
    else if(rng<mg_cdf){
        wpn_name = "mg";
    }
    else if(rng<airtillery_cdf){
        wpn_name = "airtillery";
    }
    else if(rng<burst_cannon_cdf){
        wpn_name = "burst_cannon";
    }
    
    //default wpn
    if(!ds_map_exists(global.seen_wpns,wpn_name)){
        wpn_name = "cannon";
    }
}
//add default wpn
scr_add_seen_wpn("cannon");

//set course across the center of the map
var pos = scr_get_point_on_border();
var pd = point_direction(pos[0],pos[1],room_width/2,room_height/2);
var rad = min(room_width,room_height)*2/5;
var dest_x = room_width/2+lengthdir_x(rad,pd);
var dest_y = room_height/2+lengthdir_y(rad,pd);
scr_balloon_create(pos[0],pos[1],wpn_ind,is_amred,undefined,dest_x,dest_y);
