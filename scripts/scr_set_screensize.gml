#define scr_set_screensize
///scr_set_screensize(zoom)
var rr, guir, tss;
show_debug_message("enemy count: "+string(global.spawn_cap));
tss = round(argument0);
if(tss<=0 || tss>3){ //fullscreen
    window_set_fullscreen(true);
    global.screensize = global.FULL_SCREENSIZE;
}
else{ //windowed
    window_set_fullscreen(false);
    window_set_size(global.IDEAL_WIDTH*tss,global.IDEAL_HEIGHT*tss);
    global.screensize = tss;
}
rr = min(global.resolution, global.screensize);
guir = min(global.GUI_RES, global.screensize);

surface_resize(application_surface, global.IDEAL_WIDTH, global.IDEAL_HEIGHT);
display_set_gui_size(global.IDEAL_WIDTH, global.IDEAL_HEIGHT);


#define scr_init_views
///scr_init_views()
//Set full screensize to the smaller width or height (remainder will be black)
//Initialize views (0=fullscreen, 1=windowed)
//NOTE: Can only be called once at the start because GM is weird

var dw, dh, xs, ys;

//Calculate the full screesize
dw = display_get_width();
dh = display_get_height();
xs = dw div global.IDEAL_WIDTH;
ys = dh div global.IDEAL_HEIGHT;

global.FULL_SCREENSIZE = min(xs, ys);

//Initialize view for each room
for(var i=1; i<=room_last; i++)
{
  if(room_exists(i))
  {
    room_set_view(i,0,true,
        0,0,global.IDEAL_WIDTH,global.IDEAL_HEIGHT,
        0,0,global.IDEAL_WIDTH,global.IDEAL_HEIGHT,
        0,0,0,0,-1);
    room_set_view_enabled(i,true);
  }
}
