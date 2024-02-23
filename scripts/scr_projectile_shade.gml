///scr_projectile_shade()

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
if(ds_map_exists(mp,"c_palette")){
    scr_c_palette_set_shade();
    draw_self();
    shader_reset();
}
else{
    draw_self();
}
