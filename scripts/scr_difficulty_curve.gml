#define scr_difficulty_curve
///scr_difficulty_curve(timeline_pos)
var t = argument[0];

//Generates a sine wave that constantly oscillates around a log function.
//This gives regularly occuring difficulty spikes that get less intense as the
//game goes on.
return clamp(sqrt(t)/110,0,1); //clamp((1.5*sin(t/150)+log2(t/5))/12,0,1);

#define scr_spawn_rate_curve
///scr_spawn_rate_curve(num_design_patterns)
var n = argument[0];

//modifies the base spawn rate by a linear factor of number of design patterns
return global.BASE_SPAWN_CHANCE * -0.09*(n-1)+1;