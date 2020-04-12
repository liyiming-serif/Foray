#define scr_grounded_create
///scr_grounded_create(x,y,obj_ind)

//parent script for dynamically creating grounded objects
var xv = argument[0];
var yv = argument[1];
var obj = argument[2];

with(instance_create(xv,yv,obj)){
    is_dynamically_created = true;
}



#define scr_grounded_on_create
///scr_grounded_on_create()
//call in grouded obj's creation event

if(!variable_instance_exists(id,"is_dynamically_created")){
    //created via room editor; move to true pos
    x = x/global.PARALLAX_FACTOR;
    y = y/global.PARALLAX_FACTOR;
}