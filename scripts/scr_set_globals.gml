#define scr_set_globals
///scr_set_globals()

global.MUZZLE_FLASH_ALARM = 0;

scr_set_ui_consts();

#define scr_set_ui_consts
///scr_set_ui_consts()

/*UI CONSTANTS*/

//COLORS
global.C_UI_BLACK = make_color_rgb(27,54,73);
global.C_FLASH_WARN_NORM = scr_normalize_rgb(make_colour_rgb(255,222,33));
global.C_TEXT = make_colour_rgb(108,102,142);
global.C_TEXT_LIGHT = make_colour_rgb(235,255,140);
global.C_SHADOW = make_colour_rgb(3,61,84);
global.C_FLASH_RED = make_colour_rgb(219,24,69);
global.C_SMOKESCREEN = make_colour_rgb(64,64,134);
global.C_ENEMY_HBAR = make_colour_rgb(255,0,0);
global.C_ALLY_HBAR = make_colour_rgb(0,181,156);
//obsolete grey color
global.C_ENEMY_BACK_HBAR = make_colour_rgb(87,107,112);

global.STEAL_ARROW_ANIM_SPEED = 0.3;
global.STEAL_RETICLE_ANIM_SPEED = 0.1;
global.STEAL_RETICLE_AIM_ANIM_SPEED = 0.2;
global.STEAL_RETICLE_DOT_ANIM_SPEED = 0.1;
global.STEAL_RETICLE_ON_ANIM_SPEED = 0.2;
global.STEAL_SWEEP_ANIM_SPEED = 0.2;
global.STEAL_SWEEP_ON_ANIM_SPEED = 0.3;
global.TOOLTIP_NONE_ANIM_SPEED = 0.1;

global.TUTORIAL_FADE_IN_RATE = 0.02;
global.TUTORIAL_FOLLOW_DIST = 72;
global.TUTORIAL_SCREEN_POS = 2/5;

global.TOOLTIP_ANIM_SPEED = 0.4;

global.PLAYER_HBAR_OFFSET[0] = 8;
global.PLAYER_HBAR_OFFSET[1] = 0;
global.PLAYER_HBAR_ANIM_SPEED = 0.15;
global.PLAYER_HP_LOW_WARN = 0.3;

global.CITY_HIT_FLASH_ALPHA = 0.4;
global.CITY_HIT_SHAKE_DIST = 5;
global.CITY_HIT_SHAKE_TIME = 20;
global.CITY_WARNING_DURATION = room_speed*1.6;
global.CITY_WARNING_SENSITIVITY = 24;
global.CITY_WARNING_BORDER = 12;

global.HBAR_THICKNESS = 2;