#define scr_plane_create
///scr_plane_create(min_speed, max_speed, acc, turn, ai_skill)

//CONSTRUCTOR:
min_speed = argument0; //displayed as: speed
max_speed = argument1;
acc = argument2;
turn = argument3; //displayed as: turn

curr_speed = min_speed;
shoot_rate = 12;
shoot_counter = 0;
ax = 0;
ay = 0;
image_speed = 0;

//ai behavior parameters
react_time = argument4;

#define scr_plane_point_turn
///scr_plane_point_turn(xtarget, ytarget, away)

//turn the plane towards a target
if(argument2){
    var pa = point_direction(argument0,argument1,x,y);
}
else{
    var pa = point_direction(x,y,argument0,argument1);
}
var da = angle_difference(pa,direction);
var ta = min(abs(da),turn);
direction += ta*sign(da);
image_angle = direction;
speed = curr_speed*(1-ta/(turn*global.TURN_DAMPENER));
if(ta >= turn*global.TURN_SPRITE_THRESHOLD){
    if(sign(da) == -1){
        image_index = 2;
    }
    else{
        image_index = 1;
    }
}
else{
    image_index = 0;
}

#define scr_plane_boost
///scr_plane_boost()

if(curr_speed + acc < max_speed){
    curr_speed += acc;
}
else{
    curr_speed = max_speed;
}

#define scr_plane_brake
///scr_plane_brake()

if(curr_speed - global.AIR_FRIC > min_speed){
    curr_speed -= global.AIR_FRIC ;
}
else{
    curr_speed = min_speed;
}

#define scr_plane_turn_avoiding
///scr_plane_turn_avoiding(xtarget, ytarget, away)

//sensing obstacles
var sx, sy, i, adir, sharp;
sx = lengthdir_x(speed*48,direction);
sy = lengthdir_y(speed*48,direction);
i = collision_line(x,y,sx+x,sy+y,obj_ship_parent,false,true);
if(state != 3){
    ax = 0;
    ay = 0;
}
sharp = false;

//avoiding obstacles
if(i!=noone){
    //sprite_index = spr_plane3;
    adir = point_direction(i.x-x,i.y-y,sx,sy);
    ax = lengthdir_x(48,adir);
    ay = lengthdir_y(48,adir);
    state = 3;
}
else{
    //sprite_index = spr_plane2;
}

//turn the plane towards a target
if(state == 3){
    argument0 = x;
    argument1 = y;
}
if(argument2){
    var pa = point_direction(argument0+ax,argument1+ay,x,y);
}
else{
    var pa = point_direction(x,y,argument0+ax,argument1+ay);
}
var da = angle_difference(pa,direction);
if(sharp){
    var ta = min(abs(da),turn);
}
else{
    var ta = min(abs(da),turn/2);
}
direction += ta*sign(da);
image_angle = direction;
speed = curr_speed*(1-ta/(turn*global.TURN_DAMPENER));
if(ta >= turn*global.TURN_SPRITE_THRESHOLD){
    if(sign(da) == -1){
        image_index = 2;
    }
    else{
        image_index = 1;
    }
}
else{
    image_index = 0;
}
