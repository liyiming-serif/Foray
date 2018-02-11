/// scr_nearest_in_line(x2,y2,object,prec)
//
//  Credit to: xot
//  binary search on object closest to caller
//
//  Returns the instance id of an object colliding with a given line and
//  closest to the first point, or noone if no instance found.
//  The solution is found in log2(range) collision checks.
//
//      x1,y2       first point on collision line, real
//      x2,y2       second point on collision line, real
//      object      which objects to look for (or all), real
//      prec        if true, use precise collision checking, bool
//      notme       if true, ignore the calling instance, bool
//
/// GMLscripts.com/license
{
    var ox,oy,dx,dy,object,prec,sx,sy,inst,i;
    ox = x;
    oy = y;
    dx = argument0;
    dy = argument1;
    object = argument2;
    prec = argument3;
    sx = dx - ox;
    sy = dy - oy;
    inst = collision_line(ox,oy,dx,dy,object,prec,true);
    if (inst != noone) {
        while ((abs(sx) >= 1) || (abs(sy) >= 1)) {
            sx /= 2;
            sy /= 2;
            i = collision_line(ox,oy,dx,dy,object,prec,true);
            if (i) {
                dx -= sx;
                dy -= sy;
                inst = i;
            }else{
                dx += sx;
                dy += sy;
            }
        }
    }
    return inst;
}
