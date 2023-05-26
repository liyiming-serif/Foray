#define scr_plane_ui_get_angles
///scr_plane_ui_get_angles(starting_angle_deg, offset_deg)

var w, midpt, start_a, offset, res;

//TODO: calculate width of angles based on model quality
w = pi*.8;
start_a = argument[0];
offset = argument[1];

midpt = start_a + offset;
if(midpt < -pi){
    midpt+=2*pi;
}
if(midpt > pi){
    midpt-=2*pi;
}

//constrain angles [-PI, PI]
res[0] = midpt-w/2;
if(res[0] < -pi){
    res[0]+=2*pi;
}

res[1] = res[0]+w;
if(res[1] > pi){
    res[1]-=2*pi;
}

return res;

#define scr_plane_ui_charge_to_rads
///scr_plane_ui_charge_to_rads(steal_progress)
//Given target plane's steal progress,
//return start + end angles for reticle shader in radians

var res, prog_to_rad;

prog_to_rad = argument[0]*2*pi;

res[0] = global.RET_PROG_STARTING_ANGLE_RAD;
res[1] = res[0] - prog_to_rad;
