///scr_is_obj_between_angles(player_obj, target_obj)
var pa, da, p, t;

p = argument[0];
t = argument[1];

pa = point_direction(t.x, t.y, p.x, p.y);
da = degtorad(angle_difference(pa, t.image_angle));
if(t.angles[0]>t.angles[1]){
    return (da >= t.angles[0]) || (da < t.angles[1]);
}
else{
    return (da >= t.angles[0]) && (da < t.angles[1]);
}
