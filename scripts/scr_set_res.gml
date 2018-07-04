#define scr_set_res
///scr_set_res(zoom)
var zoom = round(argument0);
if(zoom<=0){ //fullscreen
    view_visible[1] = false;
    view_visible[0] = true;
    window_set_fullscreen(true);
    surface_resize(application_surface,display_get_width(),display_get_height());
}
else{
    view_visible[0] = false;
    view_visible[1] = true;
    window_set_fullscreen(false);
    window_set_size(global.IDEAL_WIDTH*zoom,global.IDEAL_HEIGHT*zoom);
    surface_resize(application_surface,global.IDEAL_WIDTH*zoom,global.IDEAL_HEIGHT*zoom);
}

#define scr_init_views
///scr_init_views()
//Can only be called once at the start because GM is weird

//Calculate the full screen pixel res
var display_width = display_get_width();
var display_height = display_get_height();
var xzoom = display_width div global.IDEAL_WIDTH;
var yzoom = display_height div global.IDEAL_HEIGHT;

//zoom by the smaller scale and fill remainder with peripheral vision
var pixel_width = round(display_width/min(xzoom,yzoom));
var pixel_height = round(display_height/min(xzoom,yzoom));

//check for odd numbers
if(pixel_width & 1)
    pixel_width++;
if(pixel_height & 1)
    pixel_height++;

//View[0] = fullscreen res
//View[1] = windowed res
for(var i=1; i<=room_last; i++)
{
  if(room_exists(i))
  {
    room_set_view(i,0,true,0,0,pixel_width,pixel_height,0,0,pixel_width,pixel_height,0,0,0,0,-1);
    room_set_view(i,1,false,0,0,global.IDEAL_WIDTH,global.IDEAL_HEIGHT,0,0,global.IDEAL_WIDTH,global.IDEAL_HEIGHT,0,0,0,0,-1);
    room_set_view_enabled(i,true);
  }
}