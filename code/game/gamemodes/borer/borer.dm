/datum/game_mode
	var/list/datum/mind/borers = list()
	var/list/mob/living/simple_animal/captive_brain/brains = list()

/datum/game_mode/borers
	name = "Borers"
	config_tag = "borer"
	required_players = 5
	required_players_secret = 10
	required_enemies = 1
	recommended_enemies = 1

	uplink_welcome = "Borer Uplink Console:"
	uplink_uses = 0

	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/borers/announce()
	world << "<B>The current game mode is - Borers!</B>"
	world << "<B>OOC INFO: There is an \red Borer infestation \black on the station. You can't let them take over the station!</B>"
	world << "\red <B>OOC INFO: Borer mode is still in Beta! Please forgive any bugs and report them.</B>"


/datum/game_mode/borers/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0
	var/list/possible_borers = get_players_for_role(BE_ALIEN)
	if(possible_borers.len==0)
		return 0
	var/datum/mind/borer = pick(possible_borers)
	modePlayer += borer
	borer.assigned_role = "MODE" //So they aren't chosen for other jobs.
	borer.special_role = "Borer"
	borers += borer
	return 1


/datum/game_mode/borers/pre_setup()
	aliens_allowed = !aliens_allowed

//	spawn(rand(5000, 6000)) //Delayed announcements to keep the crew on their toes.
//		command_alert("Unidentified lifesign detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
//		for(var/mob/M in player_list)
//			M << sound('sound/AI/aliens.ogg')

	return 1

/datum/game_mode/borers/post_setup()
	var/list/startvents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in machines)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50) // Stops borers getting stuck in small networks. See: Security, Virology
				startvents += temp_vent

	for(var/datum/mind/borer in borers)
		greet_borer(borer)

	for(var/datum/mind/borer in borers)
		var/obj/startvent = pick(startvents)
		var/mob/living/simple_animal/borer/new_borer = new(startvent.loc)
		borer.current = new_borer
		new_borer.key = borer.key
		del(borer.original)
		borer.original = borer.current
//		world << "<B>DEBUG: borer: [borer]</B>"
//		world << "<B>DEBUG: borer KEY: [borer.key]</B>"

//		borers -= borer
		startvents -= startvent

	for(var/datum/mind/borer in borers)
		update_borer_icons_added(borer)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return



/datum/game_mode/proc/greet_borer(var/datum/mind/borer, var/you_are=1)
	if (you_are)
		borer.current << "<B>\red You are a Borer!</B>"
		borer.current << "Your goal is to take over the station by converting as many crew members to be borer loyal as possible, and only killing them if you have no other choice. You should reproduce when safe and hidden to create new borers."
		borer.current << "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>"
	return



/datum/game_mode/borers/check_finished()

	if(config.continous_rounds)
		return ..()

	var/borers_alive = 0
	for(var/datum/mind/borer in borers)
		if(!istype(borer.current,/mob/living/carbon))
			continue
		if(borer.current.stat==2)
			continue
		borers_alive++

	if (borers_alive)
		return ..()
	else
		finished = 1
		return 1



/datum/game_mode/borers/declare_completion()
	if(finished)
		feedback_set_details("round_end_result","loss - borers killed")
		world << "\red <FONT size = 3><B> The borer[(borers.len>1)?"s":""] ha[(borers.len>1)?"ve":"s"] been killed by the crew! The borers have been taught a lesson they will not soon forget!</B></FONT>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_borer()
	if(borers.len)
		var/text = "<FONT size = 2><B>The borers were:</B></FONT>"

		for(var/datum/mind/borer in borers)

			text += "<br>[borer.key] ("
			if(borer.current)
				if(borer.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(borer.current.real_name != borer.name)
					text += " as [borer.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
		world << text
	return 1

//OTHER PROCS
/datum/game_mode/proc/convert_thrall(datum/mind/host_mind)

	if(host_mind.special_role == "Borer")
		return 0

//	borers += host_mind
	host_mind.current << "\red <FONT size = 3> You feel something in your brain change! Help the cause of the Borers. Do not harm your fellow thralls or Borers. OOC: You can identify your allies by the alien face icons. Help the aliens in any way you can. You are truly loyal to them and them alone.</FONT>"
	host_mind.special_role = "Borer"
	update_all_borer_icons()
	return 1

/datum/game_mode/proc/update_all_borer_icons()
	spawn(15)
		for(var/datum/mind/theclient in ticker.minds)
			if(theclient.current)
				if(theclient.current.client)
					for(var/image/I in theclient.current.client.images)
						if(I.icon_state == "borer")
							del(I)

		for(var/datum/mind/borer in borers)
			if(borer.current)
				if(borer.current.client)
					for(var/datum/mind/borer_1 in borers)
						if(borer_1.current)
							var/I = image('code/game/gamemodes/borer/borerpic.dmi', loc = borer_1.current, icon_state = "borer")
							borer.current.client.images += I

		for(var/mob/living/simple_animal/captive_brain/capbrain in brains)
			if(capbrain.client)
				var/J = image('code/game/gamemodes/borer/borerpic.dmi', loc = capbrain.loc.loc, icon_state = "borer")
				capbrain.client.images += J


/datum/game_mode/proc/update_borer_icons_added(datum/mind/borer_mind)
	spawn(0)
		for(var/datum/mind/borer in borers)
			if(borer.current)
				if(borer.current.client)
					var/I = image('code/game/gamemodes/borer/borerpic.dmi', loc = borer_mind.current, icon_state = "borer")
					borer.current.client.images += I
			if(borer_mind.current)
				if(borer_mind.current.client)
					var/image/J = image('code/game/gamemodes/borer/borerpic.dmi', loc = borer.current, icon_state = "borer")
					borer_mind.current.client.images += J


/datum/game_mode/proc/update_borer_icons_removed(datum/mind/borer_mind)
	spawn(0)
		for(var/datum/mind/borer in borers)
			if(borer.current)
				if(borer.current.client)
					for(var/image/I in borer.current.client.images)
						if(I.icon_state == "borer" && I.loc == borer_mind.current)
							del(I)

		if(borer_mind.current)
			if(borer_mind.current.client)
				for(var/image/I in borer_mind.current.client.images)
					if(I.icon_state == "borer")
						del(I)