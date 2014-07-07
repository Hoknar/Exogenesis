/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	species_restricted = null
	var/magpulse = 0
	flags = NOSLIP //disabled by default


	verb/toggle()
		set name = "Toggle Magboots"
		set category = "Object"
		set src in usr
		if(usr.stat)
			return
		if(src.magpulse)
			src.flags &= ~NOSLIP
			src.slowdown = SHOES_SLOWDOWN
			src.magpulse = 0
			icon_state = "magboots0"
			usr << "You disable the mag-pulse traction system."
		else
			src.flags |= NOSLIP
			src.slowdown = 2
			src.magpulse = 1
			icon_state = "magboots1"
			usr << "You enable the mag-pulse traction system."
		usr.update_inv_shoes()	//so our mob-overlays update


	examine()
		set src in view()
		..()
		var/state = "disabled"
		if(src.flags&NOSLIP)
			state = "enabled"
		usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/shoes/magboots/uhsmarine
	name = "Combat Boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags = NOSLIP
	siemens_coefficient = 0.6

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE