#define scr_flame_plume_create
///scr_flame_plume_create(x,y,projectile_name,is_friendly)

var b = scr_projectile_create(argument[0],argument[1],argument[2],argument[3]);

var mp = ds_map_find_value(global.projectiles,argument[2]);
var opt = ds_map_find_value(mp,"optional");
b.piercing_invincibility = ds_map_find_value(opt, "piercing_invincibility");
b.linger = ds_map_find_value(opt, "linger");
b.flicker_frequency = ds_map_find_value(opt,"flicker_frequency");
b.smoke_frequency = ds_map_find_value(opt,"smoke_frequency");
b.miss_part = variable_global_get(ds_map_find_value(opt,"miss_part"));

return b;

#define scr_flame_plume_step
///scr_flame_plume_step()

if(!alarm[flicker_alarm]){
    //create flicker object
    var xp, yp, b;
    xp = x+lengthdir_x(88,image_angle);
    yp = y+lengthdir_y(88,image_angle);
    b = instance_create(xp, yp, obj_flame_flicker);
    b.is_friendly = is_friendly;
    alarm[flicker_alarm] = flicker_frequency;
}

if(!alarm[smoke_alarm]){
    if(variable_instance_exists(id,"miss_part")){
        //create smoke (miss) particle
        part_type_orientation(miss_part,image_angle,image_angle,0,0,false);
        var xp, yp;
        xp = x+lengthdir_x(94,image_angle);
        yp = y+lengthdir_y(94,image_angle);
        part_particles_create(global.partsys,xp,yp,miss_part,1);
    }
    alarm[smoke_alarm] = smoke_frequency;
}