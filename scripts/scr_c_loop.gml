///scr_c_loop(event_name)

var event = "_"+argument[0];

if(!variable_instance_exists(id,"components")){
    return undefined;
}

for(var i = 0; i < array_length_1d(components); i++){
    var scr = asset_get_index("scr_"+components[i]+event);
    if(scr != -1){
        script_execute(scr);
    }
}

