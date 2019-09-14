#define scr_player_create
///scr_player_create(x, y, dir, model_name, wpn_name)
var xv = argument0;
var yv = argument1;
var dir = argument2;
var model_name = argument3;
var wpn_name = argument4;

//PLAYER CONSTRUCTOR:
with(instance_create(xv,yv,obj_player)){
    scr_plane_instantiate(dir,model_name,wpn_name,true);

    global.player_id = id;
    obj_cursor.modifier = modifier; //update cursor color palette
    return id;
}

#define scr_player_bail
///scr_player_bail(target_id)
var tid = argument[0]

has_pilot=false;
tid.has_pilot = false; //target plane bails too

//play buckling animation for old plane
sprite_index = spr_plane1_buckle;
image_index = 0;
l_bound_frame = 0;
r_bound_frame = image_number+1;

//creation code for player avatar
with(instance_create(x,y,obj_player_avatar)){
    global.player_id = id;
    is_friendly = true;
    
    image_speed = 0.4;
    jump_frame = 3;
    land_frame = 9;

    pid = other.id;    
    target_id = tid;
    has_jumped = false;
    has_landed = false;
    
    if(target_id.y<y){
        sprite_index = spr_char_back;
    }
}

#define scr_player_contact_hit
///scr_player_contact_hit()

//HACK: continuous chip dmg if player is hitting an enemy ship

if(hp<=0 || invincibility > 0 || other.hp<=0) return undefined;

if(!other.is_friendly && !variable_instance_exists(other,"dmg")){
    var dmg = global.CONTACT_DMG;
    
    //Apply armor 
    if(variable_instance_exists(id,"amr")){
        dmg = max(dmg-amr,global.MIN_DMG);
    }
    
    //flash white
    hitstun = log2(dmg+1)*2.2;
    
    //apply screen flash
    if(id==global.player_id){
        global.flash_red_alpha += dmg/15;
    }
    
    //DIFFICULTY MOD: scale dmg down by spawn capacity
    dmg = max((1-global.spawn_cap*0.3)*dmg,global.MIN_DMG);
    
    //apply dmg + initiate death seq if hp <= 0
    hp -= dmg;
    if(hp <= 0){
        if(variable_instance_exists(id,"death_seq_cb")){
            script_execute(death_seq_cb);
        }
        else{
            instance_destroy();
        }
    }
    
    //apply invincibility
    invincibility += 15;
}