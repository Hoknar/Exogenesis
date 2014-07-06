/obj/item/devices/binoculars
	name = "Binoculars"
	desc = "A pair of binoculars, so you can see further."
	icon = 'icons/obj/binoculars.dmi'
	icon_state = "binoculars"
	item_state = "icons/obj/binoculars.dmi"
	origin_tech = "materials=7"
	w_class = 2.0
	var/zoom = 0

/obj/item/devices/binoculars/dropped(mob/user)
	user.client.view = world.view

/obj/item/devices/binoculars/attack_self(mob/living/user as mob)
	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		usr << "You are unable to focus down the scope of the rifle."
		return
	if(!zoom && global_hud.darkMask[1] in usr.client.screen)
		usr << "Your welding equipment gets in the way of you looking down the scope"
		return
	if(!zoom && usr.get_active_hand() != src)
		usr << "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better."
		return

	if(usr.client.view == world.view)
		if(!usr.hud_used.hud_shown)
			usr.button_pressed_F12(1)	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
		usr.button_pressed_F12(1)
		usr.client.view = 12
		zoom = 1
	else
		usr.client.view = world.view
		if(!usr.hud_used.hud_shown)
			usr.button_pressed_F12(1)
		zoom = 0
	usr << "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>"
	return