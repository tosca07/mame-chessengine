-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.turn = true
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_num = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67, 0x3f }
	send_input(":IN.0", 0x04, 0.5) -- L (Clear)
	repeat
		send_input(":IN.3", 0x01, 0.5) -- K (Level)
	until machine:outputs():get_value("digit3") == lcd_num[interface.level]
	send_input(":IN.0", 0x04, 0.5) -- L (Clear)
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.turn = true
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		interface.turn = false
		send_input(":IN.3", 0x02, 1) -- W (White)
		emu.wait(0.5)
		send_input(":IN.0", 0x08, 1) -- Q (Enter)
		emu.wait(0.5)
	end
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x6f, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.1", 0x01, 1)
	elseif (p == 2)	then	send_input(":IN.1", 0x02, 1)
	elseif (p == 3)	then	send_input(":IN.1", 0x04, 1)
	elseif (p == 4)	then	send_input(":IN.1", 0x08, 1)
	elseif (p == 5)	then	send_input(":IN.2", 0x01, 1)
	elseif (p == 6)	then	send_input(":IN.2", 0x02, 1)
	elseif (p == 7)	then	send_input(":IN.2", 0x04, 1)
	elseif (p == 8)	then	send_input(":IN.2", 0x08, 1)
	end
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (interface.turn) then
			interface.send_pos(x)
			interface.send_pos(y)
		end

		if (event == "put") then
			if (interface.turn) then
				send_input(":IN.0", 0x08, 1)
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "10"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 10) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	-- TODO
end

return interface
