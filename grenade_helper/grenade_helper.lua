local grenades_data = require "grenade_helper_data"
local grenades_all = grenades_data.get()

--math.fact = function(b)
--		if(b==1)or(b==0) then
--				return 1
--		end
--		local e=1
--		for c=b,1,-1 do
--				e=e*c
--		end
--		return e
--end

--math.pow = function(b,p)
--		local e=b
--		if(p==0) then
--				return 1
--		end
--		if(p<0) then
--				p=p*(-1)
--		end
--		for c=p,2,-1 do
--				e=e*b
--		end
--		return e
--end

--math.correctRadians = function(value)
--		while value > math.pi*2 do
--				value = value - math.pi * 2
--		end           
--		while value < -math.pi*2 do
--				value = value + math.pi * 2
--		end 
--		return value
--end

--local original_math_cos = math.cos

--math.cos = function(b,p)
--	ocos = original_math_cos(b)
--	if type(ocos) == "number" then
--		return ocos
--	end
--	local e=1
--	b = math.correctRadians(b)
--	p=p or 10
--	for i=1,p do
--		e=e+(math.pow(-1,i)*math.pow(b,2*i)/math.fact(2*i))
--	end
--	return e
--end

local last_move = 0
local is_in_position = false
local autorelease_possible = true

--local variables for API. Automatically generated by https://github.com/simpleavaster/gslua/blob/master/authors/sapphyrus/generate_api.lua 
local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position, client_color_log = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position, client.color_log 
local client_draw_circle, client_draw_text, client_visible, client_exec, client_delay_call, client_trace_line, client_world_to_screen, client_draw_hitboxes = client.draw_circle, client.draw_text, client.visible, client.exec, client.delay_call, client.trace_line, client.world_to_screen, client.draw_hitboxes 
local client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_all, entity_set_prop, entity_get_player_weapon, entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_all, entity.set_prop, entity.get_player_weapon, entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_mapname, globals_tickcount, globals_realtime, globals_absoluteframetime, globals_tickinterval, globals_curtime, globals_frametime, globals_maxplayers = globals.mapname, globals.tickcount, globals.realtime, globals.absoluteframetime, globals.tickinterval, globals.curtime, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan, math_fmod = math.ceil, math.tan, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan, math.fmod 
local math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub 
--end of local variables 

local command_name = "r_eyeshift_z"

local enabled_reference = ui.new_multiselect("VISUALS", "Other ESP", "Grenade assist", {"Smoke", "Flashbang", "Grenade", "Molotov", "Wallbangs"})
local color_reference = ui.new_color_picker("VISUALS", "Other ESP", "Grenade assist", 60, 60, 255, 255)
local secondary_color_reference = ui.new_color_picker("VISUALS", "Other ESP", "Grenade assist (secondary)", 158, 60, 255, 200)

local autorelease_reference = ui.new_hotkey("VISUALS", "Other ESP", "Grenade assist automatic release")
local saving_enabled_reference = ui.new_checkbox("VISUALS", "Other ESP", "Grenade helper saving (" .. command_name .. ")")
local airstrafe_reference = ui.reference("MISC", "Miscellaneous", "Air strafe")

local shorten_name = true

local box_size = 32
local max_distance = 600
local max_distance_meta = 450
local aimpoint_distance = 20
local aimpoint_size = 6
local full_alpha_distance = 200
local position_tolerance = 2
local hud_tolerance = 12
local yaw_tolerance = 5
local weapon = ""
local text_offset_add = 24
local visible_only = false

local console_names = {
	CSmokeGrenade="weapon_smokegrenade", 
	CSensorGrenade="weapon_smokegrenade",
	CFlashbang="weapon_flashbang", 
	CDecoyGrenade="weapon_flashbang", 
	CIncendiaryGrenade="weapon_molotov", 
	CMolotovGrenade="weapon_molotov", 
	CHEGrenade="weapon_hegrenade",
	CWeaponAWP="weapon_wallbang",
	CWeaponSCAR20="weapon_wallbang",
	CWeaponG3SG1="weapon_wallbang",
	CWeaponSSG08="weapon_wallbang",
	CDEagle="weapon_wallbang",
	CAK47="weapon_wallbang_normal",
	CWeaponSG556="weapon_wallbang_normal",
	CWeaponGalilAR="weapon_wallbang_normal",
	CWeaponM4A1="weapon_wallbang_normal",
	CWeaponM4A4="weapon_wallbang_normal",
	CWeaponAug="weapon_wallbang_normal",
	CWeaponFamas="weapon_wallbang_normal",
	CWeaponTec9="weapon_wallbang_normal",
}

local function class_to_console_name(class)
	return console_names[class]
end

local function contains(table, val)
	for i=1,#table do
		if table[i] == val then 
			return true
		end
	end
	return false
end

local function distance(x1, y1, x2, y2)
	return math_sqrt((x2-x1)^2 + (y2-y1)^2)
end

local function distance3d(x1, y1, z1, x2, y2, z2)
	return math_sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1))
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math_floor(num * mult + 0.5) / mult
end

local function draw_indicator_circle(ctx, x, y, r, g, b, a, percentage, outline)
	local outline = outline or true
	local radius = 9
	local start_degrees = 0

	-- draw outline
	if outline then
		client_draw_circle_outline(ctx, x, y, 0, 0, 0, 200, radius, start_degrees, 1.0, 5)
	end
	-- draw inner circle
	client_draw_circle_outline(ctx, x, y, r, g, b, a, radius-1, start_degrees, percentage, 3)
end

local function on_enabled_changed()
	local enabled = ui_get(enabled_reference)
	ui_set_visible(autorelease_reference, #enabled > 0)
end

ui.set_callback(enabled_reference, on_enabled_changed)

local function ticks_to_seconds(ticks)
	return ticks*1/64
end

local function get_tickrate()
	return 1/globals_tickinterval()
end

local function freeze_sensitivity(reset_delay)
	reset_delay = reset_delay or 0.2
	local sensitivity = client_get_cvar("sensitivity")
	if tonumber(sensitivity) > 0.000100 then
		client_exec("sensitivity 0")
		client_delay_call(reset_delay, client_exec, "sensitivity ", sensitivity)
	end
end

local function on_player_connect_full(e)
	if client_userid_to_entindex(e.userid) == entity_get_local_player() then
		ui_set(saving_enabled_reference, false)
	end
end
client.set_event_callback("player_connect_full", on_player_connect_full)

local function on_paint(ctx)
	local tickcount = globals_tickcount()
	local is_in_position_temp = false

	local enabled = ui_get(enabled_reference)

	if #enabled == 0 then
		return
	end

	local map = globals_mapname()
	local grenades_all = grenades_data.get()
	local grenades_map = grenades_all[map]

	local local_player = entity_get_local_player()
	local weapon = entity_get_player_weapon(local_player)
	local weapon_name = class_to_console_name(entity_get_classname(weapon))

	if ui_get(saving_enabled_reference) and weapon_name ~= nil then
		local command = client_get_cvar(command_name)
		if not (command == "0" or command == "1") then
			local words = {}
			for word in string.gmatch(command, "%S+") do table.insert(words, word) end

			client.exec(command_name .. " 0")
			if command == "" or command == " " or command == '""' or command == nil or #words < 2 then
				client_log("Usage: ", command_name, " <THROWTYPE> <NAME>")
				client_log("Example: ", command_name, " NORMAL CT Spawn to Long")
				client_log("Valid Throw Types: NORMAL, JUMP, RUN, RUNJUMP (Use WALLBANG for wallbangs)")
				return
			end

			local name = ""
			for i=1, #words-1 do
				word = words[i+1]
				if name == "" then
					name = word
				else
					name = name .. " " .. word
				end
			end

			local localX, localY, localZ = entity_get_prop(entity_get_local_player(), "m_vecOrigin")
			local localPitch, localYaw, localRoll = client_camera_angles()
			local voZ = entity_get_prop(entity_get_local_player(), "m_vecViewOffset[2]")

			local x, y, z, pitch, yaw = round(localX, 2), round(localY, 2), round(localZ, 2), round(localPitch, 2), round(localYaw, 2)
			z = z + voZ

			local duck_string = ""
			if entity_get_prop(local_player, "m_flDuckAmount") == 1 then
				duck_string = '	"duck": true, ' .. "\n"
			end

			client_log("Please copy this to clipboard:", 
				"\n{\n", 
				'	"map": "', globals_mapname(), '",', "\n",
				'	"name": "', name, '",', "\n",
				'	"description": "Manually added.",', "\n",
				'	"grenade": "', weapon_name, '",', "\n",
				'	"tickrate": "', get_tickrate(), '",', "\n",
				'	"throwType": "', string_upper(words[1]), '",', "\n",
				duck_string,
				'	"x": "', x, '",', "\n",
				'	"y": "', y, '",', "\n",
				'	"z": "', z, '",', "\n",
				'	"pitch": "', pitch, '",', "\n",
				'	"yaw": "', yaw, '"', "\n",
				'}'
			)
		end
	end

	if weapon_name == nil or grenades_map == nil then
		autorelease_possible = true
		return
	end

	if not (
		(weapon_name == "weapon_smokegrenade" and contains(enabled, "Smoke")) or
		(weapon_name == "weapon_flashbang" and contains(enabled, "Flashbang")) or
		(weapon_name == "weapon_hegrenade" and contains(enabled, "Grenade")) or
		(weapon_name == "weapon_molotov" and contains(enabled, "Molotov")) or
		((weapon_name == "weapon_wallbang" or weapon_name == "weapon_wallbang_normal") and contains(enabled, "Wallbangs"))
	)
	then
		return
	end

	local localX, localY, localZ = entity_get_prop(entity_get_local_player(), "m_vecOrigin")
	local localpitch, localyaw = client_camera_angles()
	local screen_width, screen_height = client_screen_size()
	local voZ = entity_get_prop(entity_get_local_player(), "m_vecViewOffset[2]")
	local tickrate = get_tickrate()

	local text_offsets = {}

	local autorelease = ui_get(autorelease_reference)
	if not autorelease then
		autorelease_possible = true
	end
	if not autorelease_possible and weapon ~= nil then
		if entity_get_prop(weapon, "m_bPinPulled") ~= 1 then
			autorelease_possible = true
		end
	end
	if autorelease and not autorelease_possible then
		autorelease = false
	end

	local hudX = 15
	local hudY = screen_height/2
	localZ = localZ + voZ

	for i=1, #grenades_map do
		local grenade_meta = grenades_map[i]

		local name, grenade, throw_type, x, y, z, pitch, yaw = grenade_meta["name"], grenade_meta["grenade"], grenade_meta["throwType"], grenade_meta["x"], grenade_meta["y"], grenade_meta["z"], grenade_meta["pitch"], grenade_meta["yaw"]

		if shorten_name then
			local words = {}
			for word in string_gmatch(name, "%S+") do table.insert(words, word) end
			local name_array = {}

			local to_hit = false
			for i=1, #words do
				if to_hit then
					table_insert(name_array, words[i])
				end
				if string_lower(words[i]) == "to" then
					to_hit = true
				end
			end

			if #name_array > 0 then
				name = table_concat(name_array, " ")
			end
		end

		local r, g, b, a = ui_get(color_reference)
		local r_secondary, g_secondary, b_secondary, a_secondary = ui_get(secondary_color_reference)

		local voZTemp = 64
		if grenade_meta["duck"] then
			voZTemp = 46
		end

		local tickrate_matches = true
		if grenade_meta["tickrate"] ~= nil then
			tickrate_matches = tonumber(grenade_meta["tickrate"]) == tickrate
		end

		local a_bottom = a
		local zText = z - voZTemp/2

		grenade = grenade == "weapon_incendiary" and "weapon_molotov" or grenade --fix invalid weapon name

		if grenade == weapon_name or grenade == "weapon_wallbang_normal" and weapon_name == "weapon_wallbang" and tickrate_matches then

			local distance_pos = distance(localX, localY, x, y)
			if throw_type == "WALLBANG" then
				throw_type = nil
			end

			if distance_pos < max_distance + full_alpha_distance then
				if distance_pos < full_alpha_distance then
					a = 255
				else
					a = (1 - (distance_pos / (max_distance + full_alpha_distance))) * 255
				end

				if distance_pos < max_distance_meta then
					a_bottom = (1 - (distance_pos / (max_distance_meta))) * 255
				else
					a_bottom = 0
				end

				local worldX, worldY = client_world_to_screen(ctx, x, y, z)
				local worldXText, worldYText = client_world_to_screen(ctx, x, y, zText)
				local worldXHead, worldYHead = client_world_to_screen(ctx, x, y, z)
				local hudYTemp = hudY

				local can_see = visible_only == false or client_visible(x, y, z)

				local text_offset = text_offsets[round(x) .. " " .. round(y) .. " " .. round(z)]
				local text_offset_add = text_offset_add

				if text_offset == nil then
					text_offset = 0
				else
					hudYTemp = hudY + text_offset*2
					if worldYText ~= nil then
						worldYText = worldYText + text_offset
					end
				end

				if (name == "Corner to B Main Entry" or true) and can_see then
					if worldXText ~= nil and worldYText ~= nil then
						local a_modifier = 1
						if distance_pos < position_tolerance then
							a_modifier = distance_pos / position_tolerance
						end
						client_draw_text(ctx, worldXText, worldYText, r, g, b, a*a_modifier, "c", 0, name)
						if a_bottom > 0 then
							if throw_type ~= nil then
								client_draw_text(ctx, worldXText, worldYText+12, r, g, b, a_bottom*a_modifier, "c-", 0, throw_type, " THROW")
							end

							if worldX ~= nil then
								local bottom_dot_alpha = (a_bottom*2) - a_bottom*1.5
								bottom_dot_alpha = math_max(0, bottom_dot_alpha)
								--client_draw_rectangle(ctx, worldX-aimpoint_size/2, worldY-aimpoint_size/2, aimpoint_size, aimpoint_size, r_secondary, g_secondary, b_secondary, bottom_dot_alpha*(1-a_modifier))
							end
						end
						if 50 > a_bottom then
							text_offset_add = text_offset_add/1.8 * (a_bottom/50) + text_offset_add-text_offset_add/1.8
						end
						--client_draw_text(ctx, worldX, worldY+24, 255, 255, b, a_bottom, "c", 0, "yaw ", pitch, " pitch ", yaw)
					end

					yaw = math_rad(yaw + 180)
					pitch = math_rad(pitch)

					--yaw, pitch = round(yaw, 2), round(pitch, 2)
					yawSin, yawCos, pitchTan = math_sin(yaw), math_cos(yaw), math_tan(pitch)

					local xTarget = x - math_cos(yaw) * aimpoint_distance
					local yTarget = y - math_sin(yaw) * aimpoint_distance
					local zTarget = z - math_tan(pitch) * aimpoint_distance

					local xTarget2 = x - math_cos(yaw) * 50000
					local yTarget2 = y - math_sin(yaw) * 50000
					local zTarget2 = z - math_tan(pitch) * 50000

					local can_see

					local worldXTarget, worldYTarget
					if xTarget ~= nil and yTarget ~= nil and zTarget ~= nil then
						worldXTarget, worldYTarget = client_world_to_screen(ctx, xTarget, yTarget, zTarget)
						worldXTargetDot, worldYTargetDot = client_world_to_screen(ctx, xTarget2, yTarget2, zTarget2)
					end

					local draw_target = false
					local draw_line = true
					local draw_hud = false
					local current_in_position = false
					local aHud, aHudGreen, aTargetMultiplier = 0, 0, 0
					local target_r, target_g, target_b = 0, 0, 0
					local viewangles_distance

					local throw_strength = grenade_meta["throwStrength"] or 1
					local viewangles_distance_max = grenade_meta["viewAnglesDistanceMax"] or 0.22
					local extra_info_text = ""
					local extra_info = {}

					if throw_strength == 0.5 then table_insert(extra_info, "Right / Left Click") end
					if throw_strength == 0 then table_insert(extra_info, "Right Click") end
					if grenade_meta["duck"] then table_insert(extra_info, "Duck") end

					local extra_info_text = #extra_info > 0 and " (" .. table_concat(extra_info, ", ") .. ")" or ""

					if distance_pos < hud_tolerance then
						
						draw_hud = true
						draw_line = true
						draw_target = true
						aHud = ((1 - (distance_pos / hud_tolerance)) * 255)
						aTargetMultiplier = 0.1
						target_r, target_g, target_b = 255, 255, 255

						if distance_pos < position_tolerance then
							aHudGreen = (1 - (distance_pos / (position_tolerance))) * 255
							aTargetMultiplier = aHudGreen / 255
							if aHudGreen > 250 then
								is_in_position_temp = true
								current_in_position = true
							elseif aHudGreen > 245 then
								current_in_position = true
							end
							target_r, target_g, target_b = r, g, b
							draw_line = false
							can_see = true

							viewangles_distance = distance(grenade_meta["yaw"], grenade_meta["pitch"], localyaw, localpitch)

							if autorelease then
								local duck_pressed = true
								if grenade_meta["duck"] then
									duck_pressed = entity_get_prop(local_player, "m_flDuckAmount") == 1
								end
								if viewangles_distance < viewangles_distance_max and duck_pressed then
									--client.log("setang ", grenade_meta["pitch"], " ", grenade_meta["yaw"], " 0")
									--client.log(entity_get_prop(weapon, "m_flThrowStrength"), " equals ", throw_strength)
									if entity_get_prop(weapon, "m_bPinPulled") == 1 and entity_get_prop(weapon, "m_flThrowStrength") == throw_strength then
										autorelease_possible = false

										local freeze_duration = 0.15
										local run_duration = grenade_meta["runDuration"] or 20
										freeze_sensitivity(freeze_duration + ticks_to_seconds(run_duration))

										if grenade_meta["duck"] then
											client_exec("+duck;")
											client_delay_call(freeze_duration + ticks_to_seconds(run_duration), client_exec, "-duck;")
										end

										if throw_type == "JUMP" then
											client_exec("+jump; -attack; -attack2")
											client_delay_call(ticks_to_seconds(16), client_exec, "-jump")
										elseif throw_type == "RUN" then
											client_exec("+forward; -speed;")
											client_delay_call(ticks_to_seconds(run_duration), client_exec, "-attack; -attack2; -jump")
											client_delay_call(ticks_to_seconds(run_duration+9), client_exec, "-forward")
										elseif throw_type == "RUNJUMP" then
											client_exec("+forward; -speed;")
											client_delay_call(ticks_to_seconds(run_duration), client_exec, "+jump; -attack; -attack2;")
											client_delay_call(ticks_to_seconds(run_duration+9), client_exec, "-jump;")
											client_delay_call(ticks_to_seconds(run_duration+11), client_exec, "-forward")
										else
											client_exec("-attack; -attack2")
										end
										local airstrafe = ui_get(airstrafe_reference)
										if airstrafe then
											ui_set(airstrafe_reference, false)
											client_delay_call(1+ticks_to_seconds(run_duration+16), ui_set, airstrafe_reference, true)
										end
									end
								else
									if 255-aHudGreen < 10 and autorelease_possible then
										client_exec("-forward; -back; -moveleft; -moveright;")
									end
								end
							end
						end
					end

					text_offsets[round(x) .. " " .. round(y) .. " " .. round(z)] = text_offset + text_offset_add
					local is_overlaying = (is_in_position and not current_in_position)
					--client.log(is_overlaying)
					if not is_overlaying then
						if can_see then

							if draw_hud then
								local aHudTemp = math_max(aHud - aHudGreen, 0)
								if aHudTemp > 0 and not is_overlaying then
									draw_indicator_circle(ctx, hudX+10, hudYTemp+14, r, g, b, aHudTemp, 0)
									client_draw_text(ctx, hudX+24, hudYTemp, 255, 255, 255, aHudTemp, "+", 0, name)
								end
								if throw_type ~= nil and not is_overlaying then
									client_draw_text(ctx, hudX, hudYTemp+25, 255, 255, 255, aHud, "", 0, throw_type, " THROW", extra_info_text)
								end
								if aHudGreen > 0 then
									--client_draw_text(ctx, hudX, hudYTemp, r, g, b, aHudGreen, "+", 0, name)
									local percentage = aHudGreen/255
									if percentage > 0.96 then percentage = 1 end
									draw_indicator_circle(ctx, hudX+10, hudYTemp+14, r, g, b, a, percentage, false)
									client_draw_text(ctx, hudX+24, hudYTemp, r, g, b, aHudGreen, "+", 0, name)

									if ui_get(saving_enabled_reference) then
										client_draw_text(ctx, hudX, hudYTemp+36, 255, 255, 255, 255, nil, 0, 
											"runDuration=", grenade_meta["runDuration"],
											" Correct yaw=", round(grenade_meta["yaw"], 2), 
											" pitch=", round(grenade_meta["pitch"], 2), 
											", Current yaw=", round(localyaw, 2), 
											" pitch=", round(localpitch, 2),
											" -> distance=", viewangles_distance, " (", viewangles_distance < viewangles_distance_max, ")",
											" is_in_position=", is_in_position, " current_in_position=", current_in_position
										)
									end
								end
							end

							if draw_line then
								if worldXTarget ~= nil and worldYTarget ~= nil and worldXHead ~= nil and worldYHead ~= nil then
									client_draw_line(ctx, worldXTarget, worldYTarget, worldXHead, worldYHead, r, g, b, a_bottom)

									client_draw_circle(ctx, worldXHead, worldYHead, r, g, b, a_bottom, 3, 0, 1)

									client_draw_circle(ctx, worldXTarget, worldYTarget, 16, 16, 16, a_bottom, 4, 0, 1)
									client_draw_circle(ctx, worldXTarget, worldYTarget, r_secondary, g_secondary, b_secondary, a_bottom, 2, 0, 1)
								end
							end

							if draw_target then
								if worldXTargetDot ~= nil and worldXTargetDot > 0 then
									client_draw_rectangle(ctx, worldXTargetDot-aimpoint_size/2, worldYTargetDot-aimpoint_size/2, aimpoint_size, aimpoint_size, 16, 16, 16, 255*aTargetMultiplier)
									local aimpoint_size_temp = aimpoint_size - 2
									client_draw_rectangle(ctx, worldXTargetDot-aimpoint_size_temp/2, worldYTargetDot-aimpoint_size_temp/2, aimpoint_size_temp, aimpoint_size_temp, r_secondary, g_secondary, b_secondary, a_secondary*aTargetMultiplier)
									client_draw_rectangle(ctx, worldXTargetDot-1, worldYTargetDot-1, 2, 2, 255, 255, 255, 90*aTargetMultiplier)
									
									if text_offset >= text_offset_add then
										client_draw_text(ctx, worldXTargetDot+aimpoint_size/2, worldYTargetDot-aimpoint_size/2, r_secondary, g_secondary, b_secondary, a_secondary*aTargetMultiplier, "-", 0, text_offset/text_offset_add+1)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	is_in_position = is_in_position_temp
end
client.set_event_callback("paint", on_paint)
