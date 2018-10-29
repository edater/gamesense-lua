--local variables for API. Automatically generated by https://github.com/simpleavaster/gslua/blob/master/authors/sapphyrus/generate_api.lua 
local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_gradient, client_set_event_callback, client_screen_size, client_draw_text, client_visible = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_gradient, client.set_event_callback, client.screen_size, client.draw_text, client.visible 
local client_visible, client_exec, client_draw_circle, client_delay_call, client_world_to_screen, client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.visible, client.exec, client.draw_circle, client.delay_call, client.world_to_screen, client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_all, entity_set_prop, entity_get_player_weapon, entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_all, entity.set_prop, entity.get_player_weapon, entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_mapname, globals_tickcount, globals_realtime, globals_absoluteframetime, globals_tickinterval, globals_curtime, globals_frametime, globals_maxplayers = globals.mapname, globals.tickcount, globals.realtime, globals.absoluteframetime, globals.tickinterval, globals.curtime, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
--end of local variables 

local table_concat = table.concat
local table_insert = table.insert
local to_number = tonumber
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local table_remove = table.remove
local string_format = string.format

local delay = 0.03
local buy_at, buy_as_600ms_at
local buy_command = ""

local primary_weapons = {
	{name='-', command=""},
	{name='AWP', command="buy awp; "},
	{name='Auto-Sniper', command="buy scar20; buy g3sg1; "},
	{name='Scout', command="buy ssg08; "},
	{name='Negev', command="buy negev; "},
	{name='SG553 / AUG', command="buy sg553; buy aug; "}
}

local secondary_weapons = {
	{name='-', command=""},
	{name='R8 Revolver / Deagle', command="buy deagle; "},
	{name='Dual Berettas', command="buy elite; "},
	{name='FN57 / Tec9 / CZ75-Auto', command="buy fn57; "},
	{name='P250', command="buy p250;"}
}

local gear_weapons = {
	{name='Kevlar', command="buy vest; "},
	{name='Helmet', command="buy vesthelm; "},
	{name='Defuse Kit', command="buy defuser; "},
	{name='Grenade', command="buy hegrenade; "},
	{name='Molotov', command="buy incgrenade; "},
	{name='Smoke', command="buy smokegrenade; "},
	{name='Flashbang (x2)', command="buy flashbang; "},
	{name='Taser', command="buy taser; "},
}

local function get_names(table)
	local names = {}
	for i=1, #table do
		table_insert(names, table[i]["name"])
	end
	return names
end

local function get_command(table, name)
	for i=1, #table do
		if table[i]["name"] == name then
			return table[i]["command"]
		end
	end
end

local function get_weapons(player)
	local weapons = {}
	for i=0, 64 do
		local weapon = entity_get_prop(player, "m_hMyWeapons", i)
		if weapon ~= nil then
			table_insert(weapons, weapon)
		end
	end
	return weapons
end

local function has_weapon(player, weapon_name)
	for i=0, 64 do
		local weapon = entity_get_prop(player, "m_hMyWeapons", i)
		if weapon ~= nil and entity_get_classname(weapon) == weapon_name then
			return true
		end
	end
	return false
end

local buybot_enabled = ui_new_checkbox("MISC", "Miscellaneous", "Auto-Buy")
local buybot_primary = ui_new_combobox("MISC", "Miscellaneous", "Auto-Buy: Primary", get_names(primary_weapons))
local buybot_pistol = ui_new_combobox("MISC", "Miscellaneous", "Auto-Buy: Secondary", get_names(secondary_weapons))
local buybot_gear = ui_new_multiselect("MISC", "Miscellaneous", "Auto-Buy: Gear", get_names(gear_weapons))

local function on_enabled_change()
	local enabled = ui_get(buybot_enabled)
	ui_set_visible(buybot_primary, enabled)
	ui_set_visible(buybot_pistol, enabled)
	ui_set_visible(buybot_gear, enabled)
end
ui.set_callback(buybot_enabled, on_enabled_change)
on_enabled_change()

local function buy(command)
	--client.log("BUYING AT ", globals_tickcount())
	client_exec(command)
end

local function buy_as_600ms(e)
	--right now we would have 600ms ping, we need to wait 600-ping to be able to buy

	if not ui_get(buybot_enabled) then
		return
	end

	local primary = ui_get(buybot_primary)
	local pistol = ui_get(buybot_pistol)
	local gear = ui_get(buybot_gear)

	local commands = {}
	local primary_command = ""

	if not (primary == "Auto-Sniper" and has_weapon(entity_get_local_player(), "CWeaponSCAR20")) then
		table_insert(commands, get_command(primary_weapons, primary))
		primary_command = get_command(primary_weapons, primary)
	end
	table_insert(commands, get_command(secondary_weapons, pistol))
	
	for i=1, #gear do
		table_insert(commands, get_command(gear_weapons, gear[i]))
	end

	table_insert(commands, "use weapon_knife;")

	local command = table_concat(commands, "")
	local delay = 0.6 - client_latency() + 0.1

	--client.log("BUY AS 600MS")
	--client.log("TOTAL   ", delay)

	buy_at = globals_realtime() + delay
	buy_command = command
	--client_delay_call(delay-0.25, buy, get_command(primary_weapons, primary))
	--client_delay_call(delay-0.20, buy, get_command(primary_weapons, primary))
	client_delay_call(delay-0.15, buy, command)
	client_delay_call(delay-0.10, buy, primary_command)
	client_delay_call(delay-0.05, buy, primary_command)
	--client_delay_call(delay+0.01, buy, command)
end

local function run_buybot()
	local delay = tonumber(client_get_cvar("mp_round_restart_delay")) - 0.6
	delay = math_max(0, delay)
	--client.log("buy as 600 ms in ", delay)
	buy_as_600ms_at = globals_realtime() + delay
end

local function on_paint(ctx)
	local realtime = globals_realtime()
	if buy_as_600ms_at ~= nil and buy_as_600ms_at <= realtime then
		buy_as_600ms()
		buy_as_600ms_at = nil
	end
	if buy_at ~= nil and buy_at <= realtime then
		buy(buy_command)
		buy_at = nil
	end
end

client_set_event_callback("round_end", run_buybot)
client_set_event_callback("paint", on_paint)

--client_set_event_callback("player_spawn", run_buybot)
