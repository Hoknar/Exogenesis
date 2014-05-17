/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1
	luminosity = 2
	anchored = 1
	var/active = 0


/obj/machinery/gateway/initialize()
	update_icon()
	if(dir == 2)
		density = 0


/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
		return
	icon_state = "off"



//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = 1
	icon_state = "offcenter"
	use_power = 1

	//warping vars
	var/list/linked = list()
	var/ready = 0				//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null
	var/obj/machinery/computer/gateway/computer = null

/obj/machinery/gateway/centerstation/initialize()
	update_icon()
	wait = world.time + 0//config.gateway_delay	//+ thirty minutes default
	awaygate = locate(/obj/machinery/gateway/centeraway)


/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"



obj/machinery/gateway/centerstation/process()
	if(stat & (NOPOWER))
		if(active) toggleoff()
		return

	if(active)
		use_power(5000)


/obj/machinery/gateway/centerstation/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked.len == 8)
		ready = 1


/obj/machinery/gateway/centerstation/proc/toggleon(mob/user as mob)
	if(!ready)			return
	if(linked.len != 8)	return
	if(!powered())		return
	if(!awaygate)
		user << "<span class='notice'>Error: No destination found.</span>"
		return
	if(world.time < wait)
		user << "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()


/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()


/obj/machinery/gateway/centerstation/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
//	if(!active)
//		toggleon(user)
//		return
//	toggleoff()


//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/X as mob|obj)

	if(!ready)		return
	if(!active)		return
	if(!awaygate)	return
	if(awaygate.calibrated)
		if(istype(X, /obj))
			var/obj/C = X
			C.loc = get_step(awaygate.loc, SOUTH)
			C.dir = SOUTH
			use_power(2500)
			return
		else
			var/mob/M = X
			M.loc = get_step(awaygate.loc, SOUTH)
			M.dir = SOUTH
			M.Weaken(1)
			use_power(5000)
	return


/obj/machinery/gateway/centerstation/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		detect()
		user << "\black The machine whirs slightly as it runs it's dections."
		return

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = 1
	icon_state = "offcenter"
	use_power = 0
	var/calibrated = 1
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0
	var/obj/machinery/gateway/centeraway/stationgate = null
	var/obj/machinery/computer/gateway/computer = null

	centcom
		name = "CentCom"
		var/blocked = 1
	exile
		name = "Exile"

/obj/machinery/gateway/centeraway/initialize()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation)


/obj/machinery/gateway/centeraway/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"


/obj/machinery/gateway/centeraway/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked.len == 8)
		ready = 1


/obj/machinery/gateway/centeraway/proc/toggleon(mob/user as mob)
	if(!ready)			return
	if(linked.len != 8)	return
	if(!stationgate)
		user << "<span class='notice'>Error: No destination found.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()


/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()


/obj/machinery/gateway/centeraway/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		if(istype(src, /obj/machinery/gateway/centeraway/centcom))
			return
		toggleon(user)
		return
	toggleoff()


/obj/machinery/gateway/centeraway/Bumped(atom/movable/X as mob|obj)
	if(!ready)	return
	if(!active)	return
	if(istype(X, /mob/living/carbon))
		for(var/obj/item/weapon/implant/exile/E in X)//Checking that there is an exile implant in the contents
			if(E.imp_in == X)//Checking that it's actually implanted vs just in their pocket
				X << "\black The station gate has detected your exile implant and is blocking your entry."
				return
	if(istype(X, /obj))
		var/obj/C = X
		C.loc = get_step(stationgate.loc, SOUTH)
		C.dir = SOUTH
		return
	else
		var/mob/M = X
		M.loc = get_step(stationgate.loc, SOUTH)
		M.dir = SOUTH
		M.Weaken(1)
	return


/obj/machinery/gateway/centeraway/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		if(calibrated)
			user << "\black The gate is already calibrated, there is no work for you to do here."
			return
		else
			user << "\blue <b>Recalibration successful!</b>: \black This gate's systems have been fine tuned.  Travel to this gate will now be on target."
			initialize()
			detect()
			calibrated = 1
			return


/////////////////////////////////////Control Computer////////////////////////

/obj/machinery/computer/gateway
	name = "\improper Gateway Control Console"
	desc = "Used to control the experimental Gateway."
	icon_state = "teleport"
	var/obj/machinery/gateway/centerstation/station = null
	var/obj/machinery/gateway/centeraway/dest = null
	var/obj/machinery/gateway/centeraway/lastdest = null
	var/temp_msg = "Gateway control console initialized.<BR>Welcome."

	// VARIABLES //

	var/connected = 0
	var/gateway_cooldown = 0

	var/list/obj/machinery/gateway/centeraway/gate_options[1]
	var/obj/machinery/gateway/centeraway/centcom/centgate = null

	// This is the list of awaygates


/obj/machinery/computer/gateway/New()
	..()
	link_gateway()
	recalibrate()

/obj/machinery/computer/gateway/Del()
	..()

/obj/machinery/computer/gateway/examine()
	..()
	usr << "It probably controls that huge thing over there..."

/obj/machinery/computer/gateway/initialize()
	..()
	link_gateway()


/obj/machinery/computer/gateway/proc/link_gateway()
	station = locate() in range(src, 7)
	centgate = locate(/obj/machinery/gateway/centeraway/centcom)

/obj/machinery/computer/gateway/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/gateway/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/gateway/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		user << "Recalibrating..."
		link_gateway()
		recalibrate()
	else
		..()

/obj/machinery/computer/gateway/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/gateway/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/gateway/interact(mob/user)
	user.machine = src
	in_use = 1

	var/t = "<div class='statusDisplay'>[temp_msg]</div><BR>"

	// Current Destination
	t += "<BR><div class='statusDisplay'>"
	if(!dest)
		t += "No destination locked in."
	else
		t += "Destination Locked In: [dest]<BR>"
	t += "</div>"

	t += "<div class='statusDisplay'>"
	if(centgate)
		if(centgate.blocked)
			t += "<span class='linkOff'>[centgate] - Locked<br></span>"
		else
			t += "<A href='?src=\ref[src];setdest=cent'>[centgate]</A><br>"
	for(var/i = 1; i <= gate_options.len; i++)
		t += "<A href='?src=\ref[src];setdest=[i]'>[gate_options[i]]</A><br>"
	t += "</div>"

	t += "<BR><A href='?src=\ref[src];open=1'>Open Gate</A>"
	t += " <A href='?src=\ref[src];close=1'>Close Gate</A>"
	t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Destinations</A>"

	// Information about the last teleport
	t += "<BR><div class='statusDisplay'>"
	if(!lastdest)
		t += "No last destination data found."
	else
		t += "Last Destination: [lastdest]<BR>"
	t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/gateway/proc/sparks()
	if(station)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(station))
		s.start()
	else
		return

/obj/machinery/computer/gateway/proc/gatefail()
	sparks()
	visible_message("<span class='warning'>The gateway fizzles.</span>")
	return

/obj/machinery/computer/gateway/proc/opengate(mob/user)

	if(gateway_cooldown > world.time)
		temp_msg = "Gateway is recharging.<BR>Please wait [round((gateway_cooldown - world.time) / 10)] seconds."
		return

	if(connected)
		temp_msg = "Gateway is allready connected.<BR>Please close gate first."
		return

	if(station)

		station.detect()
		if(!station.ready)
			temp_msg = "Gateway is not ready."
			return

		if(!station.powered())
			temp_msg = "Gateway is not powered."
			return

		if(!station.awaygate)
			temp_msg = "Gateway has no destination."
			return

		if(world.time < station.wait)
			temp_msg = "Error: Warpspace triangulation in progress. Estimated time to completion: [round(((station.wait - world.time) / 10) / 60)] minutes."
			return

		lastdest = dest

		playsound(station.loc, 'sound/weapons/flash.ogg', 25, 1)
		sparks()

		temp_msg = "Attempting to open gate."


		spawn(30) // 3 seconds
			if(!station)
				return
			if(station.stat & NOPOWER)
				return

			gateway_cooldown = world.time + (120 * 10)

			// use a lot of power
			use_power(5000)

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, get_turf(station))
			s.start()


			station.toggleon(user)
			connected=1
			temp_msg = "Gateway Open.<BR>"

			var/sparks = get_turf(dest)
			var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
			y.set_up(5, 1, sparks)
			y.start()

			playsound(station.loc, 'sound/weapons/emitter2.ogg', 25, 1)

			updateDialog()

/obj/machinery/computer/gateway/proc/open(mob/user)
	if(dest == null)
		temp_msg = "ERROR!<BR>Set a destination."
		return
	else
		opengate(user)
	return

/obj/machinery/computer/gateway/Topic(href, href_list)
	if(..())
		return
	if(href_list["setdest"])
		var/index = href_list["setdest"]
		if(index == "cent")
			dest = centgate
			station.awaygate = dest
		else
			index = text2num(index)
			if(index != null && gate_options[index])
				dest = gate_options[index]
				station.awaygate = dest

	if(href_list["open"])
		open(usr)

	if(href_list["close"])
		connected = 0
		station.toggleoff(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	updateDialog()
	return 1

/obj/machinery/computer/gateway/proc/recalibrate()
//	gate_options[1] = locate(/obj/machinery/gateway/centeraway/centcom)
	centgate = locate(/obj/machinery/gateway/centeraway/centcom)
	gate_options[1] = locate(/obj/machinery/gateway/centeraway/exile)
	station.computer = src
	// This is the list of awaygates

////////////////////////////////////////CENTCOM COMPUTER///////////////////////////////////////////////////////

/obj/machinery/computer/gateway/centcom
	req_access = list(access_cent_general)

/obj/machinery/computer/gateway/centcom/New()
	station = locate(/obj/machinery/gateway/centerstation)
	centlink_gateway()
	centrecalibrate()

/obj/machinery/computer/gateway/centcom/Del()
	..()

/obj/machinery/computer/gateway/centcom/examine()
	..()

/obj/machinery/computer/gateway/centcom/initialize()
	centlink_gateway()


/obj/machinery/computer/gateway/centcom/proc/centlink_gateway()
	centgate = locate() in range(src, 7)
	station = locate(/obj/machinery/gateway/centerstation)

/obj/machinery/computer/gateway/centcom/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/gateway/centcom/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/gateway/centcom/attack_hand(mob/user)
	interact(user)

/obj/machinery/computer/gateway/centcom/interact(mob/user)
	if(!allowed(user))
		user << "\red Access Denied."
		return
	user.machine = src
	in_use = 1

	var/t = "<div class='statusDisplay'>[temp_msg]</div><BR>"

	// Current Destination
	t += "<BR><div class='statusDisplay'>"
	if(!dest)
		t += "No destination locked in."
	else
		t += "Destination Locked In: [dest]<BR>"
	t += "</div>"

	t += "<div class='statusDisplay'>"
	if(station)
		t += "<A href='?src=\ref[src];setdest=stat'>[station]</A><br>"
	for(var/i = 1; i <= gate_options.len; i++)
		t += "<A href='?src=\ref[src];setdest=[i]'>[gate_options[i]]</A><br>"
	t += "</div>"

	t += "<BR><A href='?src=\ref[src];open=1'>Open Gate</A>"
	t += " <A href='?src=\ref[src];close=1'>Close Gate</A>"
	t += " <A href='?src=\ref[src];block=1'>[centgate.blocked ? "Unblock Gate" : "Block Gate"]</A>"
	t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Destinations</A>"

	// Information about the last teleport
	t += "<BR><div class='statusDisplay'>"
	if(!lastdest)
		t += "No last destination data found."
	else
		t += "Last Destination: [lastdest]<BR>"
	t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/gateway/centcom/proc/centsparks()
	if(station)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(centgate))
		s.start()
	else
		return

/obj/machinery/computer/gateway/centcom/proc/centopengate(mob/user)

	if(connected)
		temp_msg = "Gateway is allready connected.<BR>Please close gate first."
		return

	if(centgate)

		centgate.detect()
		if(!centgate.ready)
			temp_msg = "Gateway is not ready."
			return

		if(!centgate.stationgate)
			temp_msg = "Gateway has no destination."
			return

		lastdest = dest

		playsound(centgate.loc, 'sound/weapons/flash.ogg', 25, 1)
		centsparks()

		temp_msg = "Attempting to open gate."


		spawn(30) // 3 seconds
			if(!centgate)
				return

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, get_turf(centgate))
			s.start()


			centgate.toggleon(user)
			connected=1
			temp_msg = "Gateway Open.<BR>"

			var/sparks = get_turf(dest)
			var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
			y.set_up(5, 1, sparks)
			y.start()

			playsound(centgate.loc, 'sound/weapons/emitter2.ogg', 25, 1)

			updateDialog()

/obj/machinery/computer/gateway/centcom/proc/centopen(mob/user)
	if(dest == null)
		temp_msg = "ERROR!<BR>Set a destination."
		return
	else
		centopengate(user)
	return

/obj/machinery/computer/gateway/centcom/Topic(href, href_list)
//	if(..())
//		return
	if(href_list["setdest"])
		var/index = href_list["setdest"]
		if(index == "stat")
			dest = station
			centgate.stationgate = dest
		else
			index = text2num(index)
			if(index != null && gate_options[index])
				dest = gate_options[index]
				centgate.stationgate = dest

	if(href_list["open"])
		centopen(usr)

	if(href_list["close"])
		connected = 0
		centgate.toggleoff(usr)

	if(href_list["block"])
		if(centgate.blocked)
			centgate.blocked = 0
		else
			centgate.blocked = 1
			centgate.toggleoff(usr)
			connected = 0
			station.toggleoff(usr)
			station.computer.connected = 0
			station.awaygate = null
			station.computer.dest = null

	if(href_list["recal"])
		centrecalibrate()
		centsparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	updateDialog()
	return 1

/obj/machinery/computer/gateway/centcom/proc/centrecalibrate()
	station = locate(/obj/machinery/gateway/centerstation)
//	gate_options[1] = locate(/obj/machinery/gateway/centeraway/centcom)
	gate_options[1] = locate(/obj/machinery/gateway/centeraway/exile)
	// This is the list of awaygates
	centgate.computer = src

	///AWAY AREAS//////////////////////////////////////////////////////////////////

/area/gatewaydest/exilemining
	name = "\improper Mining Hut"
	icon_state = "unexplored"

/area/turret_protected/exilegateway
	name = "\improper Exile Gateway"
	icon_state = "teleporter"

/area/gatewaydest/exilecave
	name = "\improper Cave"
	icon_state = "cave"