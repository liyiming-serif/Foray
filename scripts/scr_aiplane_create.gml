#define scr_aiplane_create
///scr_aiplane_create(x, y, dir, modifier, foresight, nimbus, reflexes, max_rounds, achy)

//CONSTRUCTOR:
with(instance_create(argument0,argument1,obj_enemy)){
    direction = argument2;
    scr_plane_create(argument3);

    foresight = argument4; //how far plane looks for avoiding obstacles
    nimbus = argument5; //distance before plane opens fire
    reflexes = argument6; //how fast plane switches AI states
    max_rounds = argument7; //rounds plane fires before reloading
    
    //Handicap AI
    og_turn = turn;
    turn *= global.AI_TURN_REDUC;

    og_neutral_speed = neutral_speed;
    og_min_speed = min_speed;
    og_max_speed = max_speed;
    neutral_speed *= global.AI_SPEED_REDUC;
    min_speed *= global.AI_SPEED_REDUC;
    max_speed *= global.AI_SPEED_REDUC;
    curr_speed = neutral_speed;
        
    og_max_hp = max_hp;
    max_hp = ceil(max_hp*global.AI_HP_REDUC);
    achy = ceil(argument8*max_hp);
    achy += random_range(-achy*global.ACHY_VARIANCE,achy*global.ACHY_VARIANCE);
    hp = max_hp;
    is_achy = false;
    
    //wedge shader
    angles_ref = shader_get_uniform(shader_wedge_flash, "angles");
    sprite_uvs_ref = shader_get_uniform(shader_wedge_flash, "sprite_uvs");
    
    //entry point for AI FSM
    ax = 0;
    ay = 0;
    sx = lengthdir_x(speed*foresight,direction);
    sy = lengthdir_y(speed*foresight,direction);
    state = ai_states.chasing;
    rounds_left = max_rounds;
}

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

if(state==ai_states.firing && scr_shoot(obj_bullet, shoot_variance, 7, shoot_range, 2, global.flare1, false)!=noone){
    //change plane to shooting sprite
    sprite_index = spr_plane1_shoot;
    alarm[11] = room_speed*0.1;

    //Decide to transition AI to 'reloading'
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
#define scr_aiplane_hit
///scr_aiplane_hit()

scr_plane_hit(false);
if(!is_achy && hp<=achy){
    
}