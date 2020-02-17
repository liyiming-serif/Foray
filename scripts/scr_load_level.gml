#define scr_load_level
///scr_load_level(name)
//Call only after you're at the level you want

var name = argument0;
global.next_level = "";
global.changing_levels = false;

//GC previous level if needed
if(global.curr_level_name!=name && global.curr_level_name!=""){
    ds_map_destroy(global.curr_level_data);
}

//Load level JSON if needed
if(global.curr_level_name==""){
    var f, raw;
    f = file_text_open_read(working_directory+"\"+name+".json");
    raw = "";
    while(!file_text_eof(f)){
        raw += file_text_read_string(f);
        file_text_readln(f);
    }
    file_text_close(f);
    global.curr_level_data = json_decode(raw);
    global.curr_level_name = name;
}
//Decode next rm
var rm, rm_w, rm_h;
rm = asset_get_index("rm_"+name);
//I hate GML so much.
rm_w = ds_map_find_value(global.curr_level_data,"width");
rm_h = ds_map_find_value(global.curr_level_data,"height");

//TODO: decode and generate level time line

//Reset camera position...
var cam_x, cam_y, coords;
coords = ds_map_find_value(global.curr_level_data,"cam_coords");
cam_x = ds_list_find_value(coords,0);
cam_y = ds_list_find_value(coords,1);
//...and clamp to room
if(window_get_fullscreen()){
    view_xview[0]=clamp(cam_x,0,rm_w-view_wview[0]);
    view_yview[0]=clamp(cam_y,0,rm_h-view_hview[0]);
}
else{
    view_xview[1]=clamp(cam_x,0,rm_w-view_wview[1]);
    view_yview[1]=clamp(cam_y,0,rm_h-view_hview[1]);
}


#define scr_set_level
///scr_set_level(name)
//Buffer a level change
global.next_level = argument0;

//reset room views?
view_xview[0]=0;
view_yview[0]=0;
view_xview[1]=0;
view_yview[1]=0;

//Reset parallax
global.tile_x = 0;
global.tile_y = 0;

//reset skymine spawn queues
ds_list_clear(global.skymine_queue);

//reset score
score = 0;

//magic number that has to do with tile refresh rate
obj_control.alarm[0] = 2;