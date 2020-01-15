#define scr_statbox_create
///scr_statbox_create(follow_id, opposing_id)
var fid = argument[0];
var oid = argument[1];
if(!scr_instance_exists(fid)||!scr_instance_exists(oid)||global.game_speed>=1
    ||fid.object_index==obj_player_avatar||oid.object_index==obj_player_avatar){
    return undefined;
}

//CONSTRUCTOR:
with(instance_create(fid.x,fid.y,obj_statbox)){
    follow_id = fid;
    opposing_id = oid;
    is_friendly = follow_id.is_friendly;
    
    //round display stats
    stat_speed = round(follow_id.display_speed);
    stat_turn = round(follow_id.display_turn);
    stat_dmg = round(follow_id.display_dmg);
    
    opp_stat_speed = round(opposing_id.display_speed);
    opp_stat_turn = round(opposing_id.display_turn);
    opp_stat_dmg = round(opposing_id.display_dmg);
    
    //sprites and animation
    if(!is_friendly){
        sprite_index = spr_statbox_enemy;
    }
    image_speed = 0.9;
    stat_image_speed = 0.5;
    stat_index = irandom(sprite_get_number(spr_stat_filled)-1);
    display_stats = false;
}

#define scr_statbox_move
///scr_statbox_move(dist_following, optimal_angle)

var dfp, oa, da, ret;
if (!scr_instance_exists(follow_id) ||
    !scr_instance_exists(opposing_id)){
    //statbox going to be destroyed next frame, return bogus value in meantime
    ret[0] = 0;
    ret[1] = 0;
    return ret;
}
dfp = argument[0]; //distance from plane this hud is tracking
oa = argument[1]; //optimal angle relative to stealing line
pa = point_direction(follow_id.x,follow_id.y,opposing_id.x,opposing_id.y);

//By default, try to position the hud at a certain angle away from the opposing plane.
//There's 2 possible angles...
var x1, x2, y1, y2, fin_x, fin_y;
x1 = follow_id.x+lengthdir_x(dfp,pa+oa); //possible angle 1: positive
y1 = follow_id.y+lengthdir_y(dfp,pa+oa);
x2 = follow_id.x+lengthdir_x(dfp,pa-oa); //possible angle 2: negative
y2 = follow_id.y+lengthdir_y(dfp,pa-oa);

//...pick the one that keeps bboxes the farthest away from the edge of the screen.
var bdist1, bdist2, fin_bdist, oa_dir;
bdist1 = scr_statbox_min_border(x1,y1);
bdist2 = scr_statbox_min_border(x2,y2);
if(bdist1[0]>bdist2[0]){
    fin_x = x1;
    fin_y = y1;
    fin_bdist = bdist1;
    oa_sign = 1;
}
else if(bdist1[0]<bdist2[0]){
    fin_x = x2;
    fin_y = y2;
    fin_bdist = bdist2;
    oa_sign = -1;
}
else{
    //tie breaker: compare bbox distances along the other dimension.
    if(bdist1[1]>bdist2[1]){
        fin_x = x1;
        fin_y = y1;
        fin_bdist = bdist1;
        oa_sign = 1;
    }
    else{
        fin_x = x2;
        fin_y = y2;
        fin_bdist = bdist2;
        oa_sign = -1;
    }
}

//If the statbox is still not fully within the screen,
//bend the optimal angle until it is.
while(fin_bdist[0]<0 && oa>45){
    oa -= 15;
    fin_x = follow_id.x+lengthdir_x(dfp,pa+oa_sign*oa);
    fin_y = follow_id.y+lengthdir_y(dfp,pa+oa_sign*oa);
    fin_bdist = scr_statbox_min_border(fin_x,fin_y);
}

//Can't bend the optimal angle anymore w. out blocking game elements;
//forcefully clamp the statbox position within the screen.
var vc = scr_view_current();
ret[0] = clamp(fin_x, view_xview[vc]+sprite_xoffset, view_xview[vc]+view_wview[vc]+sprite_xoffset-sprite_width);
ret[1] = clamp(fin_y, view_yview[vc]+sprite_yoffset, view_yview[vc]+view_hview[vc]+sprite_yoffset-sprite_height);
return ret;

#define scr_statbox_draw_gui
///scr_statbox_draw_gui()

var c_prev = draw_get_colour();

//Draw self
var d_pos, ds_pos, dt_pos;
d_pos = scr_game_to_gui(x,y);
ds_pos = scr_game_to_gui(x-8,y-13);
dt_pos = scr_game_to_gui(x-7,y-13);
draw_set_font(global.fnt_4mini);
draw_set_color(global.C_TEXT_LIGHT);
draw_set_valign(fa_middle);
draw_set_halign(fa_right);
draw_sprite(sprite_index,image_index,d_pos[0],d_pos[1]);

//Draw stats
if(display_stats){
    //draw "SP"
    draw_text(dt_pos[0],dt_pos[1]+sprite_get_height(spr_stat)*0,"SP");
    
    //draw "TURN"
    draw_text(dt_pos[0],dt_pos[1]+sprite_get_height(spr_stat)*1,"TURN");
    
    //draw "DMG"
    draw_text(dt_pos[0],dt_pos[1]+sprite_get_height(spr_stat)*2,"DMG");
    
    for(var i=1; i<=global.MAX_STATS; i++){
        //draw speed
        scr_stat_draw_gui(i,stat_speed,opp_stat_speed,ds_pos[0],ds_pos[1],0);
        
        //draw turn
        scr_stat_draw_gui(i,stat_turn,opp_stat_turn,ds_pos[0],ds_pos[1],1);
        
        //draw damage
        scr_stat_draw_gui(i,stat_dmg,opp_stat_dmg,ds_pos[0],ds_pos[1],2);
    }
}

draw_set_colour(c_prev);

#define scr_stat_draw_gui
///scr_stat_draw_gui(i, follow_stat, opposing_stat, x_anchor, y_anchor, row)
var i, fstat, ostat, xo, yo, row;
i = argument[0];
fstat = argument[1];
ostat = argument[2];
xo = argument[3];
yo = argument[4];
row = argument[5];

if(i>fstat){
    draw_sprite(spr_stat,stat_index,xo+i*sprite_get_width(spr_stat),yo+row*sprite_get_height(spr_stat));
}
else{
    if(follow_id==global.player_id || fstat==ostat){
        draw_sprite(spr_stat_filled,stat_index,xo+i*sprite_get_width(spr_stat),yo+row*sprite_get_height(spr_stat));
    }
    else if(fstat>ostat){
        draw_sprite(spr_stat_better,stat_index,xo+i*sprite_get_width(spr_stat),yo+row*sprite_get_height(spr_stat));
    }
    else if(fstat<ostat){
        draw_sprite(spr_stat_worse,stat_index,xo+i*sprite_get_width(spr_stat),yo+row*sprite_get_height(spr_stat));
    }
}

#define scr_statbox_min_border
///scr_statbox_min_border(xp,yp)
var xp, yp, top_d, bottom_d, left_d, right_d, vc;
xp = argument[0];
yp = argument[1];
vc = scr_view_current();
left_d = (xp-sprite_xoffset)-view_xview[vc];
right_d = (view_wview[vc]+view_xview[vc])-(xp-sprite_xoffset+sprite_width);
top_d = (yp-sprite_yoffset)-view_yview[vc];
bottom_d = (view_hview[vc]+view_yview[vc])-(yp-sprite_yoffset+sprite_height);

//optimized sort that only returns the 2 smallest elements
var min_x, min_y, ret;
min_x = min(left_d,right_d);
min_y = min(top_d,bottom_d);
ret[0] = min(min_x,min_y);
ret[1] = max(min_x,min_y);
return ret;

#define scr_statbox_advance_frame
///scr_statbox_advance_frame()
if (!scr_instance_exists(follow_id) ||
    !scr_instance_exists(opposing_id) ||
    (!follow_id.on_target && !opposing_id.on_target)){
    
    instance_destroy();
}

//Thank you GML for implementing fmod!
stat_index = (stat_index+stat_image_speed)%sprite_get_number(spr_stat_filled);
