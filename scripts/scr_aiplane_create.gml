#define scr_aiplane_create
///scr_aiplane_create(x, y, dir, model, wpn_name, foresight, nimbus, reflexes, max_rounds, tut, achy)
var xv = argument0;
var yv = argument1;
var dir = argument2;
var model = argument3;
var wpn_name = argument4;

//CONSTRUCTOR:
with(instance_create(xv,yv,obj_enemy)){
    scr_plane_instantiate(dir,model,wpn_name,false);
    
    //TODO: (1) refactor foresight, nimbus, and reflexes to a 'skill' arg
    //      (2) refactor foresight, reflexes to consider speed and turn
    //      (3) refactor nimbus and max_rounds to wpn properties
    foresight = argument5; //how far plane looks for avoiding obstacles
    nimbus = argument6; //distance before plane opens fire
    reflexes = argument7; //how fast plane switches out of AVOID state
    max_rounds = argument8; //rounds plane fires before reloading
    tut = argument9; //(t)arget (u)pdate (t)ime
    
    //Handicap AI
    turn *= global.AI_TURN_REDUC;
    neutral_speed *= global.AI_SPEED_REDUC;
    min_speed *= global.AI_SPEED_REDUC;
    max_speed *= global.AI_SPEED_REDUC;
    curr_speed = neutral_speed;
    max_hp = ceil(max_hp*global.AI_HP_REDUC);
    achy = ceil(argument10*max_hp); //hp threshold for commandeering
    achy += random_range(-achy*global.ACHY_VARIANCE,achy*global.ACHY_VARIANCE);
    hp = max_hp;
    
    //entry point for AI FSM
    target_id = global.player_id;
    alarm[9] = tut;
    ax = 0;
    ay = 0;
    sx = lengthdir_x(speed*foresight,direction);
    sy = lengthdir_y(speed*foresight,direction);
    state = ai_states.CHASING;
    rounds_left = max_rounds;
    
    return id;
}

#define scr_aiplane_navigate
///scr_aiplane_avoid(xtarget, ytarget, away)

//CALCULATES TRAJECTORY FOR AVOIDING OBSTACLES, THEN TURNS THE PLANE

//sensing obstacles
var i, adir;
i = collision_line(x,y,sx+x,sy+y,obj_ship_parent,false,true);
if(state != ai_states.AVOIDING){
    ax = 0;
    ay = 0;
}

//avoiding obstacles
if(i!=noone){
    adir = point_direction(i.x-x,i.y-y,sx,sy);
    ax = lengthdir_x(foresight,adir);
    ay = lengthdir_y(foresight,adir);
    state = ai_states.AVOIDING;
    if(!alarm[0]){
        alarm[0] = reflexes;
        //rounds_left = clamp(rounds_left+1,0,max_rounds);
    }
}
if(state == ai_states.AVOIDING){
    argument0 = x;
    argument1 = y;
}

scr_plane_point_turn(argument0+ax,argument1+ay,argument2);
sx = lengthdir_x(speed*foresight,direction);
sy = lengthdir_y(speed*foresight,direction);

#define scr_aiplane_shoot
///scr_aiplane_shoot()

if(state==ai_states.FIRING && scr_plane_shoot("pressed")!=undefined){
    //Decide to transition AI to 'reloading'
    rounds_left--;
    if(rounds_left<=0){
        rounds_left = max_rounds;
        state = ai_states.RELOADING;
        if(!alarm[1]){
            alarm[1] = room_speed*3;
        }
    }
}

#define scr_aiplane_aim
///scr_aiplane_aim()

///check player is within nimbus
var pd = point_distance(target_id.x,target_id.y,x,y);
if(pd<=nimbus){
    //check player is within shooting range
    var pa = point_direction(x,y,target_id.x,target_id.y);
    var da = abs(angle_difference(pa,direction));
    if(da <= 30){
        state = ai_states.FIRING;
    }
}

#define scr_aiplane_hit
///scr_aiplane_hit()

var php = hp;
scr_plane_hit(false);
if(hp<=achy && php>achy){     
    var pa = point_direction(x,y,global.player_id.x,global.player_id.y);
    scr_plane_gen_weakspot(degtorad(angle_difference(pa,image_angle)));
    //make it easier to aim
    turn *= global.AI_TURN_REDUC;
}