#define scr_plane_create
///scr_plane_create(model)

//SUPERCLASS CONSTRUCTOR: don't call directly
var mp = ds_list_find_value(global.MODELS, argument0);

max_hp = ds_map_find_value(mp,"max_hp"); //displayed as: hp
neutral_speed = ds_map_find_value(mp,"neutral_speed"); //displayed as: speed
min_speed = ds_map_find_value(mp,"min_speed");
max_speed = ds_map_find_value(mp,"max_speed");
turn = ds_map_find_value(mp,"turn"); //displayed as: turn

hp = max_hp;
curr_speed = neutral_speed;
is_braking = false;
has_pilot = true;

//shooting (TODO: refactor)
shoot_rate = room_speed*0.2;
shoot_counter = 0;
shoot_variance = 5;
shoot_range = room_speed*0.8;

//animation
image_speed = 0.4;
neutral_frame = 0; //starting frames
right_frame = 16;
left_frame = 20;
l_bound_frame = neutral_frame; //upper and lower frame bounds
u_bound_frame = right_frame;

//palette swap shader
modifier = argument0/256.0; //magic number for 256 max palettes
palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
row_ref = shader_get_uniform(shader_pal_swap, "row");

//hitstun and invincibility frames
hitstun = 0;
invincibility = 0;


#define scr_plane_point_turn
///scr_plane_point_turn(xtarget, ytarget, away)

//turn the plane towards a target
var tm = (((global.ACC_DAMPENER*max_speed)-curr_speed)/((global.ACC_DAMPENER*max_speed)-min_speed))*turn; //(t)urn (m)odifier based on speed
if(argument2){
    var pa = point_direction(argument0,argument1,x,y);
    tm /= 2;
}
else{
    var pa = point_direction(x,y,argument0,argument1);
}
var da = angle_difference(pa,direction);
var ta = min(abs(da),tm);
direction += ta*sign(da);
speed = curr_speed*(1-ta/(turn*global.TURN_DAMPENER));

//drifting
if(is_braking){
    da = angle_difference(pa,image_angle);
    ta = min(abs(da),turn*global.DRIFT);
    image_angle += ta*sign(da);
}
else {
    var da2 = angle_difference(direction,image_angle);
    var ta2 = min(abs(da2),turn);
    image_angle += ta2*sign(da2);
}
if(ta > turn*global.TURN_SPRITE_THRESHOLD){
    if(sign(da) == 1){ //left turn
        l_bound_frame = left_frame;
        u_bound_frame = image_number;
    }
    else{ //right turn
        l_bound_frame = right_frame;
        u_bound_frame = left_frame;
    }
}
else{ //neutral
    l_bound_frame = neutral_frame;
    u_bound_frame = right_frame;
}

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
if (hitstun>0){ //apply hit flash shader
    shader_set(shader_hit_flash);
}
else if (object_index==obj_enemy && hp<=achy && image_index%2!=0){
    palette_ref = shader_get_sampler_index(shader_wedge_flash, "palette");
    row_ref = shader_get_uniform(shader_wedge_flash, "row");
    shader_set(shader_wedge_flash);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(row_ref, modifier);
    shader_set_uniform_f(angles_ref, 0.52, 1.6);
    var uvs = sprite_get_uvs(sprite_index,image_index);
    shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
    palette_ref = shader_get_sampler_index(shader_pal_swap, "palette");
    row_ref = shader_get_uniform(shader_pal_swap, "row");
}
else{ //apply palette swap shader
    shader_set(shader_pal_swap);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(row_ref, modifier); 
}
draw_self();
shader_reset();

#define scr_plane_advance_frame
///scr_plane_advance_frame()

if(image_index>u_bound_frame && hp > 0){
    image_index = l_bound_frame;
}
else if(image_index<l_bound_frame){
    image_index = l_bound_frame;
}

//countdown hitstun and invincibility
hitstun = max(hitstun-1, 0);
invincibility = max(invincibility-1,0);

#define scr_plane_hit
///scr_plane_hit(isFriendly)
if(hp<=0) return undefined;

var isFriendly = argument0;

if(invincibility <= 0 && isFriendly!=other.isFriendly){
    //flash white + apply damage
    hitstun = other.dmg*room_speed/24;
    hp -= other.dmg;
    
    //destroy bullet and spawn hit particle
    part_type_direction(global.hit1,other.direction,other.direction,0,0);
    part_type_orientation(global.hit1,0,0,0,0,true);
    part_particles_create(global.partsys,other.x,other.y,global.hit1,1);
    instance_destroy(other);
    
    //initiate death seq if hp <= 0
    if(hp <= 0){
        //set crash sprite
        sprite_index = spr_plane1_land;
        image_index = 0;
        l_bound_frame = 0;
        r_bound_frame = image_number+1;
        image_speed = 0.2;
        
        //set crash course
        direction += 2*random_range(-shoot_variance, shoot_variance);
        
        //stop other animation seqs
        alarm[11] = -1;
        
        //create explosion particle
        part_particles_create(global.partsys,x,y,global.boom_air,1);
    }
}