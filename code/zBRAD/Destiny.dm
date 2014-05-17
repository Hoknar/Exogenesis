//////////////////////////////////////////////////////////////////////////DESTINY AREAS

/area/destiny/observation
	name = "\improper Observation Room"
	icon_state = "observatory"

/area/destiny/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/destiny/ai
	name = "\improper AI Core"
	icon_state = "ai"

/area/destiny/quarters/dormblocka
	name = "\improper Dorm Block A"
	icon_state = "Sleep"

/area/destiny/quarters/dormblockb
	name = "\improper Dorm Block B"
	icon_state = "Sleep"

/area/destiny/quarters/capt
	name = "\improper Captain Quarters"
	icon_state = "captain"

/area/destiny/quarters/hop
	name = "\improper Head of Personell Quarters"
	icon_state = "head_quarters"

/area/destiny/quarters/hos
	name = "\improper Head of Security Quarters"
	icon_state = "head_quarters"

/area/destiny/quarters/cmo
	name = "\improper Cheif Medical Quarters"
	icon_state = "CMO"

/area/destiny/quarters/rd
	name = "\improper Research Director Quarters"
	icon_state = "head_quarters"

/area/destiny/quarters/ce
	name = "\improper Chief Engineer Quarters"
	icon_state = "head_quarters"

/area/destiny/quarters/qm
	name = "\improper Quartermaster Quarters"
	icon_state = "quart"

/area/destiny/quarters/dorms
	name = "\improper Dorms"
	icon_state = "crew_quarters"

/area/destiny/halls/fore
	name = "\improper Fore Hall"
	icon_state = "hallF"

/area/destiny/halls/centralfore
	name = "\improper Central Fore Hall"
	icon_state = "hallC"

/area/destiny/halls/centralaft
	name = "\improper Central Aft Hall"
	icon_state = "hallC"

/area/destiny/halls/port
	name = "\improper Port Hall"
	icon_state = "hallP"

/area/destiny/halls/starboard
	name = "\improper Starboard Hall"
	icon_state = "hallS"

/area/destiny/halls/aft
	name = "\improper Aft Hall"
	icon_state = "hallA"

/area/destiny/halls/central
	name = "\improper Central Hall"
	icon_state = "entry"

/area/destiny/halls/research
	name = "\improper Research Hall"
	icon_state = "hallS"

/area/destiny/halls/aft
	name = "\improper Aft Hall"
	icon_state = "hallA"

/area/destiny/maint/aft
	name = "\improper Aft Maintenance"
	icon_state = "amaint"

/area/destiny/maint/fore
	name = "\improper Fore Maintenance"
	icon_state = "fmaint"

/area/destiny/maint/port
	name = "\improper Port Maintenance"
	icon_state = "pmaint"

/area/destiny/maint/stbd
	name = "\improper Starboard Maintenance"
	icon_state = "smaint"

/area/destiny/maint/cent
	name = "\improper Central Maintenance"
	icon_state = "maintcentral"

/area/destiny/general/bathroom
	name = "\improper Bathrooms"
	icon_state = "toilet"

/area/destiny/general/bar
	name = "\improper Bar"
	icon_state = "bar"

/area/destiny/general/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/destiny/general/hydro
	name = "\improper Hydroponics"
	icon_state = "hydro"

/area/destiny/general/chapel
	name = "\improper Chapel"
	icon_state = "chapel"

/area/destiny/general/tools
	name = "\improper Tool Room"
	icon_state = "primarystorage"

/area/destiny/general/janitor
	name = "\improper Janitor"
	icon_state = "janitor"

/area/destiny/general/disposals
	name = "\improper Disposals"
	icon_state = "disposal"

/area/destiny/medical/medbay
	name = "\improper Med Bay"
	icon_state = "medbay"

/area/destiny/security/detective
	name = "\improper Detective"
	icon_state = "detective"

/area/destiny/security/outer
	name = "\improper Outer Security"
	icon_state = "security"

/area/destiny/security/inner
	name = "\improper Inner Security"
	icon_state = "security"

/area/destiny/security/hos
	name = "\improper Head of Security"
	icon_state = "sec_hos"

/area/destiny/security/warden
	name = "\improper Warden and Armoury"
	icon_state = "Warden"


/area/destiny/engineering/main
	name = "\improper Main Engineering"
	icon_state = "engine"

/area/destiny/engineering/control
	name = "\improper Engineering Control"
	icon_state = "engine_control"

/area/destiny/engineering/ce
	name = "\improper Chief Engineer Office"
	icon_state = "engine_control"

/area/destiny/engineering/atmos
	name = "\improper Atmos Storage"
	icon_state = "atmos"

/area/destiny/research/general
	name = "\improper General Research"
	icon_state = "prototype_engine"

/area/destiny/research/toxins
	name = "\improper Toxins"
	icon_state = "toxlab"

/area/destiny/research/toxstorage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/destiny/research/robotics
	name = "\improper Robotics"
	icon_state = "mechbay"

/area/destiny/research/analysis
	name = "\improper Destructive Analysis"
	icon_state = "bluenew"

/area/destiny/research/rd
	name = "\improper Research Director"
	icon_state = "head_quarters"

/area/destiny/research/server
	name = "\improper RnD Server Room"
	icon_state = "server"

/area/destiny/research/xeno
	name = "\improper Xeno Biology"
	icon_state = "green"

/area/destiny/research/tech
	name = "\improper Tech Storage"
	icon_state = "engine_storage"

// Add these below without comment part to end of SS13 list in Space Station 13 areas.dm (line 1839)


//DESTINY
var/list/destiny_areas = list (
	/area/destiny/observation,
	/area/destiny/bridge,
	/area/destiny/ai,
	/area/destiny/quarters/dormblocka,
	/area/destiny/quarters/dormblockb,
	/area/destiny/quarters/capt,
	/area/destiny/quarters/hop,
	/area/destiny/quarters/hos,
	/area/destiny/quarters/cmo,
	/area/destiny/quarters/rd,
	/area/destiny/quarters/ce,
	/area/destiny/quarters/qm,
	/area/destiny/quarters/dorms,
	/area/destiny/halls/fore,
	/area/destiny/halls/centralfore,
	/area/destiny/halls/centralaft,
	/area/destiny/halls/port,
	/area/destiny/halls/starboard,
	/area/destiny/halls/aft,
	/area/destiny/halls/central,
	/area/destiny/halls/research,
	/area/destiny/halls/aft,
	/area/destiny/maint/aft,
	/area/destiny/maint/fore,
	/area/destiny/maint/port,
	/area/destiny/maint/stbd,
	/area/destiny/maint/cent,
	/area/destiny/general/bathroom,
	/area/destiny/general/bar,
	/area/destiny/general/kitchen,
	/area/destiny/general/hydro,
	/area/destiny/general/chapel,
	/area/destiny/general/tools,
	/area/destiny/general/janitor,
	/area/destiny/general/disposals,
	/area/destiny/medical/medbay,
	/area/destiny/security/detective,
	/area/destiny/security/outer,
	/area/destiny/security/inner,
	/area/destiny/security/hos,
	/area/destiny/security/warden,
	/area/destiny/engineering/main,
	/area/destiny/engineering/control,
	/area/destiny/engineering/ce,
	/area/destiny/engineering/atmos,
	/area/destiny/research/general,
	/area/destiny/research/toxins,
	/area/destiny/research/toxstorage,
	/area/destiny/research/robotics,
	/area/destiny/research/analysis,
	/area/destiny/research/rd,
	/area/destiny/research/server,
	/area/destiny/research/xeno,
	/area/destiny/research/tech,
)


////Game/machinery/telecomms/presets.dm
//add    , "D_relay"     to hubs


/obj/machinery/telecomms/relay/preset/destiny
	id = "Destiny Relay"
	hide = 1
	toggled = 1
	autolinkers = list("D_relay")


/obj/machinery/computer/destiny_alert
	name = "Destiny Alert Computer"
	desc = "Used to access the ship's automated alert system."
	icon_state = "alert:0"
	circuit = "/obj/item/weapon/circuitboard/stationalert"
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())


	attack_ai(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)
		return


	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)
		return


	interact(mob/user)
		usr.set_machine(src)
		var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
		dat += "<A HREF='?src=\ref[user];mach_close=alerts'>Close</A><br><br>"
		for (var/cat in src.alarms)
			dat += text("<B>[]</B><BR>\n", cat)
			var/list/L = src.alarms[cat]
			if (L.len)
				for (var/alarm in L)
					var/list/alm = L[alarm]
					var/area/A = alm[1]
					var/list/sources = alm[3]
					dat += "<NOBR>"
					dat += "&bull; "
					dat += "[A.name]"
					if (sources.len > 1)
						dat += text(" - [] sources", sources.len)
					dat += "</NOBR><BR>\n"
			else
				dat += "-- All Systems Nominal<BR>\n"
			dat += "<BR>\n"
		user << browse(dat, "window=alerts")
		onclose(user, "alerts")


	Topic(href, href_list)
		if(..())
			return
		return


	proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
		if(stat & (BROKEN))
			return
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/sources = alarm[3]
				if (!(alarmsource in sources))
					sources += alarmsource
				return 1
		var/obj/machinery/camera/C = null
		var/list/CL = null
		if (O && istype(O, /list))
			CL = O
			if (CL.len == 1)
				C = CL[1]
		else if (O && istype(O, /obj/machinery/camera))
			C = O
		L[A.name] = list(A, (C) ? C : O, list(alarmsource))
		return 1


	proc/cancelAlarm(var/class, area/A as area, obj/origin)
		if(stat & (BROKEN))
			return
		var/list/L = src.alarms[class]
		var/cleared = 0
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs  = alarm[3]
				if (origin in srcs)
					srcs -= origin
				if (srcs.len == 0)
					cleared = 1
					L -= I
		return !cleared


	process()
		if(stat & (BROKEN|NOPOWER))
			icon_state = "atmos0"
			return
		var/active_alarms = 0
		for (var/cat in src.alarms)
			var/list/L = src.alarms[cat]
			if(L.len) active_alarms = 1
		if(active_alarms)
			icon_state = "alert:2"
		else
			icon_state = "alert:0"
		..()
		return