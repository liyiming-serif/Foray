///scr_flame_plume_create(x,y,projectile_name,is_friendly)

var b = scr_projectile_create(argument[0],argument[1],argument[2],argument[3]);

var mp = ds_map_find_value(global.projectiles,argument[2]);
b.piercing_invincibility = ds_map_find_value(mp, "piercing_invincibility");
b.ttl = ds_map_find_value(mp, "ttl");

return b;
