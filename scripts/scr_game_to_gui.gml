///scr_game_to_gui(x_val,y_val)

//translate an xy point in game coords to GUI layer coords
var x_val = argument[0];
var y_val = argument[1];
var ret;

if(window_get_fullscreen()){
    ret[0] = x_val-view_xview[0];
    ret[1] = y_val-view_yview[0];
}
else{
    ret[0] = x_val-view_xview[1];
    ret[1] = y_val-view_yview[1];
}
return ret;
