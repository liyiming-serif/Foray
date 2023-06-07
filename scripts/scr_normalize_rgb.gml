///scr_normalize_rgb(color)

//Feed color to shader. Returns vec3
var n, c;
c = argument[0];
n[0] = colour_get_red(c)/255.0;
n[1] = colour_get_green(c)/255.0;
n[2] = colour_get_blue(c)/255.0;

return norm;
