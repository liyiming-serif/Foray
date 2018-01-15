#define scr_plane_create
///scr_plane_create(min_speed, max_speed, acc, turn)

//CONSTRUCTOR:
min_speed = argument0; //displayed as: speed
max_speed = argument1;
acc = argument2;
turn = argument3; //displayed as: turn

curr_speed = min_speed;
shoot_rate = 12;
shoot_counter = 0;
image_speed = 0;

#define scr_plane_point_turn
///scr_plane_point_turn(xtarget, ytarget)

//turn the plane towards a target
var pa = point_direction(x,y,argument0,argument1);
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

if(curr_speed - acc > min_speed){
    curr_speed -= acc;
}
else{
    curr_speed = min_speed;
}