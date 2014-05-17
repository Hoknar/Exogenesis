/datum/game_mode
	var/list/datum/mind/aliens = list()

/datum/game_mode/aliens
	name = "Aliens"
	config_tag = "alien"
	required_players = 10
	required_players_secret = 10
	required_enemies = 1
	recommended_enemies = 1

	uplink_welcome = "Alien Uplink Console:"
	uplink_uses = 0

	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/aliens/announce()
	world << "<B>The current game mode is - Aliens!</B>"
	world << "<B>OOC INFO: There is an \red Alien infestation \black on the station. You can't let them take over the station!</B>"


/datum/game_mode/aliens/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0
	var/list/datum/mind/possible_aliens = get_players_for_role(BE_ALIEN)
	if(possible_aliens.len==0)
		return 0
	var/datum/mind/alien = pick(possible_aliens)
	aliens += alien
	modePlayer += alien
	alien.assigned_role = "MODE" //So they aren't chosen for other jobs.
	alien.special_role = "Alien"
	alien.original = alien.current
	return 1


/datum/game_mode/aliens/pre_setup()
	aliens_allowed = !aliens_allowed

	spawn(rand(5000, 6000)) //Delayed announcements to keep the crew on their toes.
		command_alert("Unidentified lifesign detected coming aboard [station_name()].", "Lifesign Alert")
		for(var/mob/M in player_list)
			M << sound('sound/AI/aliens.ogg')
	return 1

/datum/game_mode/aliens/post_setup()
	var/list/startvents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in machines)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50) // Stops Aliens getting stuck in small networks. See: Security, Virology
				startvents += temp_vent

	for(var/datum/mind/alien in aliens)
		greet_alien(alien)

	for(var/datum/mind/alien in aliens)
		var/obj/startvent = pick(startvents)

		var/mob/living/carbon/alien/larva/new_xeno = new(startvent.loc)
		new_xeno.key = alien.key
//		world << "<B>DEBUG: ALIEN: [alien]</B>"
//		world << "<B>DEBUG: ALIEN KEY: [alien.key]</B>"

//		aliens -= alien
		startvents -= startvent

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return



/datum/game_mode/proc/greet_alien(var/datum/mind/alien, var/you_are=1)
	if (you_are)
		alien.current << "<B>\red You are the Alien!</B>"
		alien.current << "Your goal is to take over the station by converting as many crew members as aliens as possible, and only killing them if you have no other choice."
		alien.current << "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>"
	return



/datum/game_mode/aliens/check_finished()

	if(config.continous_rounds)
		return ..()

	var/aliens_alive = 0
	for(var/datum/mind/alien in aliens)
		if(!istype(alien.current,/mob/living/carbon))
			continue
		if(alien.current.stat==2)
			continue
		aliens_alive++

	if (aliens_alive)
		return ..()
	else
		finished = 1
		return 1



/datum/game_mode/aliens/declare_completion()
	if(finished)
		feedback_set_details("round_end_result","loss - Aliens killed")
		world << "\red <FONT size = 3><B> The alien[(aliens.len>1)?"s":""] ha[(aliens.len>1)?"ve":"s"] been killed by the crew! The Aliens have been taught a lesson they will not soon forget!</B></FONT>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_alien()
	if(aliens.len)
		var/text = "<FONT size = 2><B>The aliens were:</B></FONT>"

		for(var/datum/mind/alien in aliens)

			text += "<br>[alien.key] ("
			if(alien.current)
				if(alien.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(alien.current.real_name != alien.name)
					text += " as [alien.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
		world << text
	return 1

//OTHER PROCS