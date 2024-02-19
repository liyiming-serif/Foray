///scr_c_hull_draw_hp_bar()

var amt, w, h, px, py, uipos, col;
amt = 100*hp/max_hp;
w = hp_bar_width;
h = global.HBAR_THICKNESS;
px = x-w/2;
py = y-sprite_yoffset-h;
uipos = scr_game_to_gui(px,py);
if(is_friendly){
    col = global.C_ALLY_HBAR;
}
else{
    col = global.C_ENEMY_HBAR;
}
draw_healthbar(uipos[0],uipos[1],uipos[0]+w,uipos[1]+h,
    amt,global.C_UI_BLACK,col,col,
    0,true,false);
