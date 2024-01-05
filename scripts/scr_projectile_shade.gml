///scr_projectile_shade()

//Decide which shader to use for this frame. CALL ONLY DURING DRAW EVENT
if(variable_instance_exists(id,modifier)){
    shader_set(shader_pal_swap);
    shader_set_uniform_f(row_ref, rt_modifier);
    texture_set_stage(palette_ref, global.palette_texture);
    draw_self();
    shader_reset();
}
else{
    draw_self();
}
