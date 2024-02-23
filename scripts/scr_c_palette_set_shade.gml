///scr_c_palette_set_shade()
shader_set(shader_pal_swap);
texture_set_stage(palette_ref, global.palette_texture);
shader_set_uniform_f(row_ref, rt_modifier); 
