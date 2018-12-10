#define scr_plane_create
///scr_plane_create(model)

//SUPERCLASS CONSTRUCTOR: don't call directly
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
rt_modifier = modifier/256.0; //magic number for 256 max palettes
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
if(ta > turn*global.TURN_SPRITE_THRESHOLD){ //TODO: REFACTOR!
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
if (hitstun>0){
    if(object_index==obj_enemy && hp<=achy){ //apply hit flash with wedge flash
        angles_ref = shader_get_uniform(shader_wedge_hit_flash, "angles");
        origin_ref = shader_get_uniform(shader_wedge_hit_flash, "origin");
        sprite_uvs_ref = shader_get_uniform(shader_wedge_hit_flash, "sprite_uvs");
        onTarget_ref = shader_get_uniform(shader_wedge_hit_flash, "onTarget");
        
        shader_set(shader_wedge_hit_flash);
        shader_set_uniform_i(onTarget_ref, on_target);
        shader_set_uniform_f_array(angles_ref, angles);
        shader_set_uniform_f(origin_ref, sprite_get_xoffset(sprite_index)/sprite_get_width(sprite_index), sprite_get_yoffset(sprite_index)/sprite_get_width(sprite_index));
        var uvs = sprite_get_uvs(sprite_index,image_index);
        shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
        
        angles_ref = shader_get_uniform(shader_wedge_flash, "angles");
        origin_ref = shader_get_uniform(shader_wedge_flash, "origin");
        sprite_uvs_ref = shader_get_uniform(shader_wedge_flash, "sprite_uvs");
        onTarget_ref = shader_get_uniform(shader_wedge_flash, "onTarget");
    }
    else{ //apply hit flash
        shader_set(shader_hit_flash);
    }
}
else if (object_index==obj_enemy && hp<=achy && image_index%2!=0){ //apply wedge flash
    palette_ref = shader_get_sampler_index(shader_wedge_flash, "palette");
    row_ref = shader_get_uniform(shader_wedge_flash, "row");
    
    shader_set(shader_wedge_flash);
    texture_set_stage(palette_ref, global.palette_texture);
    shader_set_uniform_f(row_ref, rt_modifier);
    shader_set_uniform_i(onTarget_ref, on_target);
    shader_set_uniform_f_array(angles_ref, angles);
    shader_set_uniform_f(origin_ref, sprite_get_xoffset(sprite_index)/sprite_get_width(sprite_index), sprite_get_yoffset(sprite_index)/sprite_get_width(sprite_index));
    var uvs = sprite_get_uvs(sprite_index,image_index);
    shader_set_uniform_f(sprite_uvs_ref,uvs[0],uvs[3],1/(uvs[2]-uvs[0]),1/(uvs[1]-uvs[3]));
    
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
if(object_index==obj_enemy && hitstun<=0){
    on_target = 0;
}
invincibility = max(invincibility-1,0);

//start tint red coroutine if plane is unpiloted
if(!has_pilot){
    scr_plane_unpiloted();
}

//let buckling anim play naturally
if(object_index==obj_player && is_buckle){
    return undefined;
}

//advance frame
if(image_index>u_bound_frame && hp > 0){
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
    //check if hitting weakpoint (maybe apply reduced dmg?)
    if(object_index==obj_enemy && hp<=achy){
        var pa, ha, ir;
        pa = point_direction(x,y,other.x,other.y);
        ha = degtorad(angle_difference(pa,direction));
        if(angles[0]>angles[1]){
            ir = (ha >= angles[0]) || (ha < angles[1]);
        }
        else{
            ir = (ha >= angles[0]) && (ha < angles[1]);
        }
        if(ir){
            on_target = 1;
            //TODO: scale inversely with player's dmg stat so num shots is constant for each wpn
            achy_hp -= other.dmg;
            //destroy bullet and exit early
            instance_destroy(other);
            return undefined;
        }
    }
    
    //apply dmg + initiate death seq if hp <= 0
    hp -= other.dmg;
    if(hp <= 0){
        //reset tint and shaders
        if(object_index == obj_enemy){
            achy = hp-1;
        }
    
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
    
    //destroy bullet
    instance_destroy(other);
}

#define scr_plane_steal
///scr_plane_steal()

//create player plane
var new;

new = scr_player_create(x,y,direction,modifier);
new.is_buckle = true;
new.timeline_index = tl_commandeer_coroutine;
new.timeline_position = 24;
new.timeline_running = true;
new.sprite_index = spr_plane1_buckle;
new.image_index = 0;
new.invincibility = global.SPAWN_INVINCIBILITY*0.5;
if(object_index==obj_enemy) { //restore a bit of hp if stealing new plane
    new.invincibility = global.SPAWN_INVINCIBILITY;
    new.timeline_position = 0;
    new.hp = max(hp+max_hp*0.5, max_hp);
}

//destroy enemy plane
instance_destroy(self);

#define scr_plane_bail
///scr_plane_bail()

has_pilot=false;
alarm[10] = 0;

#define scr_plane_unpiloted
///scr_plane_unpiloted()

//tint red coroutine
if(round(rt_modifier*256.0)==mk.tint_red){
    rt_modifier = modifier/256.0;
    if(!has_pilot && hp>0){
        alarm[10] = global.TINT_RED_SPEED;
    }
}
else{
    rt_modifier = mk.tint_red/256.0;
    alarm[10] = global.TINT_RED_SPEED;
}
