#define scr_load_data
///scr_load_data()
//Load datafiles json and set global data maps
//Must call scr_clear_data to gc maps from memory

global.PLANES = scr_decode_json("planes.json");
global.SHIPS = scr_decode_json("ships.json");
global.WEAPONS = scr_decode_json("weapons.json");
global.PROJECTILES = scr_decode_json("projectiles.json");
global.CLOAKS = scr_decode_json("cloaks.json");
global.DESIGN_PATTERNS = scr_decode_json("design_patterns.json");
global.DEFAULT_SETTINGS = scr_decode_json("default_settings.json");

//digest jsons
global.models = ds_map_find_value(global.PLANES, "models");
global.plane_engine_tiers = ds_map_find_value(global.PLANES, "plane_engine_tiers");
global.speeds = ds_map_find_value(global.plane_engine_tiers, "speeds");
global.turns = ds_map_find_value(global.plane_engine_tiers, "turns");
global.brake_speeds = ds_map_find_value(global.plane_engine_tiers, "brake_speeds");
global.boost_speeds = ds_map_find_value(global.plane_engine_tiers, "boost_speeds");
global.roll_speeds = ds_map_find_value(global.plane_engine_tiers, "roll_speeds");
global.roll_durations = ds_map_find_value(global.plane_engine_tiers, "roll_durations");
global.roll_cooldowns = ds_map_find_value(global.plane_engine_tiers, "roll_cooldowns");
global.turn_accels = ds_map_find_value(global.plane_engine_tiers, "turn_accels");
global.pilot_ai = ds_map_find_value(global.PLANES, "ai");
global.projectiles = ds_map_find_value(global.PROJECTILES, "projectiles");
global.bombs = ds_map_find_value(global.PROJECTILES, "bombs");
global.design_pattern_weights = ds_map_find_value(global.DESIGN_PATTERNS, "cb_weights");
global.wpn_weights = ds_map_find_value(global.DESIGN_PATTERNS, "wpn_weights");
//default settings
global.DEFAULT_CONTROLS = ds_map_find_value(global.DEFAULT_SETTINGS, "controls");
global.DEFAULT_GRAPHICS = ds_map_find_value(global.DEFAULT_SETTINGS, "graphics");
//NOTE: only default cloak available for now
global.equipped_cloak = ds_map_find_value(global.CLOAKS, "default");
global.steal_charge_rate = ds_map_find_value(global.equipped_cloak, "charge_rate_px");
global.steal_max_range = ds_map_find_value(global.equipped_cloak, "max_range");

#define scr_decode_json
///scr_decode_json(filename)
//returns decoded json as ds_map

var filename = argument[0];
var f = file_text_open_read(working_directory + "\" + filename);
var raw = "";
while(!file_text_eof(f)){
    raw += file_text_read_string(f);
    file_text_readln(f);
}
file_text_close(f);
return json_decode(raw);