///scr_plane_crash()

//reset tint and shaders
angles = -1;

//set crash sprite
anim_state = plane_anim_states.CRASH;
image_index = 0;

//set crash course
direction += random_range(-10, 10);

//finish other animation seqs
alarm[SHOOT_FLASH_ALARM] = 0;


//create explosion particle
part_particles_create(global.partsys,x,y,global.boom_air,1);

//gc wpn only
scr_ship_gc_wpns();

//switch to crashing sound
audio_stop_sound(engine_sound);
scr_play_sound(snd_explosion_m,x,y);
crashing_sound = scr_play_sound(snd_falling,x,y);

