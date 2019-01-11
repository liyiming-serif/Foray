#define scr_plane_instantiate
///scr_plane_instantiate(model)

//SUPERCLASS CONSTRUCTOR: don't call directly
image_angle = direction;

modifier = argument0;
var mp = ds_list_find_value(global.MODELS, modifier);

max_hp = ds_map_find_value(mp,"max_hp"); //displayed as: hp
neutral_speed = ds_map_find_value(mp,"neutral_speed"); //displayed as: speed
min_speed = ds_map_find_value(mp,"min_speed");
max_speed = ds_map_find_value(mp,"max_speed");
turn = ds_map_find_value(mp,"turn"); //displayed as: turn

hp = max_hp;
curr_speed = neutral_speed;
is_braking = false;
has_pilot = true;

//animation
image_speed = 0.4;
neutral_frame = 0; //starting frames
right_frame = 16;
left_frame = 20;
l_bound_frame = neutral_frame; //upper and lower frame bounds
u_bound_frame = right_frame;

//palette swap shader
rt_modifier = modifier/256.0; //magic number for 256 max palettes
palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
row_ref = shader_get_uniform(shader_pal_swap, "row");

//wedge shader
angles = -1;
angles_ref = shader_get_uniform(shader_wedge_flash, "angles");
origin_ref = shader_get_uniform(shader_wedge_flash, "origin");
sprite_uvs_ref = shader_get_uniform(shader_wedge_flash, "sprite_uvs");
on_target = 0.0;
onTarget_ref = shader_get_uniform(shader_wedge_flash, "onTarget");

//hitstun and invincibility frames
hitstun = 0;
invincibility = 0;


#define scr_plane_point_turn
///scr_plane_point_turn(xtarget, ytarget, away, turn_modifier=1)

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

//Optional: apply a modifier w/out affecting 'turn' property.
if(argument_count==4){
    tm *= argument[3];
}

//actually turn plane, affecting direction.
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);
direction += ta*sign(da);
speed = curr_speed*(1-ta/(turn*global.TURN_DAMPENER)); //slow down based on turn angle

//drifting, affecting image_angle
if(is_braking && !(argument_count==4 && abs(argument[3])<1)){
    da = angle_difference(pa,image_angle);
    ta = min(abs(da),turn*global.DRIFT);
    image_angle += ta*sign(da);
}
else {
    var da2 = angle_difference(direction,image_angle);
    var ta2 = min(abs(da2),turn);
    image_angle += ta2*sign(da2);
}

//change sprite based on turn angle
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

#define scr_plane_idle
///scr_plane_idle()
//maybe refactor this, idk. copy-pasted from point_turn
var da2 = angle_difference(direction,image_angle);
var ta2 = min(abs(da2),turn);
image_angle += ta2*sign(da2);

#define scr_plane_boost
///scr_plane_boost()
is_braking = false;
curr_speed = clamp(curr_speed+global.ACC_SPEED,min_speed,max_speed);


#define scr_plane_brake
///scr_plane_brake()
is_braking = true;
curr_speed = clamp(curr_speed-global.BRAKE_SPEED,min_speed,max_speed);

#define scr_plane_neutral
///scr_plane_neutral()
is_braking = false;
if(curr_speed<neutral_speed){//too slow
    curr_speed = clamp(curr_speed+global.ACC_SPEED,min_speed,neutral_speed);
}
else if(curr_speed>neutral_speed){//too fast
    curr_speed = clamp(curr_speed-global.BRAKE_SPEED,neutral_speed,max_speed);
}
#define scr_plane_shade
///scr_plane_shade()

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
if (hitstun>0){
    if (is_array(angles) && image_index%3>1.5){ //apply hit wedge flash
        angles_ref = shader_get_uniform(shader_wedge_hit_flash, "angles");
        origin_ref = shader_get_uniform(shader_wedge_hit_flash, "origin");
        sprite_uvs_ref = shader_get_uniform(shader_wedge_hit_flash, "sprite_uvs");
        onTarget_ref = shader_get_uniform(shader_wedge_hit_flash, "onTarget");
        
        shader_set(shader_wedge_hit_flash);
        shader_set_uniform_f(onTarget_ref, on_target);
        shader_set_uniform_f_array(angles_ref, angles);
        shader_set_uniform_f(origin_ref, sprite_get_xoffset(sprite_index)/sprite_get_width(sprite_index), sprite_get_yoffset(sprite_index)/sprite_get_width(sprite_index));
        var uvs = sprite_get_uvs(sprite_index,image_index);
        shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
        
        angles_ref = shader_get_uniform(shader_wedge_flash, "angles");
        origin_ref = shader_get_uniform(shader_wedge_flash, "origin");
        sprite_uvs_ref = shader_get_uniform(shader_wedge_flash, "sprite_uvs");
        onTarget_ref = shader_get_uniform(shader_wedge_flash, "onTarget");
    }
    //apply hit flash
    shader_set(shader_hit_flash);
}
else if (is_array(angles) && image_index%3>1.5){ //apply wedge flash
    palette_ref = shader_get_sampler_index(shader_wedge_flash, "palette");
    row_ref = shader_get_uniform(shader_wedge_flash, "row");
    
    shader_set(shader_wedge_flash);
    shader_set_uniform_f(row_ref, rt_modifier);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(onTarget_ref, on_target);
    shader_set_uniform_f_array(angles_ref, angles);
    shader_set_uniform_f(origin_ref, sprite_get_xoffset(sprite_index)/sprite_get_width(sprite_index), sprite_get_yoffset(sprite_index)/sprite_get_width(sprite_index));
    var uvs = sprite_get_uvs(sprite_index,image_index);
    shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
    shader_set_uniform_f(global.isMeter_ref, 0.0);
    
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

//countdown hitstun and invincibility
hitstun = max(hitstun-1, 0);
invincibility = max(invincibility-1,0);

//advance frame
if(image_index>=u_bound_frame && hp > 0){
    image_index = l_bound_frame;
}
else if(image_index<l_bound_frame){
    image_index = l_bound_frame;
}

#define scr_plane_hit
///scr_plane_hit(isFriendly)
if(hp<=0) return undefined;

var isFriendly = argument0;

if(isFriendly!=other.isFriendly){

    if(invincibility>0){ //destroy bullet and exit early
        instance_destroy(other);
        return undefined;
    }    

    //spawn hit particle
    part_type_direction(global.hit1,other.direction,other.direction,0,0);
    part_type_orientation(global.hit1,0,0,0,0,true);
    part_particles_create(global.partsys,other.x,other.y,global.hit1,1);
    
    //flash white
    hitstun = other.dmg*room_speed/30;
    
    //apply dmg + initiate death seq if hp <= 0
    hp -= other.dmg;
    if(hp <= 0){
        //reset tint and shaders
        angles = -1;
    
        //set crash sprite
        sprite_index = spr_plane1_land;
        image_index = 0;
        l_bound_frame = 0;
        r_bound_frame = image_number+1;
        image_speed = 0.2;
        
        //set crash course
        direction += 2*random_range(-other.dmg, other.dmg);
        
        //stop other animation seqs
        alarm[11] = -1;
        
        //create explosion particle
        part_particles_create(global.partsys,x,y,global.boom_air,1);
    }
    
    //destroy bullet
    instance_destroy(other);
}

#define scr_plane_steal
///scr_plane_steal()

//Run the moment the player avatar's jump anim finishes and this plane
//becomes the active player.

//create player plane
var new = scr_player_create(x,y,direction,modifier,gid.key);
//play buckling animation for new plane
sprite_index = spr_plane1_buckle;
image_index = 0;
l_bound_frame = 0;
r_bound_frame = image_number+1;
//start tint green coroutine
new.timeline_index = tl_commandeer_coroutine;
new.timeline_position = 24;
new.timeline_running = true;
//invincibility during recovery frames
new.invincibility = global.SPAWN_INVINCIBILITY*0.5;
//inherit old plane's hp
new.hp = hp;
//restore a bit of hp and double invincibility frames if stealing new plane
if(object_index==obj_enemy) {
    new.invincibility = global.SPAWN_INVINCIBILITY;
    new.timeline_position = 0;
    new.hp = max(hp+max_hp*0.5, max_hp);
}

//destroy old commandeered plane
instance_destroy();

#define scr_plane_gen_weakspot
///scr_plane_gen_weakspot(starting_angle=random_range(-pi,pi))

var w;

//TODO: calculate width of angles based on model quality
w = pi;

//no arguments: starting angle based on rng
if(argument_count==0){
    angles[0] = random_range(-pi,pi);
}
else{ //starting angle tries to face player
    angles[0] = argument[0]-w/2;
    if(angles[0]<-pi){
        angles[0]+=2*pi;
    }
}
angles[1] = angles[0]+w;
if(angles[1]>pi){
    angles[1]-=2*pi;
}
#define scr_plane_shoot
///scr_plane_shoot(cb_type)

//wrapper around executing gid callbacks for reducing copied code
var cb, ret;
cb = argument0;
with(gid){
    switch(cb){
        case "on_click":
            ret = script_execute(on_click_cb);
            break;
        case "pressed":
            ret = script_execute(pressed_cb);
            break;
        case "on_release":
            ret = script_execute(on_release_cb);
            break;
    }
}
if(ret!=undefined){
    //change plane to shooting sprite
    sprite_index = spr_plane1_shoot;
    alarm[11] = gid.recoil;
}
return ret;

#define scr_plane_update_wpn
///scr_plane_update_wpn()

//Update weapon position and image angle. Call during the end step.
gid.image_angle = image_angle;

gid.x = x+lengthdir_x(20,image_angle);
gid.y = y+lengthdir_y(20,image_angle);
