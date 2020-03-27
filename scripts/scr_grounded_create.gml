///scr_grounded_create(x,y,obj_ind)

//parent script for dynamically creating grounded objects
var xv = argument[0];
var yv = argument[1];
var obj = argument[2];

with(instance_create(xv,yv,obj)){
    is_dynamically_created = true;
}


