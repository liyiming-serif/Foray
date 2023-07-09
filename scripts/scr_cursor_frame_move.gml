///scr_cursor_frame_move()

var pd; //point direction between mouse and player

if(point_distance(global.player_id.x,global.player_id.y,mouse_x,mouse_y)>global.steal_max_range){
    pd = point_direction(global.player_id.x,global.player_id.y,mouse_x,mouse_y);
    x = global.player_id.x+lengthdir_x(global.steal_max_range,pd);
    y = global.player_id.y+lengthdir_y(global.steal_max_range,pd);
}
else{
    x = mouse_x;
    y = mouse_y;
}
