#define scr_any_stealables_in_view
///scr_any_stealables_in_view()

for(var i = 0; i < instance_number(obj_plane_parent); i++){
    var s = instance_find(obj_plane_parent,i);
    if(s.is_stealable && scr_is_stealable_in_view(s)){
        return true;
    }
}
return false;

#define scr_is_stealable_in_view
///scr_is_stealable_in_view(inst)

var i, buf, vc, rv, bv;

i = argument[0];
buf = 39;
vc = scr_view_current();
rv = view_xview[vc] + view_wview[vc];
bv = view_yview[vc] + view_hview[vc];

return point_in_rectangle(i.x, i.y,
    view_xview[vc]-buf, view_yview[vc]-buf, rv+buf, bv+buf);
    