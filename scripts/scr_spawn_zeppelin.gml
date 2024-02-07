#define scr_spawn_zeppelin
///scr_spawn_zeppelin(front_wpn=rand, side_wpn=rand)

//select front and side wpns
var front_wpn;
var side_wpn;
if(argument_count>0){
    front_wpn = argument[0];
    side_wpn = argument[1];
}
else{
    //random generate front and side wpns
    var poss_wpns;
    poss_wpns[0] = "obj_cannon";
    poss_wpns[1] = "obj_airtillery";
    poss_wpns[2] = "obj_burst_cannon";
    front_wpn = scr_spawn_choose_wpn(poss_wpns);
    side_wpn = scr_spawn_choose_wpn(poss_wpns);
}
scr_spawn_zeppelin_helper(front_wpn, side_wpn);

//start spawning zeppelins
scr_add_design_pattern("scr_spawn_rhino_zeppelin");
scr_add_design_pattern("scr_spawn_broad_zeppelin");

#define scr_spawn_rhino_zeppelin
///scr_spawn_rhino_zeppelin(front_wpn=rand)

var front_wpn;
if(argument_count==1){
    front_wpn = argument[0];
}
else{
    //random generate front_wpn
    var poss_wpns;
    poss_wpns[0] = "obj_cannon";
    poss_wpns[1] = "obj_airtillery";
    poss_wpns[2] = "obj_burst_cannon";
    front_wpn = scr_spawn_choose_wpn(poss_wpns);
}
scr_spawn_zeppelin_helper(front_wpn, noone);

#define scr_spawn_broad_zeppelin
///scr_spawn_broad_zeppelin(side_wpn=rand)

var side_wpn;
if(argument_count==1){
    side_wpn = argument[0];
}
else{
    //random generate side_wpn
    var poss_wpns;
    poss_wpns[0] = "obj_cannon";
    poss_wpns[1] = "obj_airtillery";
    poss_wpns[2] = "obj_burst_cannon";
    side_wpn = scr_spawn_choose_wpn(poss_wpns);
}
scr_spawn_zeppelin_helper(noone, side_wpn);

#define scr_spawn_zeppelin_helper
///scr_spawn_zeppelin_helper(front_wpn, side_wpn)

//select wpn
var front_wpn = argument[0];
var side_wpn = argument[1];

//set course across the center of the map
var pos = scr_get_point_on_border();
var pd = point_direction(pos[0],pos[1],room_width/2,room_height/2);
var dest_x = room_width/2;
var dest_y = room_height/2;
scr_instance_create(pos[0],pos[1],obj_zeppelin,
    choose(90,-90),false,front_wpn,side_wpn,side_wpn);
    
//add default wpns
scr_add_seen_wpn("airtillery");
scr_add_seen_wpn("burst_cannon");
