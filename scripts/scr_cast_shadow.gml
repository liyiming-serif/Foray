///scr_cast_shadow(y_squash=1)

//Call right before drawing the actual object.
//FUTURE: shear the shadow for different times of the day

var y_squash = 1;
if(argument_count>0){
    y_squash = argument[0];
}

var xp, yp, dir;
dir = point_direction(global.VANISH_X,global.VANISH_Y,x,y);
xp = x + lengthdir_x(global.SHADOW_DIST, dir);
yp = y + lengthdir_y(global.SHADOW_DIST, dir);

shader_set(shader_cast_shadow);
draw_sprite_ext(sprite_index,image_index,xp,yp,global.PARALLAX_FACTOR,global.PARALLAX_FACTOR*y_squash,image_angle,0,1);
shader_reset();
