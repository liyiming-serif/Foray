#define scr_play_sound
///scr_play_sound(sound_id, x, y)

//plays a positional sound fx once
//randomizes the pitch, track-position(?), and gain to keep the sound from going stale
//TODO: can one falloff setting fit all?
var sound_id = argument[0];
var px = argument[1];
var py = argument[2];

var s;
s = audio_play_sound_at(sound_id,px,py,0,
    global.SOUND_FALLOFF_REF_DIST,
    global.SOUND_FALLOFF_MAX_DIST,
    global.SOUND_FALLOFF_FACTOR,false,0);
audio_sound_gain(s,1-random(global.SOUND_GAIN_VARIANCE),0);
audio_sound_pitch(s,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));
return s;

#define scr_play_sound_randomize
///scr_play_sound_randomize(sound_prefix, num_sounds, x, y)

//plays a positional sound fx once
//randomizes between different takes of the same sound
var sound_prefix = argument[0];
var num_sounds = argument[1];
var px = argument[2];
var py = argument[3];

var s, ind, sound_asset;
ind = irandom(num_sounds-1);
sound_asset = asset_get_index(sound_prefix+string(ind));
s = audio_play_sound_at(sound_asset,px,py,0,
    global.SOUND_FALLOFF_REF_DIST,
    global.SOUND_FALLOFF_MAX_DIST,
    global.SOUND_FALLOFF_FACTOR,false,0);
return s;

#define scr_play_sound_ui
///scr_play_sound_ui(sound_id)

//plays a sound fx once, regardless of position
//randomizes the pitch, track-position(?), and gain to keep the sound from going stale
var sound_id = argument[0];

var s;
s = audio_play_sound(sound_id,0,false);
audio_sound_gain(s,1-random(global.SOUND_GAIN_VARIANCE),0);
audio_sound_pitch(s,1+random_range(-global.SOUND_PITCH_VARIANCE,global.SOUND_PITCH_VARIANCE));
return s;
