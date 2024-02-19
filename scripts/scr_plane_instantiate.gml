#define scr_plane_instantiate
///scr_plane_instantiate(dir, model_name, is_friendly, update_target_time=-1)

//SUPERCLASS CONSTRUCTOR: don't call directly
direction = argument[0];
var mp = ds_map_find_value(global.models, argument[1]);
key = argument[1];
if(argument_count==4){
    scr_ship_instantiate(argument[2],global.planes,argument[3]);
}
else{
    scr_ship_instantiate(argument[2],global.planes);
}

//orient the plane
image_angle = direction;

//params common to every model
max_hp = ds_map_find_value(global.planes,"max_hp");

//primary stats. These stats represent how many stars the player sees.
//Use the global lookup table to interpolate the in-game values these
//stats represent.
display_speed = clamp(ds_map_find_value(mp,"speed"),1,global.MAX_STATS);
display_turn = clamp(ds_map_find_value(mp,"base_turn"),1,global.MAX_STATS);
display_dmg = clamp(ds_map_find_value(mp,"dmg"),1,global.MAX_STATS);
rolltime = ds_map_find_value(mp,"rolltime");
max_roll_cooldown = ds_map_find_value(mp, "roll_cooldown");

//translated primary stats
neutral_speed = scr_interpolate_stat(display_speed,global.speed_tiers);
base_turn = scr_interpolate_stat(display_turn,global.base_turn_tiers);

//hidden stats
min_speed = scr_interpolate_stat(display_speed,global.min_speed_tiers);
max_speed = scr_interpolate_stat(display_speed,global.max_speed_tiers);
turn_accel = scr_interpolate_stat(ds_map_find_value(mp,"turn_accel"),global.turn_accel_tiers);
roll_speed = scr_interpolate_stat(display_speed,global.roll_speed_tiers);
modifier = ds_map_find_value(mp,"palette");

//variable fields
hp = max_hp;
turn = 0;
turn_d = 0;
curr_speed = neutral_speed;
is_braking = false;
is_boosting = false;
is_rolling = false;
has_pilot = true;
roll_invuln = 0;
roll_cooldown = 0;

//animation
idle_anim_speed = 0.4; //hardcoded values
roll_anim_speed = 0.7;
neutral_frame = 0;
right_frame = 16;
left_frame = 20;
roll_start_frame = 5;
roll_end_frame = 11;
image_speed = idle_anim_speed; //in-game bounds
l_bound_frame = neutral_frame; 
u_bound_frame = right_frame;

//palette swap shader
rt_modifier = modifier/256.0; //magic number for 256 max palettes
palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
row_ref = shader_get_uniform(shader_pal_swap, "row");
//flash shader
flash_color_ref = shader_get_uniform(shader_flash, "flashColor");

//stealing mechanic flags
is_stealable = false;
if(global.AB_USE_CHARGE_STEAL){
    is_targeted = false;
    steal_progress = 0;
}

if(global.AB_USE_ANGLE_STEAL){
    starting_angle = 0; //mid-point of angles
    angles = -1;
}
ready_to_steal = false;

//steal ui shaders
if(global.AB_USE_CHARGE_STEAL){
    steal_angles_ref = shader_get_uniform(shader_radial_bar, "angles");
    steal_origin_ref = shader_get_uniform(shader_radial_bar, "origin");
    steal_uvs_ref = shader_get_uniform(shader_radial_bar, "spriteUVs");
}
else if(global.AB_USE_ANGLE_STEAL){
    steal_angles_ref = shader_get_uniform(shader_angle, "angles");
    steal_origin_ref = shader_get_uniform(shader_angle, "origin");
    steal_uvs_ref = shader_get_uniform(shader_angle, "spriteUVs");
}

//particle counters
smoke_counter = global.SMOKE_RATE;
trail_counter = global.TRAIL_RATE;

//GUI: stealing reticle, sweep, and arrow
reticle_img_ind = 0;
reticle_scale = 1;
if(global.AB_USE_CHARGE_STEAL){
    reticle_on_img_ind = 0;
    reticle_aim_img_ind = 0;
    reticle_dot_img_ind = 0;
}
if(global.AB_USE_ANGLE_STEAL){
    sweep_img_ind = 0;
    arrow_img_ind = 0;
}

//arm the plane
wpn_name = ds_map_find_value(mp,"wpn");
gid = scr_wpn_create(x,y,direction,wpn_name,is_friendly,display_dmg);

//audio
if(is_friendly){
    engine_sound = audio_play_sound_on(engine_sound_emitter,snd_ambience,true,0);
}
else{
    engine_sound = audio_play_sound_on(engine_sound_emitter,snd_plane_engine,true,0);
}
audio_sound_pitch(engine_sound,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));


#define scr_plane_steer
///scr_plane_steer(xtarget, ytarget, turn_modifier=1)

//Steer (calculate turn) of the plane towards a target.

//Find target image angle + direction
var pa, da, da_d;
pa = point_direction(x,y,argument[0],argument[1]);
da = angle_difference(pa,image_angle);
da_d = angle_difference(pa,direction);

//Calculate turn acc modifiers
var tam;
if(roll_invuln > 0){
    tam = 1;
}
else{
    //normal flying, dampen turn acc based on speed
    tam = 1-global.TURN_ACC_DAMPENER*((curr_speed-min_speed)/(max_speed-min_speed));
}


//Calculate turn modifiers
var tm, tm_d;
tm = 1;
tm_d = 1;
//rolling turn boost
if(roll_invuln > 0){
    tm *= global.ROLL_TURN;
    tm_d *= global.ROLL_TURN;
}
else{
    //normal flying, dampen turn limit based on speed
    tm *= 1-global.TURN_DAMPENER*((curr_speed-min_speed)/(max_speed-min_speed));
    tm_d *= 1-global.TURN_DAMPENER*((curr_speed-min_speed)/(max_speed-min_speed));
}
//Apply a flat multiplier so planes spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
    tm_d *= global.TURN_OUTSIDE_ROOM_COEFF;
}
//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count==3){
    tm *= argument[2];
    tm_d *= argument[2];
}
//hairpin turns at low speeds + stabilization
var insta_turn = false;
if(turn<global.TURN_STABLE_THRESH*base_turn){
    insta_turn = true;
}
//Can drift - only affects image angle
if(is_braking){
    tm *= global.DRIFT;
    if(curr_speed > min_speed){
        insta_turn = true;
    }
}

//Boost after drifting to fly straight
if(is_boosting){
    tm_d *= global.STABILITY;
}

//Apply turn modifiers
var ideal_turn, max_turn;
max_turn = tm*base_turn;
ideal_turn = clamp(da,-max_turn,max_turn);
if(insta_turn){
    turn = ideal_turn;
}
else{
    turn = clamp(ideal_turn,
        turn-turn_accel*tam*global.game_speed,
        turn+turn_accel*tam*global.game_speed);
}

//Set image angle
if(roll_invuln > 0){
    //rolling, lock image angle
}
else {
    image_angle += global.game_speed*turn;
}
image_angle = angle_difference(image_angle, 0); //constrain angle values

//Set direction
var ideal_turn_d, max_turn_d;
max_turn_d = tm_d*base_turn;
ideal_turn_d = clamp(da_d,-max_turn_d,max_turn_d);
if(insta_turn){
    turn_d = ideal_turn_d;
}
else{
    turn_d = clamp(ideal_turn_d,
        turn_d-turn_accel*tam*global.game_speed,
        turn_d+turn_accel*tam*global.game_speed);
}
direction += global.game_speed*turn_d;
direction = angle_difference(direction,0); //constrain angle values


//Set speed
speed = global.game_speed*curr_speed*(1-abs(turn_d)/(base_turn*global.SPEED_DAMPENER));
    
//Change sprite based on turn img angle
if(!is_rolling && sprite_index != spr_plane1_buckle){
    if(turn > base_turn){
        //hard left turn
        l_bound_frame = left_frame;
        u_bound_frame = image_number;
    }
    else if(turn < -base_turn){
        //hard right turn
        l_bound_frame = right_frame;
        u_bound_frame = left_frame;
    }
    else{ //neutral
        l_bound_frame = neutral_frame;
        u_bound_frame = right_frame;
    }
}

//update sound emitter for doppler effect
if(is_friendly){
    var pitch = 1-((max_speed-curr_speed)/max_speed)*global.SOUND_PITCH_DAMPENER;
    audio_emitter_pitch(engine_sound_emitter, pitch);
}
var gain = (1-(max_speed-curr_speed)/max_speed)*(1-global.SOUND_GAIN_DAMPENER*global.spawn_cap);
audio_emitter_gain(engine_sound_emitter, gain);


#define scr_plane_idle
///scr_plane_idle()
//refactor this. copy-pasted from point_turn
var ideal_turn, da;
da = angle_difference(direction,image_angle);
ideal_turn = min(abs(da),base_turn)*sign(da);
turn = clamp(ideal_turn,
    turn-turn_accel*global.game_speed,
    turn+turn_accel*global.game_speed);
image_angle += global.game_speed*turn_d;
speed = global.game_speed*curr_speed;
audio_stop_sound(engine_sound);

#define scr_plane_boost
///scr_plane_boost()
if(!is_rolling){
    is_braking = false;
    is_boosting = true;
    curr_speed = clamp(curr_speed+global.ACC_SPEED,min_speed,max_speed);
}

#define scr_plane_brake
///scr_plane_brake()
if(!is_rolling){
    is_braking = true;
    is_boosting = false;
    curr_speed = clamp(curr_speed-global.BRAKE_SPEED,min_speed,max_speed);
}


#define scr_plane_neutral
///scr_plane_neutral()
if(!is_rolling){
    is_braking = false;
    is_boosting = false;
    if(curr_speed<neutral_speed){//too slow
        curr_speed = clamp(curr_speed+global.ACC_SPEED,min_speed,neutral_speed);
    }
    else if(curr_speed>neutral_speed){//too fast
        curr_speed = clamp(curr_speed-global.AIR_FRIC,neutral_speed,max_speed);
    }
}

#define scr_plane_shade
///scr_plane_shade()

//cast shadow
scr_cast_shadow();

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
if (is_stealable && image_index%3>1.5){ //apply red/warn flash
    if(global.AB_USE_CHARGE_STEAL && is_targeted){
        shader_set(shader_flash);
        shader_set_uniform_f_array(flash_color_ref, global.C_FLASH_WARN_NORM);
    }
    else{
        shader_set(shader_hurt_flash);
    }
}
else if (hitstun>0){ //apply white flash
    shader_set(shader_hit_flash);
}
else{ //apply palette swap shader
    shader_set(shader_pal_swap);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(row_ref, rt_modifier); 
}
draw_self();
shader_reset();

#define scr_plane_advance_frame
///scr_plane_advance_frame()

scr_ship_advance_frame();

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

//advance frame
if(image_index>=u_bound_frame && hp > 0){
    //special rolling conditions
    if(is_rolling){
        if(roll_invuln>0){
            l_bound_frame = roll_start_frame;
        }
        else{
            l_bound_frame = roll_end_frame;
            u_bound_frame = image_number;
        }
    }
    
    image_index = l_bound_frame;
}
else if(image_index<l_bound_frame){
    image_index = l_bound_frame;
}

//rolling mechanics
if(is_rolling){
    scr_plane_rolling();
}

//draw depth
if(is_rolling){
    depth = -2;
}
else{
    depth = 0;
}

//countdown rolling maneuver
roll_invuln = max(0, roll_invuln-global.game_speed);
roll_cooldown = max(0, roll_cooldown-global.game_speed);

//charge stealing: reset charge progress when not aiming
if(global.AB_USE_CHARGE_STEAL && !is_targeted){
    steal_progress = 0;
}


#define scr_plane_crash
///scr_plane_crash()

//reset tint and shaders
angles = -1;

//set crash sprite
sprite_index = spr_plane1_land;
image_index = 0;
l_bound_frame = 0;
u_bound_frame = image_number+1;
image_speed = 0.2;

//set crash course
direction += random_range(-10, 10);

//stop other animation seqs
alarm[11] = -1;

//create explosion particle
part_particles_create(global.partsys,x,y,global.boom_air,1);

//gc wpn only
scr_ship_gc_wpns();

//switch to crashing sound
audio_stop_sound(engine_sound);
scr_play_sound(snd_explosion_m,x,y);
crashing_sound = scr_play_sound(snd_falling,x,y);


#define scr_plane_steal
///scr_plane_steal()

//Run the moment the player avatar's jump anim finishes and this plane
//becomes the active player.

//create player plane
var nw_plane = scr_player_create(x,y,direction,key);
nw_plane.speed = speed;
//play buckling animation for new plane
nw_plane.sprite_index = spr_plane1_buckle;
nw_plane.image_index = 0;
nw_plane.l_bound_frame = 0;
nw_plane.u_bound_frame = nw_plane.image_number+1;
//start tint green coroutine
nw_plane.timeline_index = tl_steal_coroutine;
nw_plane.timeline_position = 24;
nw_plane.timeline_running = true;
//invuln during recovery frames
nw_plane.invuln = global.SPAWN_INVULN*0.5;
//inherit old plane's hp
nw_plane.hp = hp;
//restore a bit of hp and double invuln frames if stealing new plane
switch(object_index){
    case obj_enemy:
    case obj_enemy_pyro:
        nw_plane.invuln = global.SPAWN_INVULN;
        nw_plane.timeline_position = 0;
        nw_plane.hp = min(hp+max_hp*0.7, max_hp);
        break;
    default:
        break;
}

//destroy old stolen plane
instance_destroy();

#define scr_plane_gen_weakspot
///scr_plane_gen_weakspot(starting_angle, angle_variance=0)

is_stealable = true;
reticle_scale = 3;

if(global.AB_USE_ANGLE_STEAL){
    var w;
    
    //TODO: calculate width of angles based on model quality
    w = pi;
    
    starting_angle = argument[0];
    if(argument_count > 1){
        starting_angle += random_range(-argument[1], argument[1]);
    }
    
    angles[0] = starting_angle-w/2;
    if(angles[0]<-pi){
        angles[0]+=2*pi;
    }
    
    angles[1] = angles[0]+w;
    if(angles[1]>pi){
        angles[1]-=2*pi;
    }
}

#define scr_plane_shoot
///scr_plane_shoot(cb_type)

//TEMP: planes *cannot* shoot while rolling
if(is_rolling){
    return undefined;
}

//wrapper around executing gid callbacks for reducing copied code
var cb, ret;
cb = argument[0];
ret= scr_ship_shoot(gid,cb);
if(ret!=undefined){
    //change plane to shooting sprite
    sprite_index = spr_plane1_shoot;
    alarm[11] = gid.recoil;
}
return ret;

#define scr_plane_gc
//scr_plane_gc

scr_play_sound(snd_explosion_m,x,y);

//clean up all sounds under emitter
audio_stop_sound(engine_sound);
if(variable_instance_exists(id,"crashing_sound")){
    audio_stop_sound(crashing_sound);
}

//dispose function for all ships
scr_ship_gc();
