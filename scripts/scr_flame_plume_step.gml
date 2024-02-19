///scr_flame_plume_step()

//reset xscale
var sd, rx, ry;
sd = sprite_get_width(sprite_index)-sprite_get_xoffset(sprite_index);
rx = x+lengthdir_x(sd,image_angle);
ry = y+lengthdir_y(sd,image_angle);
if(collision_line(x,y,rx,ry,obj_solid_parent,false,true)==noone){
    image_xscale = 1;
}

if(!alarm[flicker_alarm]){
    //create secondary effect: flame flicker
    var xp, yp, b;
    xp = x+lengthdir_x(88*image_xscale, image_angle);
    yp = y+lengthdir_y(88*image_xscale, image_angle);
    b = scr_instance_create(xp, yp, obj_flame_flicker, is_friendly);
    if(variable_instance_exists(id,"dmg_mod")){
        b.sp_dmg *= dmg_mod;
    }
    alarm[flicker_alarm] = flicker_frequency;
}

if(!alarm[smoke_alarm]){
    if(variable_instance_exists(id,"miss_part")){
        //create smoke (miss) particle
        part_type_orientation(miss_part,image_angle,image_angle,0,0,false);
        var xp, yp;
        xp = x+lengthdir_x(94*image_xscale, image_angle);
        yp = y+lengthdir_y(94*image_xscale, image_angle);
        part_particles_create(global.partsys,xp,yp,miss_part,1);
    }
    alarm[smoke_alarm] = smoke_frequency;
}
