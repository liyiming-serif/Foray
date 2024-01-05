#define scr_missile_navigate
///scr_missile_navigate()

//Retargeting if need...
if(!scr_instance_exists(target_id)){
    if(!script_execute(targeting_cb)){
        instance_destroy();
        return undefined;
    }
}

//STATELESS AVOIDANCE FUNCTION
//NEEDS: axy, foresight, avoid_arc
//TODO: make both avoid functions generic if more ship ai reuses logic

var tx = target_id.x;
var ty = target_id.y;

var pd, dd, sx, sy, i, adir, adiff, pa, da;

//clear detour route if avoidance state alarm not active
if(!alarm[global.AVOIDANCE_ALARM]){
    ax = 0;
    ay = 0;
}

//sensing obstacles
sx = lengthdir_x(speed*foresight,direction);
sy = lengthdir_y(speed*foresight,direction);
i = collision_line(x,y,sx+x,sy+y,obj_obstacle_parent,false,true);

//bombs crash into their opponent
if(i!=noone){
    if(variable_instance_exists(i,"is_friendly") && is_friendly!=i.is_friendly){
        i = noone;
    }
}

//don't dodge if obstacle is 1)moving away 2)too fast 3)not imminently close 4)rolling 
if(i!=noone){
    if(variable_instance_exists(i, "roll_invuln") && i.roll_invuln>0){
        i = noone;
    }
    else {
        if(i.speed>speed*0.5 && abs(angle_difference(i.direction,direction))<30.0){
            var l = distance_to_object(i);
            if(l>foresight*0.4){
                i = noone;
            }
        }
    }
}

//avoiding obstacles
if(i!=noone){
    //calculate avoidance trajectory
    adiff = angle_difference(direction,i.direction);
    if(i.speed<speed*0.5 || adiff==0 || adiff==180 || adiff==-180){
        //position-based
        pa = point_direction(x,y,i.x,i.y);
        da = angle_difference(pa,direction);
        adir = direction-sign(da)*90;
    }
    else{
        //velocity-based
        adir = direction+sign(adiff)*90;
    }
    ax = lengthdir_x(foresight,adir);
    ay = lengthdir_y(foresight,adir);
    if(!alarm[global.AVOIDANCE_ALARM]){
        alarm[global.AVOIDANCE_ALARM] = avoid_arc;
    }
}
if(alarm[global.AVOIDANCE_ALARM]){
    //swerving
    scr_missile_turn(x+ax, y+ay, global.SWERVE_TURN_MOD);
}
else{
    //normal flying
    scr_missile_turn(tx, ty, 1);
}


#define scr_missile_turn
///scr_missile_turn(x,y,turn_modifier=1)

//Generic script for turning ships towards a point,
//and whether to change image_angle to match dir
//Req inst variables: curr_speed, turn

var tx = argument[0];
var ty = argument[1];
var tm = turn;
var sm = curr_speed;

//Apply a flat turn multiplier so ships spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}
//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count > 2){
    tm *= argument[2];
}

var pa = point_direction(x,y,tx,ty);
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);

direction += global.game_speed*ta*sign(da);
direction = angle_difference(direction,0); //constrain angle values
speed = global.game_speed*sm;
image_angle = direction;

//sound
var gain = (1-(curr_speed-speed)/curr_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, clamp(gain,0,1));

#define scr_missile_destroy
///scr_missile_destroy()

//gc audio emitter
audio_emitter_free(engine_sound_emitter);

#define scr_missile_set_target
///scr_missile_set_target()
if(!variable_instance_exists(id,"target_sprite") || !scr_instance_exists(target_id)){
    return undefined;
}

var xcorn, ycorn;
xcorn = -target_id.sprite_xoffset;
ycorn = -target_id.sprite_yoffset;

target_sprite_xoff = irandom_range(xcorn,xcorn+sprite_get_width(target_id.sprite_index));
target_sprite_yoff = irandom_range(ycorn,ycorn+sprite_get_height(target_id.sprite_index));

//set global missile table
if(!ds_map_exists(global.missile_slots, object_get_name(object_index))){
    ds_map_add(global.missile_slots, object_get_name(object_index), ds_list_create());
}

#define scr_missile_draw_target
///scr_missile_draw_target()

if(!variable_instance_exists(id,"target_sprite") ||
    !variable_instance_exists(id,"target_sprite_ind") ||
    !variable_instance_exists(id,"target_sprite_xoff") ||
    !variable_instance_exists(id,"target_sprite_yoff") ||
    !variable_instance_exists(id,"warn_range") ||
    !ds_map_exists(global.missile_slots, object_get_name(object_index)) ||
    !scr_instance_exists(target_id)){
    
    return undefined;
}

var tpos, wr, can_draw_target, ml, nm, lp;

target_sprite_ind = (target_sprite_ind+0.4)%sprite_get_number(target_sprite);

//decide whether to draw warn target
can_draw_target = false;
wr = point_distance(x,y,target_id.x,target_id.y) > warn_range;
ml = global.missile_slots[? object_get_name(id.object_index)];
nm = ds_list_size(ml);
lp = ds_list_find_index(ml,id);
if(wr){
    if(nm < global.MAX_MISSILE_TARGETS || lp != -1){
        can_draw_target = true;
    }
}
//just entered warning range, add missile to table
if(can_draw_target && lp == -1){
    ds_list_add(global.missile_slots[? object_get_name(object_index)],id);
}
//just left warning range, remove missile from table
if(!can_draw_target && lp != -1){
    ds_list_delete(global.missile_slots[? object_get_name(object_index)], lp);
}

if(can_draw_target){
    tpos = scr_game_to_gui(target_id.x+target_sprite_xoff, target_id.y+target_sprite_yoff);
    draw_sprite(target_sprite,target_sprite_ind,tpos[0],tpos[1]);
}