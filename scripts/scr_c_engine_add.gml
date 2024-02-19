///scr_c_engine_add(face_dir)

//decode json properties
//req: mp
//ADDS: neutral_speed, turn, curr_speed

var cmp = ds_map_find_value(mp, "c_engine");

face_dir = argument[0];
if(face_dir){
    image_angle = direction;
}
neutral_speed = ds_map_find_value(cmp, "speed");
turn = ds_map_find_value(cmp, "turn");
curr_speed = neutral_speed;

//audio
engine_sound_emitter = audio_emitter_create();
audio_emitter_falloff(engine_sound_emitter,
    global.SOUND_FALLOFF_REF_DIST,
    global.SOUND_FALLOFF_MAX_DIST,
    global.SOUND_FALLOFF_FACTOR);
    
scr_c_add("c_engine");
