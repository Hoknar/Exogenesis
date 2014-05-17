//EXOGENESIS STATION AREAS
/area/hallway/primary/vestal/main
	name = "Vestal Hallway"
	icon_state = "hallC"

/area/hallway/primary/central/devil
	name = "DEVIL Hallway"
	icon_state = "blue-red"

/area/maintenance/MI/Maint
	name = "Mind Imaging Maintenance"
	icon_state = "maintcentral"

/area/engine/checkpoint/Northern
	name = "Northern Engineering"
	icon_state = "engine_control"

/area/maintenance/disposal/Maint
	name = "Disposal Maintenance"
	icon_state = "fmaint"

/area/maintenance/bore/Maint
	name = "Bore Maintenance"
	icon_state = "maintcentral"

/area/maintenance/toxins/Maint
	name = "Toxins Maintenance"
	icon_state = "fmaint"

/area/maintenance/pods/Maint
	name = "Pods Maintenance"
	icon_state = "fmaint"

/area/pods
	name = "Pods"
	icon_state = "dark128"

// ===================================== Exogenesis Station elevator areas =========================================

/area/shuttle/elevator
	name = "\improper elevator"
	music = "music/escape.ogg"

/area/shuttle/elevator/walls
	icon_state = "exit"

/area/shuttle/elevator/living
	icon_state = "shuttle"

/area/shuttle/elevator/science
	icon_state = "shuttle"

/area/shuttle/elevator/devilliving
	icon_state = "shuttle2"

/area/shuttle/elevator/devilscience
	icon_state = "shuttle2"

/area/shuttle/elevator/devilspace
	icon_state = "shuttle2"

/area/shuttle/elevator/devilentry
	icon_state = "shuttle2"

/area/shuttle/elevator/space
	icon_state = "shuttle"

/area/shuttle/elevator/entry
	icon_state = "shuttle"

//------------------------------------------------------------------------------

///COPY THIS INTO AREAS IF USING EXOGENESIS ELEVATORS
//SPACE STATION 13

var/list/exogenesis_areas = list (
	/area/hallway/primary/central/devil, //00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	/area/hallway/primary/vestal/main,
	/area/maintenance/MI/Maint,
	/area/engine/checkpoint/Northern,
	/area/maintenance/disposal/Maint,
	/area/maintenance/bore/Maint,
	/area/maintenance/toxins/Maint,
	/area/maintenance/pods/Maint,
	/area/pods,
	/area/shuttle/elevator,
	/area/shuttle/elevator/walls,
	/area/shuttle/elevator/living,
	/area/shuttle/elevator/science,
	/area/shuttle/elevator/devilliving,
	/area/shuttle/elevator/devilscience,
	/area/shuttle/elevator/devilspace,
	/area/shuttle/elevator/devilentry,
	/area/shuttle/elevator/space,
	/area/shuttle/elevator/entry,
)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////**********************EXOGENESIS ELEVATOR CONTROLS**************************////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ELEVATOR_CONTROL_RANGE 200

//ENTRY/DEVIL
var/elevator_entry_loc = 1 //1=entry 0=devil

//ENTRY TO DEVIL

var/elevator_entry_tickstomove = 5
var/elevator_entry_moving = 0

proc/move_elevator_entry()
	if(elevator_entry_moving)	return
	elevator_entry_moving = 1
	spawn(elevator_entry_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/entry)
		toArea = locate(/area/shuttle/elevator/devilentry)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, NORTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_entry_moving = 0
		if(elevator_entry_loc)
			elevator_entry_loc = 0
		else
			elevator_entry_loc = 1

	return

/obj/machinery/elevator/entry/button_entry
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/entry/button_entry/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to DEVIL</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/entry/button_entry/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_entry_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_entry()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorentry"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorentry"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilentry"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilentry"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilentry_tickstomove*6)
			signal.data["tag"] = "elevatordevilentry"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return

//Elevator call button
/obj/machinery/elevator/entry/call_entry
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/entry/call_entry/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_entry_moving)
		if(elevator_entry_loc)
			signal.data["tag"] = "elevatorentry"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/entry/call_entry/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_entry_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_entry()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilentry"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilentry"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilentry_tickstomove*8)
			signal.data["tag"] = "elevatorentry"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatorentry"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return



//DEVIL TO ENTRY

var/elevator_devilentry_tickstomove = 5
var/elevator_devilentry_moving = 0

proc/move_elevator_devilentry()
	if(elevator_devilentry_moving)	return
	elevator_devilentry_moving = 1
	spawn(elevator_devilentry_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/devilentry)
		toArea = locate(/area/shuttle/elevator/entry)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, SOUTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_devilentry_moving = 0

		if(elevator_entry_loc)
			elevator_entry_loc = 0
		else
			elevator_entry_loc = 1

	return

/obj/machinery/elevator/devilentry/button_devilentry
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilentry/button_devilentry/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to Entry Hall</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/devilentry/button_devilentry/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_devilentry_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_devilentry()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilentry"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilentry"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorentry"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorentry"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilentry_tickstomove*6)
			signal.data["tag"] = "elevatorentry"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return


//Elevator call button
/obj/machinery/elevator/devilentry/call_devilentry
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilentry/call_devilentry/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_entry_moving)
		if(!elevator_entry_loc)
			signal.data["tag"] = "elevatordevilentry"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/devilentry/call_devilentry/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_entry_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_devilentry()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorentry"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorentry"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilentry_tickstomove*8)
			signal.data["tag"] = "elevatordevilentry"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatordevilentry"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return


//Science/DEVIL
var/elevator_science_loc = 1 //1=science 0=devil

//science TO DEVIL

var/elevator_science_tickstomove = 5
var/elevator_science_moving = 0

proc/move_elevator_science()
	if(elevator_science_moving)	return
	elevator_science_moving = 1
	spawn(elevator_science_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/science)
		toArea = locate(/area/shuttle/elevator/devilscience)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, NORTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_science_moving = 0
		if(elevator_science_loc)
			elevator_science_loc = 0
		else
			elevator_science_loc = 1

	return

/obj/machinery/elevator/science/button_science
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/science/button_science/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to DEVIL</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/science/button_science/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_science_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_science()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorscience"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorscience"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilscience"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilscience"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilscience_tickstomove*6)
			signal.data["tag"] = "elevatordevilscience"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return

//Elevator call button
/obj/machinery/elevator/science/call_science
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/science/call_science/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_science_moving)
		if(elevator_science_loc)
			signal.data["tag"] = "elevatorscience"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/science/call_science/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_science_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_science()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilscience"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilscience"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilscience_tickstomove*8)
			signal.data["tag"] = "elevatorscience"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatorscience"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return



//DEVIL TO science

var/elevator_devilscience_tickstomove = 5
var/elevator_devilscience_moving = 0

proc/move_elevator_devilscience()
	if(elevator_devilscience_moving)	return
	elevator_devilscience_moving = 1
	spawn(elevator_devilscience_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/devilscience)
		toArea = locate(/area/shuttle/elevator/science)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, SOUTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_devilscience_moving = 0

		if(elevator_science_loc)
			elevator_science_loc = 0
		else
			elevator_science_loc = 1

	return

/obj/machinery/elevator/devilscience/button_devilscience
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilscience/button_devilscience/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to Science Hall</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/devilscience/button_devilscience/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_devilscience_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_devilscience()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilscience"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilscience"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorscience"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorscience"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilscience_tickstomove*6)
			signal.data["tag"] = "elevatorscience"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return


//Elevator call button
/obj/machinery/elevator/devilscience/call_devilscience
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilscience/call_devilscience/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_science_moving)
		if(!elevator_science_loc)
			signal.data["tag"] = "elevatordevilscience"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/devilscience/call_devilscience/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_science_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_devilscience()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorscience"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorscience"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilscience_tickstomove*8)
			signal.data["tag"] = "elevatordevilscience"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatordevilscience"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return


//Space/DEVIL
var/elevator_space_loc = 1 //1=space 0=devil

//space TO DEVIL

var/elevator_space_tickstomove = 5
var/elevator_space_moving = 0

proc/move_elevator_space()
	if(elevator_space_moving)	return
	elevator_space_moving = 1
	spawn(elevator_space_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/space)
		toArea = locate(/area/shuttle/elevator/devilspace)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, NORTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_space_moving = 0
		if(elevator_space_loc)
			elevator_space_loc = 0
		else
			elevator_space_loc = 1

	return

/obj/machinery/elevator/space/button_space
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/space/button_space/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to DEVIL</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/space/button_space/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_space_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_space()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorspace"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorspace"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilspace"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilspace"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilspace_tickstomove*6)
			signal.data["tag"] = "elevatordevilspace"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return

//Elevator call button
/obj/machinery/elevator/space/call_space
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/space/call_space/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_space_moving)
		if(elevator_space_loc)
			signal.data["tag"] = "elevatorspace"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/space/call_space/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_space_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_space()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilspace"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilspace"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilspace_tickstomove*8)
			signal.data["tag"] = "elevatorspace"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatorspace"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return



//DEVIL TO space

var/elevator_devilspace_tickstomove = 5
var/elevator_devilspace_moving = 0

proc/move_elevator_devilspace()
	if(elevator_devilspace_moving)	return
	elevator_devilspace_moving = 1
	spawn(elevator_devilspace_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/devilspace)
		toArea = locate(/area/shuttle/elevator/space)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, SOUTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_devilspace_moving = 0

		if(elevator_space_loc)
			elevator_space_loc = 0
		else
			elevator_space_loc = 1

	return

/obj/machinery/elevator/devilspace/button_devilspace
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilspace/button_devilspace/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to space Hall</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/devilspace/button_devilspace/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_devilspace_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_devilspace()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilspace"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilspace"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorspace"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorspace"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilspace_tickstomove*6)
			signal.data["tag"] = "elevatorspace"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return


//Elevator call button
/obj/machinery/elevator/devilspace/call_devilspace
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilspace/call_devilspace/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_space_moving)
		if(!elevator_space_loc)
			signal.data["tag"] = "elevatordevilspace"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/devilspace/call_devilspace/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_space_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_devilspace()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorspace"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorspace"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilspace_tickstomove*8)
			signal.data["tag"] = "elevatordevilspace"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatordevilspace"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return


//Living/DEVIL
var/elevator_living_loc = 1 //1=living 0=devil

//living TO DEVIL

var/elevator_living_tickstomove = 5
var/elevator_living_moving = 0

proc/move_elevator_living()
	if(elevator_living_moving)	return
	elevator_living_moving = 1
	spawn(elevator_living_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/living)
		toArea = locate(/area/shuttle/elevator/devilliving)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, NORTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_living_moving = 0
		if(elevator_living_loc)
			elevator_living_loc = 0
		else
			elevator_living_loc = 1

	return

/obj/machinery/elevator/living/button_living
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/living/button_living/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to DEVIL</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/living/button_living/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_living_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_living()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorliving"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorliving"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilliving"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilliving"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilliving_tickstomove*6)
			signal.data["tag"] = "elevatordevilliving"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return

//Elevator call button
/obj/machinery/elevator/living/call_living
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/living/call_living/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_living_moving)
		if(elevator_living_loc)
			signal.data["tag"] = "elevatorliving"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/living/call_living/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_living_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_living()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilliving"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilliving"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilliving_tickstomove*8)
			signal.data["tag"] = "elevatorliving"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatorliving"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return



//DEVIL TO living

var/elevator_devilliving_tickstomove = 5
var/elevator_devilliving_moving = 0

proc/move_elevator_devilliving()
	if(elevator_devilliving_moving)	return
	elevator_devilliving_moving = 1
	spawn(elevator_devilliving_tickstomove*10)
		var/area/fromArea
		var/area/toArea

		fromArea = locate(/area/shuttle/elevator/devilliving)
		toArea = locate(/area/shuttle/elevator/living)

		fromArea.move_contents_to(toArea, /turf/simulated/shuttle/floor4, SOUTH)

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					shake_camera(M, 3, 1) // not a lot of shaking
		elevator_devilliving_moving = 0

		if(elevator_living_loc)
			elevator_living_loc = 0
		else
			elevator_living_loc = 1

	return

/obj/machinery/elevator/devilliving/button_devilliving
	name = "Elevator Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilliving/button_devilliving/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>High Speed Elevator: <b><A href='?src=\ref[src];move=1'>Move to living Hall</A></b></center><br>"

	user << browse("[dat]", "window=elevator;size=200x100")

/obj/machinery/elevator/devilliving/button_devilliving/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!elevator_devilliving_moving)
			usr << "\blue Elevator launcher charging. Brace yourself."
			move_elevator_devilliving()
		else
			usr << "\blue Elevator launcher already charging and will move shortly."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatordevilliving"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatordevilliving"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorliving"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorliving"
		signal.data["command"] = "unlock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilliving_tickstomove*6)
			signal.data["tag"] = "elevatorliving"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		return


//Elevator call button
/obj/machinery/elevator/devilliving/call_devilliving
	name = "Elevator Call Button"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "romos2"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1701
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

/obj/machinery/elevator/devilliving/call_devilliving/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/datum/signal/signal = new
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
	signal.transmission_method = 1 //radio signal

	if (!elevator_living_moving)
		if(!elevator_living_loc)
			signal.data["tag"] = "elevatordevilliving"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		else
			var/dat = "<center>High Speed Elevator: <b><br><A href='?src=\ref[src];move=1'>Call Elevator</A></b></center><br>"
			user << browse("[dat]", "window=callelevator;size=200x100")
	else
		usr << "\blue Elevator is already moving."

/obj/machinery/elevator/devilliving/call_devilliving/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])

		if (!elevator_living_moving)
			usr << "\blue The elevator has been called and will arrive shortly."
			move_elevator_devilliving()
		else
			usr << "\blue Elevator is already moving."

		var/datum/signal/signal = new
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)
		signal.transmission_method = 1 //radio signal

		signal.data["tag"] = "elevatorliving"
		signal.data["command"] = "close"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		signal.data["tag"] = "elevatorliving"
		signal.data["command"] = "lock"
		radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		spawn(elevator_devilliving_tickstomove*8)
			signal.data["tag"] = "elevatordevilliving"
			signal.data["command"] = "unlock"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			signal.data["tag"] = "elevatordevilliving"
			signal.data["command"] = "open"
			radio_connection.post_signal(src, signal, range = ELEVATOR_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return