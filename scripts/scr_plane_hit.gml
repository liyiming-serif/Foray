#define scr_plane_hit
///scr_plane_hit()

if(roll_invuln == 0){
    scr_ship_hit();
}

#define scr_plane_solid_hit
///scr_plane_solid_hit()

//Set bounce direction based on collision
var sfn, ca;
sfn = point_direction(other.x, other.y, x, y);
if(variable_instance_exists(other, "grid_pos")){
    switch(other.grid_pos){
        case 1:
            sfn = 225; break;
        case 2:
            sfn = 270; break;
        case 3:
            sfn = 315; break;
        case 4:
            sfn = 180; break;
        case 6:
            sfn = 0; break;
        case 7:
            sfn = 135; break;
        case 8:
            sfn = 90; break;
        case 9:
            sfn = 45; break;
    }
}
ca = angle_difference(direction,sfn+180);
direction = sfn + ca;
move_outside_solid(direction, -1);
