#define scr_ai_pyro_step
///scr_ai_pyro_step()
///Act based on AI FSM

if(hp<=0 || !has_pilot || !scr_instance_exists(target_id)){
    scr_c_plane_engine_idle();
    return undefined;
}

switch(state){
    case plane_ai_states.CHASING:
        scr_ai_pyro_aim();
    case plane_ai_states.FIRING:
        scr_ai_pyro_fire();
    case plane_ai_states.AVOIDING:
        if(can_fire){
            scr_ai_pyro_fire();
        }
        scr_aiplane_navigate(target_id.x,target_id.y);
        break;
    case plane_ai_states.RELOADING:
    case plane_ai_states.FLEEING:
        scr_aiplane_navigate(-target_id.x,-target_id.y,global.AI_FLEE_TURN_MOD);
        break;
}

if(state != plane_ai_states.FIRING){
    fuel = min(fuel+refuel_speed*global.game_speed, max_fuel);
}

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