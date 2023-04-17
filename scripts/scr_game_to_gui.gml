///scr_game_to_gui(x_val,y_val)

//translate an xy point in game coords to GUI layer coords
var x_val = argument[0];
var y_val = argument[1];

var ret;
ret[0] = x_val-view_xview[scr_view_current()];
ret[1] = y_val-view_yview[scr_view_current()];


return ret;
