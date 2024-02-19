///scr_c_add(c_name)

///add component metadata
c_name = argument[0];
if(!variable_instance_exists(id,"components")){
    components[0] = c_name;
}
else{
    var len = array_length_1d(components);
    components[len] = c_name;
}
