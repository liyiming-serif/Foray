///scr_ground_particle_create(x, y, particle)

var px = argument[0];
var py = argument[1];
var part = argument[2];

part_particles_create(
    global.partsys_ground,
    px-global.tiles_x,
    py-global.tiles_y,
    part,
    1);
