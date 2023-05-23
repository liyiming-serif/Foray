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
display_turn = clamp(ds_map_find_value(mp,"turn"),1,global.MAX_STATS);
display_dmg = clamp(ds_map_find_value(mp,"dmg"),1,global.MAX_STATS);
display_amr = clamp(ds_map_find_value(mp,"amr"),1,global.MAX_STATS);
rolltime = ds_map_find_value(mp,"rolltime");
max_roll_cooldown = ds_map_find_value(mp, "roll_cooldown");

//translated primary stats
neutral_speed = scr_interpolate_stat(display_speed,global.speed_tiers);
turn = scr_interpolate_stat(display_turn,global.turn_tiers);
amr = scr_interpolate_stat(display_amr,global.amr_tiers);

//hidden stats
min_speed = scr_interpolate_stat(display_speed,global.min_speed_tiers);
max_speed = scr_interpolate_stat(display_speed,global.max_speed_tiers);
roll_speed = scr_interpolate_stat(display_speed,global.rolling_speed_tiers);
modifier = ds_map_find_value(mp,"palette");

//variable fields
hp = max_hp;
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

//charage-based stealing
is_stealable = false;
is_targeted = false;
steal_progress = 0;

//TODO: remove wedge shader
starting_angle = 0; //mid-point of angles
angles = -1;
angles_ref = shader_get_uniform(shader_wedge_flash, "angles");
origin_ref = shader_get_uniform(shader_wedge_flash, "origin");
sprite_uvs_ref = shader_get_uniform(shader_wedge_flash, "spriteUVs");
on_target = 0.0;
on_target_ref = shader_get_uniform(shader_wedge_flash, "onTarget");

//ui angle shader
steal_angles_ref = shader_get_uniform(shader_angle, "angles");
steal_origin_ref = shader_get_uniform(shader_angle, "origin");
steal_uvs_ref = shader_get_uniform(shader_angle, "spriteUVs");

//particle counters
smoke_counter = global.SMOKE_RATE;
trail_counter = global.TRAIL_RATE;

//GUI: stealing reticle, sweep, and arrow
reticle_img_ind = 0;
sweep_img_ind = 0;
arrow_img_ind = 0;

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


#define scr_plane_turn
///scr_plane_turn(xtarget, ytarget, away, turn_modifier=1)

//Turn the plane towards a target.
//Probably the most important script of the game.

//(t)urn (m)odifier based on speed

var tm = (((global.ACC_DAMPENER*max_speed)-curr_speed)/((global.ACC_DAMPENER*max_speed)-min_speed))*turn;

//Turn towards or away from target.
if(argument[2]){
    var pa = point_direction(argument[0],argument[1],x,y);
    tm /= 2; //MAGIC NUM; makes avoiding look better
}
else{
    var pa = point_direction(x,y,argument[0],argument[1]);
}

//Apply a flat multiplier so planes spend less time off-screen
if(scr_is_obj_outside_room()){
    tm *= global.TURN_OUTSIDE_ROOM_COEFF;
}

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count==4){
    tm *= argument[3];
}

//Set direction
var da, ta;
if(roll_invuln > 0){
    //strafing during rolling
    da = angle_difference(pa,direction);
    ta = min(abs(da),turn*global.ROLL_TURN);
    direction += global.game_speed*ta*sign(da);
}
else {
    da = angle_difference(pa,direction);
    ta = min(abs(da),tm);
    direction += global.game_speed*ta*sign(da);
}

//actually move the plane based on turn angle
speed = global.game_speed*curr_speed*(1-ta/(turn*global.TURN_DAMPENER));

//Set image angle
var pimg_angle, dimg_angle;
pimg_angle = angle_difference(image_angle, pa);
dimg_angle = angle_difference(image_angle, direction);
if(is_braking &&
    !(argument_count==4 && abs(argument[3])<1) &&
    curr_speed > neutral_speed){
    
    //drifting during break
    da = angle_difference(pa,image_angle);
    ta = min(abs(da),turn*global.DRIFT);
    image_angle += global.game_speed*ta*sign(da);
}
else if(sign(pimg_angle)!=sign(dimg_angle) &&
    pimg_angle!=0 &&
    dimg_angle!=0){
    //lock image angle until drift is finished
}
else if(roll_invuln > 0){
    //strafing, lock image angle
}
else {
    var da2 = angle_difference(direction,image_angle);
    var ta2 = min(abs(da2),turn);
    image_angle += global.game_speed*ta2*sign(da2);
}

//change sprite based on turn angle
if(!is_rolling && sprite_index != spr_plane1_buckle){
    if(ta > turn){
        if(sign(da) == 1){ //hard left turn
            l_bound_frame = left_frame;
            u_bound_frame = image_number;
        }
        else{ //hard right turn
            l_bound_frame = right_frame;
            u_bound_frame = left_frame;
        }
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
//maybe refactor this, idk. copy-pasted from point_turn
var da2 = angle_difference(direction,image_angle);
var ta2 = min(abs(da2),turn);
image_angle += global.game_speed*ta2*sign(da2);
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
if (hitstun>0){
    if (is_array(angles)){ //apply hit wedge flash
        angles_ref = shader_get_uniform(shader_wedge_hit_flash, "angles");
        origin_ref = shader_get_uniform(shader_wedge_hit_flash, "origin");
        sprite_uvs_ref = shader_get_uniform(shader_wedge_hit_flash, "spriteUVs");
        on_target_ref = shader_get_uniform(shader_wedge_hit_flash, "onTarget");
        
        shader_set(shader_wedge_hit_flash);
        shader_set_uniform_f(on_target_ref, on_target);
        shader_set_uniform_f_array(angles_ref, angles);
        var originx = sprite_get_xoffset(sprite_index)/sprite_get_width(sprite_index);
        var originy = sprite_get_yoffset(sprite_index)/sprite_get_height(sprite_index);
        shader_set_uniform_f(origin_ref, originx, originy);
        var uvs = sprite_get_uvs(sprite_index,image_index);
        shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
        
        angles_ref = shader_get_uniform(shader_wedge_flash, "angles");
        origin_ref = shader_get_uniform(shader_wedge_flash, "origin");
        sprite_uvs_ref = shader_get_uniform(shader_wedge_flash, "spriteUVs");
        on_target_ref = shader_get_uniform(shader_wedge_flash, "onTarget");
    }
    else{
        //apply hit flash
        shader_set(shader_hit_flash);
    }
}
else if (is_array(angles) && image_index%3>1.5){ //apply wedge flash
    palette_ref = shader_get_sampler_index(shader_wedge_flash, "palette");
    row_ref = shader_get_uniform(shader_wedge_flash, "row");
    
    shader_set(shader_wedge_flash);
    shader_set_uniform_f(row_ref, rt_modifier);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(on_target_ref, on_target);
    shader_set_uniform_f_array(angles_ref, angles);
    var originx = sprite_get_xoffset(sprite_index)/sprite_get_width(sprite_index);
    var originy = sprite_get_yoffset(sprite_index)/sprite_get_height(sprite_index);
    shader_set_uniform_f(origin_ref, originx, originy);
    var uvs = sprite_get_uvs(sprite_index,image_index);
    shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
    shader_set_uniform_f(global.is_meter_ref, 0.0);
    
    palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
    row_ref = shader_get_uniform(shader_pal_swap, "row");
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

//charge stealing: progress falloff when not targeted
if(!is_targeted){
    steal_progress = max(steal_progress-global.STEAL_CHARGE_FALLOFF, 0);
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
//invincibility during recovery frames
nw_plane.invincibility = global.SPAWN_INVINCIBILITY*0.5;
//inherit old plane's hp
nw_plane.hp = hp;
//restore a bit of hp and double invincibility frames if stealing new plane
switch(object_index){
    case obj_enemy:
    case obj_enemy_pyro:
        nw_plane.invincibility = global.SPAWN_INVINCIBILITY;
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

//TODO: delete this if charge stealing works out
is_stealable = true;
return 0;

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