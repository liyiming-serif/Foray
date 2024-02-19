///scr_c_hull_collide_with_obstacle()

//Set bounce direction based on collision
//Angle in = angle out
var surf_n, coll_a, max_coll_a;
surf_n = point_direction(other.x, other.y, x, y);
max_coll_a = global.MAX_COLLISION_ANGLE;
if(variable_instance_exists(other, "grid_pos")){
    switch(other.grid_pos){
        case 1:
            surf_n = 225;
            max_coll_a = global.MAX_CORNER_COLLISION_ANGLE;
            break;
        case 2:
            surf_n = 270; break;
        case 3:
            surf_n = 315;
            max_coll_a = global.MAX_CORNER_COLLISION_ANGLE;
            break;
        case 4:
            surf_n = 180; break;
        case 6:
            surf_n = 0; break;
        case 7:
            surf_n = 135;
            max_coll_a = global.MAX_CORNER_COLLISION_ANGLE;
            break;
        case 8:
            surf_n = 90; break;
        case 9:
            surf_n = 45;
            max_coll_a = global.MAX_CORNER_COLLISION_ANGLE;
            break;
    }
}
coll_a = clamp(
    angle_difference(surf_n, direction+180),
    -max_coll_a,
    max_coll_a);
direction = surf_n + coll_a;
move_outside_solid(surf_n, -1);

