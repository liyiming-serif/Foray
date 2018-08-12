#define scr_aiplane_create
///scr_aiplane_create(foresight, nimbus, reflexes, max_rounds)

//CONSTRUCTOR: MUST CALL PLANE CONSTRUCTOR FIRST
foresight = argument0;
nimbus = argument1;
reflexes = argument2;
max_rounds = argument3;

if(turn!=undefined){
    og_turn = turn;
    turn *= global.AI_TURN_REDUC;
}
if(neutral_speed!=undefined){
    og_neutral_speed = neutral_speed;
    og_min_speed = min_speed;
    og_max_speed = max_speed;
    
    neutral_speed *= global.AI_SPEED_REDUC;
    min_speed *= global.AI_SPEED_REDUC;
    max_speed *= global.AI_SPEED_REDUC;
    curr_speed = neutral_speed;
}

ax = 0;
ay = 0;
sx = lengthdir_x(speed*foresight,direction);
sy = lengthdir_y(speed*foresight,direction);
state = ai_states.chasing;
rounds_left = max_rounds;

#define scr_aiplane_navigate
///scr_aiplane_avoid(xtarget, ytarget, away)

//CALCULATES TRAJECTORY FOR AVOIDING OBSTACLES, THEN TURNS THE PLANE

//sensing obstacles
var i, adir;
i = collision_line(x,y,sx+x,sy+y,obj_ship_parent,false,true);
if(state != ai_states.avoiding){
    ax = 0;
    ay = 0;
}

//avoiding obstacles
if(i!=noone){
    adir = point_direction(i.x-x,i.y-y,sx,sy);
    ax = lengthdir_x(foresight,adir);
    ay = lengthdir_y(foresight,adir);
    state = ai_states.avoiding;
    //sprite_index = spr_plane3;
    turn = og_turn;
    if(!alarm[0]){
        alarm[0] = reflexes;
        //rounds_left = clamp(rounds_left+1,0,max_rounds);
    }
}
if(state == ai_states.avoiding){
    argument0 = x;
    argument1 = y;
}

scr_plane_point_turn(argument0+ax,argument1+ay,argument2);
sx = lengthdir_x(speed*foresight,direction);
sy = lengthdir_y(speed*foresight,direction);

#define scr_aiplane_shoot
///scr_aiplane_shoot()

if(state==ai_states.firing && scr_shoot(false)!=noone){
    rounds_left--;
    if(rounds_left<=0){
        rounds_left = max_rounds;
        state = ai_states.reloading;
        if(!alarm[1]){
            alarm[1] = room_speed*3;
        }
    }
}

#define scr_aiplane_aim
///scr_aiplane_aim()

///check player is within nimbus
var pd = point_distance(obj_player.x,obj_player.y,x,y);
if(pd<=nimbus){
    //check player is within shooting range
    var pa = point_direction(x,y,obj_player.x,obj_player.y);
    var da = abs(angle_difference(pa,direction));
    if(da <= 30){
        state = ai_states.firing;
    }
}