#define scr_ai_pyro_fire
///scr_ai_pyro_fire()

if(state==plane_ai_states.FIRING && fuel>0){
    scr_plane_shoot("pressed");
    fuel = max(fuel-global.game_speed, 0);
    
    //Decide to transition AI to 'reloading'
    if(fuel<=0){
        can_fire = false;
        state = plane_ai_states.RELOADING;
        if(!alarm[refuel_state_alarm]){
            alarm[refuel_state_alarm] = ceil(max_fuel/refuel_speed);
        }
    }
}

#define scr_ai_pyro_aim
///scr_ai_pyro_aim()

if(scr_aiplane_aim()){
    can_fire = true;
}
