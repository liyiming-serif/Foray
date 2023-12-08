///scr_instance_create(x, y, obj, ...args)

arg_buff = undefined;
arg_len = argument_count - 3;

for(var i=0; i<arg_len; i++){
    arg_buff[i] = argument[i+3];
}
var o = instance_create(argument[0], argument[1], argument[2]);

arg_buff = undefined;
arg_len = undefined;
return o;
