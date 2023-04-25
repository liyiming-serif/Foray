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
