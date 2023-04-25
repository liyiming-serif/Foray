///scr_plane_ui_get_angles(starting_angle_deg)

var w, midpt, res;

//TODO: calculate width of angles based on model quality
w = pi*0.8;
midpt = argument[0];

//constrain angles [-PI, PI]
res[0] = midpt-w/2;
if(res[0]<-pi){
    res[0]+=2*pi;
}

ui_angles[1] = midpt+w/2;
if(ui_angles[1]>pi){
    ui_angles[1]-=2*pi;
}
