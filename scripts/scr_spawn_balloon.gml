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

//create balloon at random point on border
var pos = scr_get_point_on_border();
var b = scr_instance_create(pos[0],pos[1],obj_balloon,
    0,false,wpn_ind,is_amred);
if(scr_instance_exists(b.gid)){
    scr_add_seen_wpn(wpn_ind);
}

