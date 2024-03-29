#define scr_set_level
///scr_set_level(name)
//Entry point for switching levels
//Note: because of how GM handles tiles, we wait 2 frames before actually changing
//rooms. This script only resets level variables and signals to obj_control to
//change levels.
 
global.next_level = argument0;

//reset room views
view_xview[0]=0;
view_yview[0]=0;

//clear particles
part_particles_clear(global.partsys);
part_particles_clear(global.partsys_ground);
part_particles_clear(global.partsys_depths);

//Reset parallax
global.tiles_x = 0;
global.tiles_y = 0;

//reset skymine spawn queues
ds_list_clear(global.skymine_queue);

//reset score and progress
score = 0;

//Signal: Wait 2 frames before actually changing rooms
obj_control.alarm[0] = 2;

#define scr_load_level
///scr_load_level(name)
//Called by obj_control when it receives a signal to change levels

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
var cam_x, cam_y, coords, vc;
coords = ds_map_find_value(global.curr_level_data,"cam_coords");
cam_x = ds_list_find_value(coords,0);
cam_y = ds_list_find_value(coords,1);
//...and clamp to room
vc = scr_view_current();
view_xview[vc]=clamp(cam_x,0,rm_w-view_wview[vc]);
view_yview[vc]=clamp(cam_y,0,rm_h-view_hview[vc]);
view_xprev = view_xview[vc];
view_yprev = view_yview[vc];