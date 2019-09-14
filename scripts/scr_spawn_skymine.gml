#define scr_spawn_skymine
///scr_spawn_skymine()

scr_skymine_queue(irandom(room_width),irandom(room_height));
scr_add_design_pattern("scr_spawn_skymine");

#define scr_spawn_chasing_skymine
///scr_spawn_chasing_skymine()

scr_skymine_queue(irandom(room_width),irandom(room_height),true);
scr_add_design_pattern("scr_spawn_chasing_skymine");

#define scr_spawn_skymine_cluster
///scr_spawn_skymine_cluster(chasing=rand)

var chase, center, rad, num;
if(argument_count>0){
    chase = argument[0];
}
else if(random(1)<0.6){
    chase = false;
}
else{
    chase = true;
}
center[0] = irandom(room_width);
center[1] = irandom(room_height);
rad = 36;
num = 5;

//spawn mines in a ring, with radius rad and size num
for(i = 0; i < num; i++){
    var dir = i/num*360;
    scr_skymine_queue(center[0]+lengthdir_x(rad,dir),center[1]+lengthdir_y(rad,dir),chase);
}

scr_add_design_pattern("scr_spawn_skymine_cluster");
