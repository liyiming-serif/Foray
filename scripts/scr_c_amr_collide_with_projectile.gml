///scr_c_amr_collide_with_projectile()

if(is_friendly!=other.is_friendly){
    player_noticed = true;
    if(scr_instance_exists(aid) && scr_c_amr_is_up()){
        instance_destroy(other);
        part_particles_create(global.partsys,other.x,other.y,global.deflect,1);
        //deflected
        scr_play_sound_metallic(snd_deflect,x,y);
    }
    else{
        scr_c_hull_collide_with_projectile();
    }
}
