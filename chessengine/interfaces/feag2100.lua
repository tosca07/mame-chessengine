-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.opt_clear_announcements = true
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	if (x > 2) then
		return
	end
	local y = tostring(tonumber(interface.level:sub(2, 2)))
	send_input(":IN.0", 0x04, 1)  -- LV
	sb_press_square(":board", 1, x, y)
	send_input(":IN.1", 0x01, 1) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(3.0)
	send_input(":IN.1", 0x04, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x01, 1) -- RV
end

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.8") ~= 0 and machine:outputs():get_value("0.9") ~= 0 and machine:outputs():get_value("0.10") ~= 0 and machine:outputs():get_value("0.11") ~= 0 and
	    machine:outputs():get_value("0.12") ~= 0 and machine:outputs():get_value("0.13") ~= 0 and machine:outputs():get_value("0.14") ~= 0 and machine:outputs():get_value("0.15") ~= 0) then
		send_input(":IN.1", 0x01, 1) -- CL
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_value((y - 1) .. "." .. (7 + x)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a1"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
	if (name == "clear announcements") then
		interface.opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion_led()
	if     (machine:outputs():get_value("8.12") ~= 0) then	return 'q'
	elseif (machine:outputs():get_value("8.11") ~= 0) then	return 'r'
	elseif (machine:outputs():get_value("8.10") ~= 0) then	return 'b'
	elseif (machine:outputs():get_value("8.9") ~= 0) then	return 'n'
	end
	return nil
end

function interface.get_promotion(x, y)
	interface.clear_announcements()
	interface.select_piece(x, y, "")

	local new_type = nil
	for i=1,5 do
		new_type = interface.get_promotion_led()
		if (new_type ~= nil) then
			break
		end
		emu.wait(0.25)
	end

	interface.select_piece(x, y, "")

	return new_type
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":IN.0", 0x40, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x20, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x08, 1)
	end
end

return interface
