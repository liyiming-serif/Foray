///scr_city_hit(dmg)
var d = argument[0];

scr_city_warning_create();
global.flash_explosion_alpha = global.CITY_HIT_FLASH_ALPHA;
global.progress -= d;
global.screen_shake_dist = global.CITY_HIT_SHAKE_DIST;
global.screen_shake_time = global.CITY_HIT_SHAKE_TIME;

