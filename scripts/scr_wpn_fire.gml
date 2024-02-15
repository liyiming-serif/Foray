///scr_wpn_fire(gid, cb_type)

//helper func that wraps around executing gid callbacks
//CALL FROM SHIP/PLANE/ETC.
var g, cb, ret;
g = argument[0];
cb = argument[1];
ret = undefined;

with(g){
    switch(cb){
        case "on_click":
            ret = script_execute(on_click_cb);
            break;
        case "pressed":
            ret = script_execute(pressed_cb);
            break;
        case "on_release":
            ret = script_execute(on_release_cb);
            break;
    }
}

return ret;
