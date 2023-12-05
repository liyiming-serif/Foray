///scr_c_hull_step()

//countdown hitstun and invuln
hitstun = max(hitstun-global.game_speed, 0);
invuln = max(invuln-global.game_speed,0);

sp_invuln = max(sp_invuln-global.game_speed,0);
solid_invuln = max(sp_invuln-global.game_speed,0);
