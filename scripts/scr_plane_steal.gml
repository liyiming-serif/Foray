///scr_plane_steal()

//Runs from enemy's perspective the moment the player avatar's
//jump anim finishes. Turn this plane into player

//create player plane
var nw_plane = scr_player_create(x,y,direction,model_name);
nw_plane.speed = speed;
//play buckling animation for new plane
nw_plane.anim_state = plane_anim_states.SHAKE;
nw_plane.image_index = 0;
//start tint green coroutine
nw_plane.timeline_index = tl_steal_coroutine;
nw_plane.timeline_position = 24;
nw_plane.timeline_running = true;
//invuln during recovery frames
nw_plane.invuln = global.SPAWN_INVULN*0.5;
//inherit old plane's hp
nw_plane.hp = hp;
//restore a bit of hp and double invuln frames if stealing new plane
nw_plane.invuln = global.SPAWN_INVULN;
nw_plane.timeline_position = 0;
nw_plane.hp = min(hp+max_hp*0.7, max_hp);

//destroy old stolen plane
instance_destroy();
