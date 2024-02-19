///scr_spawn_blimp()

//set course perpendicular to the center of the map
var pos = scr_get_point_on_border();
var pd = point_direction(pos[0],pos[1],room_width/2,room_height/2);
var ppd = angle_difference(0,pd+choose(-90,90));

scr_instance_create(pos[0],pos[1],obj_blimp,ppd,false);
scr_add_design_pattern("scr_spawn_blimp");
