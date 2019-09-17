///scr_view_current()

//because the builtin view_current doesn't work
if(window_get_fullscreen()){
    return 0;
}
else{
    return 1;
}
