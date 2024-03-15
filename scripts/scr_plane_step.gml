#define scr_plane_step
///scr_plane_step()

///Update components
scr_c_loop("step");

//emit far contrail if boosting
trail_counter = min(trail_counter+1,global.TRAIL_RATE);
if(is_boosting && trail_counter>=global.TRAIL_RATE){
    var px, py;
    px = x+lengthdir_x(-32,image_angle);
    py = y+lengthdir_y(-32,image_angle);
    part_type_direction(global.trail_far,image_angle,image_angle,0,0);
    part_type_orientation(global.trail_far,0,0,0,0,true);
    part_type_speed(global.trail_far,speed,speed,0,0);
    part_particles_create(global.partsys,px,py,global.trail_far,1);
    trail_counter = 0;
}

//evaluate hp and produce dmg indicators
for(var i=array_length_1d(global.DMG_THRESHOLDS)-1; i>=0; i--;){
    if(smoke_counter<global.SMOKE_RATE){
        smoke_counter++;
        break;
    } //smoke not ready yet
    if(hp<max_hp*global.DMG_THRESHOLDS[i]){
        var px, py;
        px = x+irandom_range(-sprite_width/2,sprite_width/2);
        py = y+irandom_range(-sprite_height/2,sprite_height/2);
        part_type_direction(global.dmg_ind[i],image_angle,image_angle,0,0);
        part_type_orientation(global.dmg_ind[i],0,0,0,0,true);
        part_type_speed(global.dmg_ind[i],speed*0.6,speed*0.6,0,0);
        part_particles_create(global.partsys,px,py,global.dmg_ind[i],1);
        smoke_counter = 0;
        break;
    } //produce smoke particle
}

//charge stealing: reset charge progress when not aiming
if(global.AB_USE_CHARGE_STEAL && !locking_on){
    steal_progress = 0;
}

//rolling mechanics
if(is_rolling){
    scr_c_plane_engine_rolling();
}

//countdown rolling maneuver
roll_invuln = max(0, roll_invuln-global.game_speed);
roll_cool = max(0, roll_cool-global.game_speed);

scr_plane_advance_frame();

#define scr_plane_advance_frame
///scr_plane_advance_frame()

//Animation state controller
//NOTE: move anim properties to chassis comp if animation timings ever differ

switch(anim_state){
    case plane_anim_states.CRASH:
        sprite_index = spr_plane1_crash;
        image_speed = 0.2;
        l_bound_frame = 0;
        u_bound_frame = image_number;
        break;
    case plane_anim_states.ROLL:
        sprite_index = spr_plane1_roll;
        image_speed = 0.7;
        if(image_index>u_bound_frame){
            if(roll_invuln>0){
                l_bound_frame = roll_start_frame;
            }
            else{
                l_bound_frame = roll_end_frame;
                u_bound_frame = image_number;
            }
        }
        break;
    case plane_anim_states.SHAKE:
        scr_plane_set_sprite("shake");
        image_speed = 0.4;
        l_bound_frame = 0;
        u_bound_frame = image_number;
        break;
    case plane_anim_states.NORM:
        scr_plane_set_sprite();
        image_speed = 0.4;
        switch(turn_state){
            case plane_turn_states.NEUTRAL:
                l_bound_frame = 0;
                u_bound_frame = 3;
                break;
            case plane_turn_states.RIGHT_TURN:
                l_bound_frame = 4;
                u_bound_frame = 7;
                break;
            case plane_turn_states.LEFT_TURN:
                l_bound_frame = 8;
                u_bound_frame = 11;
                break;
            case plane_turn_states.RIGHT_DRIFT:
                l_bound_frame = 12;
                u_bound_frame = 15;
                break;
            case plane_turn_states.LEFT_DRIFT:
                l_bound_frame = 16;
                u_bound_frame = 19;
                break;
        }
        break;
}

//NOTE: bound frames are *inclusive*
if(image_index>u_bound_frame && hp > 0){
    image_index = l_bound_frame;
}
else if(image_index<l_bound_frame){
    image_index = l_bound_frame;
}

//draw depth control
if(is_rolling){
    depth = -2;
}
else{
    depth = 0;
}




