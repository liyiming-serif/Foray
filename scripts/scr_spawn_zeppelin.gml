///scr_spawn_zeppelin(front_wpn=rand, side_wpn=rand)

//select front and side wpns
var front_wpn = "";
var side_wpn = "";
if(argument_count>0){
    front_wpn = argument[0];
    side_wpn = argument[1];
}
else{
    //front wpn
    var airtillery_cdf = 0.5;
    var burst_cannon_cdf = 0.75;
    var cannon_cdf = 0.9;
    var mg_cdf = 1;
    var rng = random(1);
    
    if(rng<airtillery_cdf){
        front_wpn = "airtillery";
    }
    else if(rng<burst_cannon_cdf){
        front_wpn = "burst_cannon";
    }
    else if(rng<cannon_cdf){
        front_wpn = "cannon";
    }
    else if(rng<mg_cdf){
        front_wpn = "mg";
    }
    //default
    if(!ds_map_exists(global.seen_wpns,front_wpn)){
        front_wpn = "airtillery";
    }
    
    //side wpn
    burst_cannon_cdf = 0.5;
    airtillery_cdf = 0.75;
    cannon_cdf = 0.9;
    mg_cdf = 1;
    rng = random(1);
    
    if(rng<burst_cannon_cdf){
        side_wpn = "burst_cannon";
    }
    else if(rng<airtillery_cdf){
        side_wpn = "airtillery";
    }
    else if(rng<cannon_cdf){
        side_wpn = "cannon";
    }
    else if(rng<mg_cdf){
        side_wpn = "mg";
    }
    //default
    if(!ds_map_exists(global.seen_wpns,side_wpn)){
        side_wpn = "burst_cannon";
    }
}
//add default wpns
scr_add_seen_wpn("airtillery");
scr_add_seen_wpn("burst_cannon");

//set course across the center of the map
var pos = scr_get_point_on_border();
var pd = point_direction(pos[0],pos[1],room_width/2,room_height/2);
var dest_x = room_width/2;
var dest_y = room_height/2;
scr_instance_create(pos[0],pos[1],obj_zeppelin,
    choose(90,-90),false,front_wpn,side_wpn,side_wpn);

scr_add_design_pattern("scr_spawn_zeppelin");
