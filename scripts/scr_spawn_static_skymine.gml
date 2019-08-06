///scr_spawn_static_skymine()

var k, v;
scr_skymine_queue(irandom(room_width),irandom(room_height));

k = scr_spawn_static_skymine;
v = 8;

if(!ds_map_exists(global.seen_enemies,k)){
    ds_map_add(global.seen_enemies,k,v);
    global.spawn_weight += v;
}
