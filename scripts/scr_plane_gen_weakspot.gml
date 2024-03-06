///scr_plane_gen_weakspot(starting_angle, angle_variance=0)

is_stealable = true;
reticle_scale = 3;

if(global.AB_USE_ANGLE_STEAL){
    var w;
    
    //TODO: calculate width of angles based on model quality
    w = pi;
    
    starting_angle = argument[0];
    if(argument_count > 1){
        starting_angle += random_range(-argument[1], argument[1]);
    }
    
    angles[0] = starting_angle-w/2;
    if(angles[0]<-pi){
        angles[0]+=2*pi;
    }
    
    angles[1] = angles[0]+w;
    if(angles[1]>pi){
        angles[1]-=2*pi;
    }
}
