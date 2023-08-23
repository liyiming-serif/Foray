///scr_depths_particle_create(x, y, particle)

var px = argument[0];
var py = argument[1];
var part = argument[2];

part_particles_create(
    global.partsys_depths,
    px*global.PARALLAX_FACTOR_DEPTHS,
    py*global.PARALLAX_FACTOR_DEPTHS,
    part,
    1);
