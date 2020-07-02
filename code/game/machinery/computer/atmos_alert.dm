/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Used to access the station's atmospheric sensors."
	circuit = /obj/item/circuitboard/atmos_alert
	var/ui_x = 350
	var/ui_y = 300
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = ATMOS_FIRE_FREQ
	var/datum/radio_frequency/radio_connection

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	set_frequency(receive_frequency)

/obj/machinery/computer/atmos_alert/Destroy()
	SSradio.remove_object(src, receive_frequency)
	return ..()

/obj/machinery/computer/atmos_alert/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/atmos_alert/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AtmosAlertConsole", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/atmos_alert/tgui_data(mob/user)
	var/list/data = list()

	data["priority"] = list()
	for(var/zone in priority_alarms)
		data["priority"] += zone
	data["minor"] = list()
	for(var/zone in minor_alarms)
		data["minor"] += zone

	return data

/obj/machinery/computer/atmos_alert/tgui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear")
			var/zone = params["zone"]
			if(zone in priority_alarms)
				to_chat(usr, "<span class='notice'>Priority alarm for [zone] cleared.</span>")
				priority_alarms -= zone
				. = TRUE
			if(zone in minor_alarms)
				to_chat(usr, "<span class='notice'>Minor alarm for [zone] cleared.</span>")
				minor_alarms -= zone
				. = TRUE
	update_icon()

/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = SSradio.add_object(src, receive_frequency, RADIO_ATMOSIA)

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity)
		return

	minor_alarms -= zone
	priority_alarms -= zone
	if(severity == "severe")
		priority_alarms += zone
	else if (severity == "minor")
		minor_alarms += zone
	update_icon()

/obj/machinery/computer/atmos_alert/update_icon()
	if(priority_alarms.len)
		icon_screen = "alert:1"
	else
		icon_screen = "alert:0"
	..()
