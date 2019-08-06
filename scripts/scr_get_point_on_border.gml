///scr_get_point_on_border()

//pick a side to place the point
var p_side, rng, ret;

rng = irandom(room_height+room_width);
if(rng < room_width){
    //pick room_width
    if(irandom(2)<1){
        //top
        p_side = "top";
    }
    else{
        //bottom
        p_side = "bottom";
    }
}
else{
    //pick room_height
    if(irandom(2)<1){
        //left
        p_side = "left";
    }
    else{
        //right
        p_side = "right";
    }
}

//generate a random point along that side
if(p_side == "top" || p_side == "bottom"){
    rng = irandom(room_width);
    ret[0] = rng;
    if(p_side == "top"){
        ret[1] = 0;
    }
    else{
        ret[1] = room_height;
    }
}
else{
    rng = irandom(room_height);
    ret[1] = rng;
    if(p_side == "left"){
        ret[0] = 0;
    }
    else{
        ret[0] = room_width;
    }
}
return ret;
