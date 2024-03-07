///scr_plane_set_turn_state(state)

var ns = argument[0];

if(alarm[TURN_SPR_ALARM]<0 && turn_state!=ns){
    if(ns > turn_state){
        turn_state++;
    }
    else{
        turn_state--;
    }
    alarm[TURN_SPR_ALARM] = turn_speed;
}

