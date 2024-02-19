///scr_clear_data()
//destroy top level data map created from scr_load_data
ds_map_destroy(global.PLANES);
ds_map_destroy(global.SHIPS);
ds_map_destroy(global.WEAPONS);
ds_map_destroy(global.PROJECTILES);
ds_map_destroy(global.CLOAKS);
ds_map_destroy(global.DESIGN_PATTERNS);
ds_map_destroy(global.DEFAULT_SETTINGS);

