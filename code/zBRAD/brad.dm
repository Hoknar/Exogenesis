
////THINGS TO COPY WHEN UPDATING
//THIS FILE, DESTINY.DM, EXOGENESIS.DM
//ALL OF RUST (code\WorkInProgress\Cael_Aislinn)
//OOC FILE (code\game\verbs)

//THINGS TO CHANGE WHEN UPDATING
//MERGE MAP (COURT, ENGINE, LAW OFFICE)
//DISPOSALS (modules\recycling\disposals line 544)
//LAWYER CODE (code\game\jobs\job\civilian line 328)
//Camera naming code (code\game\machinery\camera\camera.dm  line 37)
//Door 2x1.dmi
//fullscreen.dmi
//ai_laws.dm  line 40
//night glasses (see brad.dm line 486)
//Change telescience computer to simple one on map
//modules/power/apc.dm update any "the_station_areas" to be z==1 || z==7
//Destiny line 283
//IAN CODE  /modules/mob/living/simple_animal/friendly/corgi
//Hydrolic Clamp
//BORERS. ADD new check_borer_coverage() into /modules/mob/living/simple_animal/borer   line 373





//New Areas by Brad OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO00000000000000000000000000000000000000000000000000000000000



//////////////////////////////////////////////////////////////////REGULAR NEW STATION AREAS

/area/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"

///Addthis line below without comment part to end of SS13 list in Space Station 13 areas.dm (line 1839)
//  	/area/courtroom,





///////////////////////////////////////////////////GENERATOR FOR RUST
/obj/machinery/power/generator3
	name = "thermoelectric generator MK III"
	desc = "It's a super capacity thermoelectric generator."
	icon_state = "teg"
	density = 1
	anchored = 0

	use_power = 1
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/obj/machinery/atmospherics/binary/circulator/circ1
	var/obj/machinery/atmospherics/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/generator3/New()
	..()

	spawn(1)
		reconnect()

//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/generator3/proc/reconnect()
	circ1 = null
	circ2 = null
	if(src.loc && anchored)
		if(src.dir & (EAST|WEST))
			circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)
			circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)

			if(circ1 && circ2)
				if(circ1.dir != SOUTH || circ2.dir != NORTH)
					circ1 = null
					circ2 = null

		else if(src.dir & (NORTH|SOUTH))
			circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,NORTH)
			circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,SOUTH)

			if(circ1 && circ2 && (circ1.dir != EAST || circ2.dir != WEST))
				circ1 = null
				circ2 = null

/obj/machinery/power/generator3/proc/updateicon()
	if(stat & (NOPOWER|BROKEN))
		overlays.Cut()
	else
		overlays.Cut()

		if(lastgenlev != 0)
			overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")

/obj/machinery/power/generator3/process()
	if(!circ1 || !circ2 || !anchored || stat & (BROKEN|NOPOWER))
		return

	updateDialog()

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()
	lastgen = 0

	if(air1 && air2)
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/efficiency = 0.65
			var/energy_transfer = delta_temperature*air2_heat_capacity*air1_heat_capacity/(air2_heat_capacity+air1_heat_capacity)
			var/heat = energy_transfer*(1-efficiency)
			lastgen = energy_transfer*efficiency*0.5

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity

			//Transfer the air
			circ1.air2.merge(air1)
			circ2.air2.merge(air2)

			//Update the gas networks
			if(circ1.network2)
				circ1.network2.update = 1
			if(circ2.network2)
				circ2.network2.update = 1

	// update icon overlays and power usage only if displayed level has changed
	if(lastgen > 800000 && prob(10))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		lastgen *= 0.5
	var/genlev = max(0, min( round(11*lastgen / 700000), 11))
	if(lastgen > 100 && genlev == 0)
		genlev = 1
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()
	add_avail(lastgen)

/obj/machinery/power/generator3/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)

/obj/machinery/power/generator3/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		user << "\blue You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor."
		use_power = anchored
		reconnect()
	else
		..()

/obj/machinery/power/generator3/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER) || !anchored) return
	interact(user)


/obj/machinery/power/generator3/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!istype(user, /mob/living/silicon/ai)))
		user.unset_machine()
		user << browse(null, "window=teg")
		return

	user.set_machine(src)

	var/t = "<PRE><B>Thermo-Electric Generator MK III</B><HR>"

	if(circ1 && circ2)
		t += "Output : [round(lastgen)] W<BR><BR>"

		t += "<B>Primary Circulator (top or right)</B><BR>"
		t += "Inlet Pressure: [round(circ1.air1.return_pressure(), 0.1)] kPa<BR>"
		t += "Inlet Temperature: [round(circ1.air1.temperature, 0.1)] K<BR>"
		t += "Outlet Pressure: [round(circ1.air2.return_pressure(), 0.1)] kPa<BR>"
		t += "Outlet Temperature: [round(circ1.air2.temperature, 0.1)] K<BR>"

		t += "<B>Secondary Circulator (bottom or left)</B><BR>"
		t += "Inlet Pressure: [round(circ2.air1.return_pressure(), 0.1)] kPa<BR>"
		t += "Inlet Temperature: [round(circ2.air1.temperature, 0.1)] K<BR>"
		t += "Outlet Pressure: [round(circ2.air2.return_pressure(), 0.1)] kPa<BR>"
		t += "Outlet Temperature: [round(circ2.air2.temperature, 0.1)] K<BR>"

	else
		t += "Unable to connect to circulators.<br>"
		t += "Ensure both are in position and wrenched into place."

	t += "<BR>"
	t += "<HR>"
	t += "<A href='?src=\ref[src]'>Refresh</A> <A href='?src=\ref[src];close=1'>Close</A>"

	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1


/obj/machinery/power/generator3/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.unset_machine()
		return 0

	updateDialog()
	return 1


/obj/machinery/power/generator3/power_change()
	..()
	updateicon()


/obj/machinery/power/generator3/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, 90)

/obj/machinery/power/generator3/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, -90)

//////////////////////////LAWYER STUFF
//COPY STUFF BETWEEN COMMENTS TO LAWYER JOB (code\game\jobs\job\civilian line 328)

/*

/datum/job/lawyer
	title = "Lawyer"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_access = list(access_lawyer, access_court, access_sec_doors)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/lawyerjacket(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big(H), slot_glasses)
		H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		//var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		//L.imp_in = H
		//L.implanted = 1
		//var/datum/organ/external/affected = H.organs_by_name["head"]
		//affected.implants += L
		//L.part = affected
		return 1

*/


//New Lawyer Items
/obj/item/clothing/suit/storage/lawyerjacket
	name = "Lawyer's Jacket"
	desc = "A smooth black jacket."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

	verb/toggle()
		set name = "Toggle Coat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		switch(icon_state)
			if("ia_jacket_open")
				src.icon_state = "ia_jacket"
				usr << "You button up the jacket."
			if("ia_jacket")
				src.icon_state = "ia_jacket_open"
				usr << "You unbutton the jacket."
			else
				usr << "You attempt to button-up the velcro on your [src], before promptly realising how stupid you are."
				return
		usr.update_inv_wear_suit()	//so our overlays update


//////////////////////////////////////CAMERA NAMING CODE
//COPY STUFF BETWEEN COMMENT TAGS TO code\game\machinery\camera\camera.dm  line 37 adding the variable in the top to the existing camera and overwriting the entire 'new'
//proc for cameras (before emp_act)
/*

	//AREA NAMING
	var/area_uid
	var/area/cam_area

/obj/machinery/camera/New()
	WireColorToFlag = randomCameraWires()
	assembly = new(src)
	assembly.state = 4

	//Name the camera based on area
	cam_area = get_area(src)
	if (cam_area.master)
		cam_area = cam_area.master
	area_uid = cam_area.uid
	if(c_tag == null)
		c_tag = "[cam_area.name] "

	// Use this to look for cameras that have the same c_tag, and add a "I" to the end.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			//world.log << "[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]"
			src.c_tag = "[src.c_tag]I"

	if(!src.network || src.network.len < 1)
		if(loc)
			error("[src.name] in [get_area(src)] (x:[src.x] y:[src.y] z:[src.z] has errored. [src.network?"Empty network list":"Null network list"]")
		else
			error("[src.name] in [get_area(src)]has errored. [src.network?"Empty network list":"Null network list"]")
		ASSERT(src.network)
		ASSERT(src.network.len > 0)
	..()

*/




//////////////////////////////////////////////NEW BOMBS///////////////////////////////////////////////////////////////////////////////
/obj/effect/spawner/goodbomb
	name = "bomb"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/ttype = 0 // 0=small, 1=med, 2=big

	timer
		btype = 2

		syndicate

		med
			ttype = 1

		big
			ttype = 2

	proximity
		btype = 1

		med
			ttype = 1

		big
			ttype = 2

	radio
		btype = 0

		med
			ttype = 1

		big
			ttype = 2


/obj/effect/spawner/goodbomb/New()
	..()

	var/obj/item/device/transfer_valve/V = new(src.loc)
	var/obj/item/weapon/tank/plasma/PT = new(V)
	var/obj/item/weapon/tank/oxygen/OT = new(V)

	V.tank_one = PT
	V.tank_two = OT

	PT.master = V
	OT.master = V

	switch (src.ttype)
		//small
		if (0)
			PT.air_contents.toxins = 5
			PT.air_contents.nitrogen = 1
			PT.air_contents.carbon_dioxide = 23

		//med
		if (1)
			PT.air_contents.toxins = 8
			PT.air_contents.nitrogen = 1
			PT.air_contents.carbon_dioxide = 20

		//big
		if (2)
			PT.air_contents.toxins = 15
			PT.air_contents.nitrogen = 1
			PT.air_contents.carbon_dioxide = 13

	PT.air_contents.temperature = 220+T0C

	PT.air_contents.update_values()

	OT.air_contents.temperature = 20+T0C
	OT.air_contents.oxygen = 29
	OT.air_contents.update_values()

	var/obj/item/device/assembly/S

	switch (src.btype)
		// radio
		if (0)

			S = new/obj/item/device/assembly/signaler(V)

		// proximity
		if (1)

			S = new/obj/item/device/assembly/prox_sensor(V)

		// timer
		if (2)

			S = new/obj/item/device/assembly/timer(V)


	V.attached_device = S

	S.holder = V
	S.toggle_secure()

	V.update_icon()

	del(src)


/proc/nograv_trajectory(var/src_x, var/src_y, var/rotation, var/power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y]
	// rotated at [rotation] and with the power of [power]

	var/power_x = power
	var/power_y = power
	var/time = 2* power_y / 10 //10 = g

	var/distance = power

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

//////////////////////////Night Vision Goggles////////////////////////////////////////////////////////////////////////////
/* Copy into modules/clothing/glasses/Glasses.dm ine 33


/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!."
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "magnets=2"
	darkness_view = 0
	var/ison = 0

/obj/item/clothing/glasses/night/verb/toggle()
	set category = "Object"
	set name = "Toggle On"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(src.ison)
			src.ison = 0
			src.darkness_view = 0
			usr << "You turn the goggles off."
		else
			src.ison = 1
			src.darkness_view = 100
			usr << "You turn the goggles on."

		usr.update_inv_glasses()

/obj/item/clothing/glasses/night/attack_self()
	toggle()


/////////////////////////////////////////////////LIFE GLASSES UPDATE FOR NIGHT

//REPLACE INTO modules/mob/living/carbon/human/life.dm (human) line 1278

			if(glasses)
				var/obj/item/clothing/glasses/G = glasses
				if(istype(G))
					see_in_dark += G.darkness_view
					if(see_in_dark > 100)
						see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
					if(G.vision_flags)
						sight |= G.vision_flags
						if(!druggy)
							see_invisible = SEE_INVISIBLE_MINIMUM

*/


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////   SIMPLE TELESCIENCE /////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/machinery/computer/simpetelescience
	name = "\improper Telescience Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	var/angle_off
	var/offset

	var/rotation = 0
	var/angle = 0
	var/power = 1

	// Based on the power used
	var/teleport_cooldown = 0
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80, 100) // every index requires a bluespace crystal
	var/teleporting = 0
	var/starting_crystals = 6
	var/list/crystals = list()

/obj/machinery/computer/simpetelescience/New()
	..()
	link_telepad()
	recalibrate()

/obj/machinery/computer/simpetelescience/Del()
	eject()
	..()

/obj/machinery/computer/simpetelescience/examine()
	..()
	usr << "There are [crystals.len] bluespace crystals in the crystal ports."

/obj/machinery/computer/simpetelescience/initialize()
	..()
	link_telepad()
	for(var/i = 1; i <= starting_crystals; i++)
		crystals += new /obj/item/bluespace_crystal/artificial(null) // starting crystals
	power = power_options[1]

/obj/machinery/computer/simpetelescience/proc/link_telepad()
	telepad = locate() in range(src, 7)

/obj/machinery/computer/simpetelescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/simpetelescience/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/simpetelescience/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/bluespace_crystal))
		if(crystals.len >= power_options.len)
			user << "<span class='warning'>There are not enough crystal ports.</span>"
			return
		user.drop_item()
		crystals += W
		W.loc = null
		user.visible_message("<span class='notice'>[user] inserts a [W] into the [src]'s crystal port.</span>")
	else
		..()

/obj/machinery/computer/simpetelescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/simpetelescience/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/simpetelescience/interact(mob/user)
	user.machine = src
	in_use = 1

	var/t = "<div class='statusDisplay'>[temp_msg]</div><BR>"
	t += "<A href='?src=\ref[src];setrotation=1'>Set Bearing</A>"
	t += "<div class='statusDisplay'>[rotation]°</div>"
//	t += "<A href='?src=\ref[src];setangle=1'>Set Elevation</A>"
//	t += "<div class='statusDisplay'>[angle]°</div>"
	t += "<A href='?src=\ref[src];setpower=1'>Set Power</A>"
	t += "<div class='statusDisplay'>[power]</div>"
//	t += "<span class='linkOn'>Set Power</span>"
//	t += "<div class='statusDisplay'>"

/*
	for(var/i = 1; i <= power_options.len; i++)
		if(crystals.len < i)
			t += "<span class='linkOff'>[power_options[i]]</span>"
			continue
		if(power == power_options[i])
			t += "<span class='linkOn'>[power_options[i]]</span>"
			continue
		t += "<A href='?src=\ref[src];setpower=[i]'>[power_options[i]]</A>"
*/

//	t += "</div>"
	t += "<A href='?src=\ref[src];setz=1'>Set Sector</A>"
	t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

	t += "<BR><A href='?src=\ref[src];send=1'>Send</A>"
	t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
	t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Crystals</A> <A href='?src=\ref[src];eject=1'>Change Offset</A>"

	// Information about the last teleport
	t += "<BR><div class='statusDisplay'>"
	if(!last_tele_data)
		t += "No teleport data found."
	else
		t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<BR>"
		//t += "Distance: [round(last_tele_data.distance, 0.1)]m<BR>"
		t += "Time: [round(last_tele_data.time, 0.1)] secs<BR>"
	t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/simpetelescience/proc/sparks()
	if(telepad)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(telepad))
		s.start()
	else
		return

/obj/machinery/computer/simpetelescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/simpetelescience/proc/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)

		var/truePower = Clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off

//		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		var/datum/projectile_data/proj_data = nograv_trajectory(telepad.x, telepad.y, trueRotation, truePower)
		last_tele_data = proj_data

		var/trueX = Clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = Clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		var/area/A = get_area(target)
		flick("pad-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, 1)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		spawn(round(proj_data.time) * 10) // in seconds
			if(!telepad)
				return
			if(telepad.stat & NOPOWER)
				return
			teleporting = 0
			teleport_cooldown = world.time + (power * 2)
			teles_left -= power

			// use a lot of power
			use_power(power * 10)

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, get_turf(telepad))
			s.start()

			temp_msg = "Teleport successful.<BR>"
			if(teles_left < 200)
				temp_msg += "<BR>Calibration required soon."
			else
				temp_msg += "Data printed below."
			investigate_log("[key_name(usr)]/[user] has teleported with Telescience at [trueX],[trueY],[z_co], in [A ? A.name : "null area"].","telesci")

			var/sparks = get_turf(target)
			var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
			y.set_up(5, 1, sparks)
			y.start()

			var/turf/source = target
			var/turf/dest = get_turf(telepad)
			if(sending)
				source = dest
				dest = target

			flick("pad-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1)
			for(var/atom/movable/ROI in source)
				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						if(L.buckled)
							// TP people on office chairs
							if(L.buckled.anchored)
								continue
						else
							continue
					else if(!isobserver(ROI))
						continue
				do_teleport(ROI, dest)
			updateDialog()

/obj/machinery/computer/simpetelescience/proc/teleport(mob/user)
	if(rotation == null || angle == null || z_co == null)
		temp_msg = "ERROR!<BR>Set a angle, rotation and sector."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ERROR!<BR>No power selected!"
		return
//	if(angle < 1 || angle > 90)
//		telefail()
//		temp_msg = "ERROR!<BR>Elevation is less than 1 or greater than 90."
//		return
	if(z_co == 2 || z_co < 1 || z_co > 6)
		telefail()
		temp_msg = "ERROR! Sector is less than 1, <BR>greater than 6, or equal to 2."
		return
	if(teles_left > 0)
		doteleport(user)
	else
		telefail()
		temp_msg = "ERROR!<BR>Calibration required."
		return
	return

/obj/machinery/computer/simpetelescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.loc = src.loc
		crystals -= I
	power = 0

/obj/machinery/computer/simpetelescience/Topic(href, href_list)
	if(..())
		return
	if(href_list["setrotation"])
		var/new_rot = input("Please input desired bearing in degrees.", name, rotation) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = Clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(..())
			return
		angle = Clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
	/*
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			if(crystals.len >= index)
				power = power_options[index]
	*/
		var/new_power = input("Please input desired power level", name, power) as num
		if(..())
			return
		power = Clamp(round(new_power, 0.01), 1, 1000)

	if(href_list["setz"])
		var/new_z = input("Please input desired sector.", name, z_co) as num
		if(..())
			return
		z_co = Clamp(round(new_z), 1, 10)

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	if(href_list["eject"])
//		eject()
		var/new_offset = input("Please offset.", name, offset) as num
		if(..())
			return
		rotation_off += new_offset
		temp_msg = "NOTICE:<BR>Offset Changed."

	updateDialog()
	return 1

/obj/machinery/computer/simpetelescience/proc/recalibrate()
	teles_left = rand(1500, 2500)
	angle_off = 0//rand(-25, 25)
	power_off = 0//rand(-4, 0)
	rotation_off = rand(10, 350)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/card/id/mad_scientist
	name = "ID"
	desc = "ID."
	icon_state = "centcom_old"
	item_state = "gold_id"
	registered_name = "ID"
	assignment = "Mad Scientist"
	New()
		var/datum/job/captain/J = new/datum/job/scientist
		access = J.get_access()
		..()


///////////////////////////////PERSONAL DOORS

/obj/machinery/door/airlock/personal
	name = "Cabin Door"
	icon = 'icons/obj/doors/Doormining.dmi'
	desc = "This is a lockable personal door. Swipe your ID on the door to lock it using your account number."
	var/idlockdoor = 1
	var/idlock = 0
	var/linkedID = 0
	var/doorready = 1
	var/oldname = "name"

/obj/machinery/door/airlock/personal/bathroom
	name = "Bathroom Stall Door"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	desc = "This is a lockable stall door. Swipe your ID on the door to lock it using your account number."

/obj/machinery/door/airlock/personal/cell
	name = "Cell Door"
	icon = 'icons/obj/doors/Doorglass.dmi'
	desc = "This is a lockable Cell door. Swipe your ID on the door to lock it to your account number. Guards also have access to unlock with their ID."
	opacity = 0

/obj/machinery/door/airlock/personal/New()
	oldname = src.name
	..()

/obj/machinery/door/airlock/personal/cell/attackby(C as obj, mob/user as mob)
	if(istype(C, /obj/item/weapon/card/id) && src.idlockdoor)
		var/isguard = 0
		var/obj/item/weapon/card/id/W = C
		if(src.idlock)
			if(src.linkedID == W.associated_account_number)
				user << "\blue You swipe your card and the door unlocks."
				src.name = src.oldname
				src.locked = 0
				src.idlock = 0
				src.doorready = 0
				src.update_icon()
				return
			else
				for(var/theaccess in W.access)
					if(theaccess == 2)
						isguard = 1

				if(isguard)
					user << "\blue You swipe your card and the door recognizes you as a guard and unlocks."
					src.locked = 0
					src.idlock = 0
					src.doorready = 0
					src.update_icon()
				else
					user << "\blue You swipe your ID, but the door just beeps at you..."
					flick("door_deny", src)
				return
		else
			user << "\blue You swipe your ID, and the door locks down, linked to your account number."
			src.name = "[src.name] ([W.registered_name])"
			src.linkedID = W.associated_account_number
			src.idlock = 1
			src.locked = 1
			src.doorready = 0
			src.update_icon()
			return
	..()

/obj/machinery/door/airlock/personal/bathroom/attackby(C as obj, mob/user as mob)
	if(istype(C, /obj/item/weapon/card/id) && src.idlockdoor)
		var/obj/item/weapon/card/id/W = C
		if(src.idlock)
			if(src.linkedID == W.associated_account_number)
				user << "\blue You swipe your card and the door unlocks."
				src.name = src.oldname
				src.locked = 0
				src.idlock = 0
				src.doorready = 0
				src.update_icon()
			else
				user << "\blue You swipe your ID, but the door just beeps at you..."
				flick("door_deny", src)
			return
		else
			user << "\blue You swipe your ID, and the door locks down, linked to your account number."
			src.name = "[src.name] ([W.registered_name])"
			src.linkedID = W.associated_account_number
			src.idlock = 1
			src.locked = 1
			src.doorready = 0
			src.update_icon()
			return
	..()


/obj/machinery/door/airlock/personal/attackby(C as obj, mob/user as mob)
	//world << text("airlock attackby src [] obj [] mob []", src, C, user)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	src.add_fingerprint(user)
	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating > 0 ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			if(!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
		else
			return
	else if(istype(C, /obj/item/weapon/screwdriver))
		src.p_open = !( src.p_open )
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/multitool))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/assembly/signaler))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/twohanded/fireaxe) )
		var/beingcrowbarred = null
		if(istype(C, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if( beingcrowbarred && (operating == -1 || density && welded && operating != 1 && src.p_open && (!src.arePowerSystemsOn() || stat & NOPOWER) && !src.locked) )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(do_after(user,40))
				user << "\blue You removed the airlock electronics!"

				var/obj/structure/door_assembly/da = new assembly_type(src.loc)
				da.anchored = 1
				if(mineral)
					da.glass = mineral
				//else if(glass)
				else if(glass && !da.glass)
					da.glass = 1
				da.state = 1
				da.created_name = src.name
				da.update_state()

				var/obj/item/weapon/airlock_electronics/ae
				if(!electronics)
					ae = new/obj/item/weapon/airlock_electronics( src.loc )
					if(src.req_access.len)
						ae.conf_access = src.req_access
					else if (src.req_one_access.len)
						ae.conf_access = src.req_one_access
						ae.one_access = 1
				else
					ae = electronics
					electronics = null
					ae.loc = src.loc
				if(operating == -1)
					ae.icon_state = "door_electronics_smoked"
					operating = 0

				del(src)
				return
		else if(arePowerSystemsOn() && !(stat & NOPOWER))
			user << "\blue The airlock's motors resist your efforts to force it."
		else if(locked)
			user << "\blue The airlock's bolts prevent it from being forced."
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn(0)	open(1)
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn(0)	close(1)
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn(0)	close(1)

	else if(istype(C, /obj/item/weapon/card/id) && src.idlockdoor)
		var/obj/item/weapon/card/id/W = C
		if(src.idlock && src.doorready)
			if(src.linkedID == W.associated_account_number)
				user << "\blue You swipe your card and the door unlocks."
				src.name = src.oldname
				src.locked = 0
				src.idlock = 0
				src.update_icon()
			else
				user << "\blue You swipe your ID, but the door just beeps at you..."
				flick("door_deny", src)
			return
		else
			user << "\blue You swipe your ID, and the door locks down, linked to your account number."
			src.name = "[src.name] ([W.registered_name])"
			src.linkedID = W.associated_account_number
			src.idlock = 1
			src.locked = 1
			src.update_icon()
			return
		doorready = 1
	else
		..()
	return

/////////////////////////////////////////NEW BRIG TIMERS BY NAME//////////////////////////////////////////////////////////////////////////
#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"

/obj/machinery/prisoner_timer
	name = "Prisoner Timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A timer for prisoner brig duration."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it.
	layer = 4
	var/id = null     		// id of door it controls.
	var/releasetime = 0		// when world.timeofday reaches it - release the prisoner
	var/timing = 1    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/targets = list()
	var/timetoset = 0		// Used to set releasetime upon starting the timer
	var/prisoner = "Empty"

	maptext_height = 26
	maptext_width = 32

/obj/machinery/prisoner_timer/New()
	..()

	pixel_x = ((src.dir & 3)? (0) : (src.dir == 4 ? 32 : -32))
	pixel_y = ((src.dir & 3)? (src.dir ==1 ? 24 : -32) : (0))
	layer = 4
	return


//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the prisoner_timer window and the icon
/obj/machinery/prisoner_timer/process()

	if(stat & (NOPOWER|BROKEN))	return
	if(src.timing)

		// poorly done midnight rollover
		// (no seriously there's gotta be a better way to do this)
		var/timeleft = timeleft()
		if(timeleft > 1e5)
			src.releasetime = 0


		if(world.timeofday > src.releasetime)
			src.timer_end() // open doors, reset timer, clear status screen
			src.timing = 1
			releasetime = 0

		src.updateUsrDialog()
		src.update_icon()

	else
		timer_end()

	return


// has the door power situation changed, if so update icon.
/obj/machinery/prisoner_timer/power_change()
	..()
	update_icon()
	return


// open/closedoor checks if prisoner_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.

// Closes and locks doors, power check
/obj/machinery/prisoner_timer/proc/timer_start()
	if(stat & (NOPOWER|BROKEN))	return 0

	// Set releasetime
	releasetime = world.timeofday + timetoset


// Opens and unlocks doors, power check
/obj/machinery/prisoner_timer/proc/timer_end()
	if(stat & (NOPOWER|BROKEN))	return 0

	// Reset releasetime
	releasetime = 0

	return 1


// Check for releasetime timeleft
/obj/machinery/prisoner_timer/proc/timeleft()
	. = (releasetime - world.timeofday)/10
	if(. < 0)
		. = 0

// Set timetoset
/obj/machinery/prisoner_timer/proc/timeset(var/seconds)
	timetoset = seconds * 10

	if(timetoset <= 0)
		timetoset = 0

	return

//Allows AIs to use prisoner_timer, see human attack_hand function below
/obj/machinery/prisoner_timer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


//Allows humans to use prisoner_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds
/obj/machinery/prisoner_timer/attack_hand(var/mob/user as mob)
	if(..())
		return

	// Used for the 'time left' display
	var/second = round(timeleft() % 60)
	var/minute = round((timeleft() - second) / 60)

	// Used for 'set timer'
	var/setsecond = round((timetoset / 10) % 60)
	var/setminute = round(((timetoset / 10) - setsecond) / 60)

	user.set_machine(src)

	// dat
	var/dat = "<HTML><BODY><TT>"

	dat += "<HR>Timer System:</hr>"
	dat += " <b>Prisoner: [src.prisoner] </b><br/>"
	dat += "<a href='?src=\ref[src];prisoner=1'>Set Prisoner Name</a>"
	dat += " - <a href='?src=\ref[src];empty=1'><i>Empty</i></a><br/><hr>"

	// Start/Stop timer
	if (src.timing)
		dat += "<a href='?src=\ref[src];timing=0'>Stop Timer</a><br/>"
	else
		dat += "<a href='?src=\ref[src];timing=1'>Activate Timer</a><br/>"

	// Time Left display (uses releasetime)
	dat += "Time Left: [(minute ? text("[minute]:") : null)][second] <br/>"
	dat += "<br/>"

	// Set Timer display (uses timetoset)
	if(src.timing)
		dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]  <a href='?src=\ref[src];change=1'>Set</a><br/>"
	else
		dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]<br/>"

	// Controls
	dat += "<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"


	dat += "<br/><br/><a href='?src=\ref[user];mach_close=computer'>Close</a>"
	dat += "</TT></BODY></HTML>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return


//Function for using prisoner_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// 	"change" resets the timer to the timetoset amount while the timer is counting down
// Also updates dialog window and timer icon
/obj/machinery/prisoner_timer/Topic(href, href_list)
	if(..())
		return
	if(!src.allowed(usr))
		return

	usr.set_machine(src)

	if(href_list["timing"])
		src.timing = text2num(href_list["timing"])

		if(src.timing)
			src.timer_start()
		else
			src.timer_end()

	else
		if(href_list["tp"])  //adjust timer, close door if not already closed
			var/tp = text2num(href_list["tp"])
			var/addtime = (timetoset / 10)
			addtime += tp
			addtime = min(max(round(addtime), 0), 3600)

			timeset(addtime)

		if(href_list["fc"])
			for(var/obj/machinery/flasher/F in targets)
				F.flash()

		if(href_list["change"])
			src.timer_start()

		if(href_list["prisoner"])
			prisoner = input("Please input Prisoner Name", name, prisoner) as text

		if(href_list["empty"])
			prisoner = "Empty"
			src.timer_end()

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	src.update_icon()

	/* if(src.timing)
		src.timer_start()

	else
		src.timer_end() */

	return


//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/prisoner_timer/update_icon()
	if(stat & (NOPOWER))
		icon_state = "frame"
		return
	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return
	if(src.timing)
		var/disp1 = prisoner
		var/timeleft = timeleft()
		var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
		if(length(disp2) > CHARS_PER_LINE)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)	maptext = ""
	return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/prisoner_timer/proc/set_picture(var/state)
	picture_state = state
	overlays.Cut()
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/prisoner_timer/proc/update_display(var/line1, var/line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text


//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
/obj/machinery/prisoner_timer/proc/texticon(var/tn, var/px = 0, var/py = 0)
	var/image/I = image('icons/obj/status_display.dmi', "blank")
	var/len = lentext(tn)

	for(var/d = 1 to len)
		var/char = copytext(tn, len-d+1, len-d+2)
		if(char == " ")
			continue
		var/image/ID = image('icons/obj/status_display.dmi', icon_state=char)
		ID.pixel_x = -(d-1)*5 + px
		ID.pixel_y = py
		I.overlays += ID
	return I


#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE

//////////////////////////DIRECTIONAL SIGNS//////////////////////////////////////////////////
/obj/structure/sign/directions/directional/scienceN
	name = "\improper Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"
	pixel_y = 0
	dir = 1

/obj/structure/sign/directions/directional/engineeringN
	name = "\improper Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"
	pixel_y = 12
	dir = 1

/obj/structure/sign/directions/directional/securityN
	name = "\improper Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"
	pixel_y = -8
	dir = 1

/obj/structure/sign/directions/directional/medicalN
	name = "\improper Medical Bay"
	desc = "A direction sign, pointing out which way Meducal Bay is."
	icon_state = "direction_med"
	pixel_y = 6
	dir = 1

/obj/structure/sign/directions/directional/evacN
	name = "\improper Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"
	dir = 1

/obj/structure/sign/directions/directional/scienceN
	name = "\improper Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"
	pixel_y = 0
	dir = 1

/obj/structure/sign/directions/directional/engineeringE
	name = "\improper Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"
	pixel_y = 12
	dir = 4

/obj/structure/sign/directions/directional/securityE
	name = "\improper Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"
	pixel_y = -8
	dir = 4

/obj/structure/sign/directions/directional/medicalE
	name = "\improper Medical Bay"
	desc = "A direction sign, pointing out which way Meducal Bay is."
	icon_state = "direction_med"
	pixel_y = 6
	dir = 4

/obj/structure/sign/directions/directional/evacE
	name = "\improper Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"
	dir = 4

/obj/structure/sign/directions/directional/scienceE
	name = "\improper Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"
	pixel_y = 0
	dir = 4

/obj/structure/sign/directions/directional/engineeringS
	name = "\improper Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"
	pixel_y = 12
	dir = 2

/obj/structure/sign/directions/directional/securityS
	name = "\improper Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"
	pixel_y = -8
	dir = 2

/obj/structure/sign/directions/directional/medicalS
	name = "\improper Medical Bay"
	desc = "A direction sign, pointing out which way Meducal Bay is."
	icon_state = "direction_med"
	pixel_y = 6
	dir = 2

/obj/structure/sign/directions/directional/evacS
	name = "\improper Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"
	dir = 2

/obj/structure/sign/directions/directional/scienceS
	name = "\improper Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"
	pixel_y = 0
	dir = 2

/obj/structure/sign/directions/directional/engineeringW
	name = "\improper Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"
	pixel_y = 12
	dir = 8

/obj/structure/sign/directions/directional/securityW
	name = "\improper Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"
	pixel_y = -8
	dir = 8

/obj/structure/sign/directions/directional/medicalW
	name = "\improper Medical Bay"
	desc = "A direction sign, pointing out which way Meducal Bay is."
	icon_state = "direction_med"
	pixel_y = 6
	dir = 8

/obj/structure/sign/directions/directional/evacW
	name = "\improper Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"
	dir = 8

/obj/structure/sign/directions/directional/scienceW
	name = "\improper Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"
	pixel_y = 0
	dir = 8


//////////////////HYDROLIC CLAMP CODE
//ADD TO game/mecha/tools/tools.dm  line 28
//THEN Chane IF below this to an else if.
/*

		if (istype(target,/obj/machinery/door))
			var/obj/machinery/door/O = target
			chassis.visible_message("\red \The [chassis] starts to force \the [target] [O.density ? "open" : "closed"] with the Hydrolic Clamp!")
			occupant_message("You start forcing the [target] [O.density ? "open" : "closed"] with the Hydrolic Clamp! You hear metal strain.")
			if(do_after_cooldown(target))
				chassis.visible_message("\red \The [chassis] forces \the [target] [O.density ? "open" : "closed"] with the Hydrolic Clamp!")
				occupant_message("You force \the [target] [O.density ? "open" : "closed"] with the Hydrolic Clamp! You hear metal strain, and a door [O.density ? "open" : "close"].")
				if(O.density)
					spawn(0)
						O.open()
				else
					spawn(0)
						O.close()
				return

*/

/mob/living/carbon/human/proc/check_borer_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & HEAD)
				if(istype(bp ,/obj/item/clothing/head/helmet))
					return 1
				else if(istype(bp ,/obj/item/clothing/head/bio_hood))
					return 1
				else if(istype(bp ,/obj/item/clothing/head/bomb_hood))
					return 1
				else if(istype(bp ,/obj/item/clothing/ears/earmuffs))
					return 1

	return 0

/obj/item/weapon/book/manual/security_ic
	name = "Facility Security"
	desc = "Milo Hachert, Senior Member of NanoTrasen Security Graduate, Locke Academy of Advanced Military Studies."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pamphlet"
	author = "Milo Hachert"
	title = "Facility Security: Meaning And Application of Duties"

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://mcbeards.com/exogenesis/index.php?title=Facility_Security&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>		</body>

		</html>

		"}

/obj/item/weapon/book/manual/simple_telescience
	name = "Simple Telescience"
	desc = "Welcome to Telescience, the room where you teleport stuff."
	icon_state = "triangulate"
	author = "Gerald Hobbes"
	title = "Telescience and YOU"

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://mcbeards.com/exogenesis/index.php?title=Guide_To_Telescience&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>		</body>

		</html>

		"}

/obj/structure/table/verb/climbonto()
	set name = "Climb onto table"
	set desc = "Climb up onto the table"
	set category = "Object"
	set src in oview(1)
	if(ismouse(usr))
		return
	if (!can_touch(usr) || !usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr))
		usr << "You can not touch that."
		return
	usr.visible_message("<span class='warning'>[usr] starts to climb up onto \the [src]!</span>")
	spawn(20)
		usr.visible_message("<span class='warning'>[usr] climbs up onto \the [src]!</span>")
		usr.loc = src.loc
		usr.Weaken(2)
		return


/*

	if(href_list["dibs"])
		var/mob/ref_person = locate(href_list["dibs"])
//		var/adminckey = href_list["ckey"]
		var/msg = "\blue <b><font color=red>NOTICE: </font><font color=darkgreen>[usr.key]</font> is answering adminhelp from <font color=red>[ref_person]</font>.</b>"

		//send this msg to all admins
		for(var/client/X in admins)
			if((R_ADMIN|R_MOD) & X.holder.rights)
				if(X.prefs.toggles & SOUND_ADMINHELP)
					X << 'sound/effects/adminhelp.ogg'
				X << msg

*/