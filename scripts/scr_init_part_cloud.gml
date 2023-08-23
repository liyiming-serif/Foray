///scr_init_part_cloud()

for(var i = 1; i <= 7; i++){
    var cld_sp, cld_spr, cld_dist, cld_t;
    switch(i){
        case 2:
        case 5:
        case 6:
            cld_sp = 1;
            break;
        case 1:
        case 3:
        case 4:
        case 7:
            cld_sp = 0.5;
            break;
    }
    cld_spr = asset_get_index("eff_cloud_"+string(i));
    cld_dist = room_width*global.PARALLAX_FACTOR_DEPTHS+sprite_get_width(cld_spr); 
    cld_t = room_speed*cld_dist/cld_sp;
    
    part_clouds[i-1] = part_type_create();
    part_type_sprite(part_clouds[i-1], cld_spr, false, false, false);
    part_type_direction(part_clouds[i-1], 180, 180, 0, 0);
    //part_type_speed(part_clouds[i-1], cld_sp, cld_sp, 0, 0);
    part_type_life(part_clouds[i-1], cld_t, cld_t);
}
