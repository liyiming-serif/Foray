///scr_plane_shoot(cb_type)

//TEMP: planes *cannot* shoot while rolling
if(is_rolling){
    return undefined;
}

//wrapper around executing gid callbacks for reducing copied code
var cb, ret;
cb = argument[0];
ret= scr_wpn_fire(gid,cb);
if(ret!=undefined){
    //change plane to flashing sprite
    scr_c_palette_flash(gid.recoil);
}
return ret;
