///scr_c_plane_engine_add()

//ADDS: speed_rank, turn_rank, turn_accel_rank, roll_duration_rank, roll_cooldown_rank
//neutral_speed, min_speed, max_speed, base_turn,
//curr_speed, turn, turn_d

var cmp = ds_map_find_value(mp,"c_plane_engine");

//Use the global lookup table to translate ranks to stats
speed_rank = ds_map_find_value(cmp,"speed_rank");
turn_rank = ds_map_find_value(cmp,"turns_rank");
turn_accel_rank = ds_map_find_value(cmp,"turn_accel_rank");
roll_duration_rank = ds_map_find_value(cmp,"roll_duration_rank");
roll_cooldown_rank = ds_map_find_value(cmp,"roll_cooldown_rank");

neutral_speed = scr_interpolate_stat(speed_rank,
    ds_map_find_value(global.plane_engine_tiers,"speeds"));
brake_speed = scr_interpolate_stat(speed_rank,
    ds_map_find_value(global.plane_engine_tiers,"brake_speeds"));
boost_speed = scr_interpolate_stat(speed_rank,
    ds_map_find_value(global.plane_engine_tiers,"boost_speeds"));
base_turn = scr_interpolate_stat(turn_rank,
    ds_map_find_value(global.plane_engine_tiers,"turns"));
turn_accel = scr_interpolate_stat(turn_accel_rank,
    ds_map_find_value(global.plane_engine_tiers,"turn_accels"));
roll_speed = scr_interpolate_stat(turn_rank,
    ds_map_find_value(global.plane_engine_tiers,"roll_speeds"));
roll_duration = scr_interpolate_stat(roll_duration_rank,
    ds_map_find_value(global.plane_engine_tiers,"roll_durations"));
roll_cooldown = scr_interpolate_stat(roll_cooldown_rank,
    ds_map_find_value(global.plane_engine_tiers,"roll_cooldowns"));

//variable fields
turn = 0;
turn_d = 0;
curr_speed = neutral_speed;
roll_invuln = 0;
roll_cool = 0;
is_braking = false;
is_boosting = false;
is_rolling = false;

//audio
engine_sound_emitter = audio_emitter_create();
audio_emitter_falloff(engine_sound_emitter,
    global.SOUND_FALLOFF_REF_DIST,
    global.SOUND_FALLOFF_MAX_DIST,
    global.SOUND_FALLOFF_FACTOR);
//TODO: change engine sound for player
if(is_friendly){
    engine_sound = audio_play_sound_on(engine_sound_emitter,snd_ambience,true,0);
}
else{
    engine_sound = audio_play_sound_on(engine_sound_emitter,snd_plane_engine,true,0);
}
audio_sound_pitch(engine_sound,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));

