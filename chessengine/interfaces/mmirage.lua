-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = "a3"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tonumber(interface.level:sub(2, 2))
	send_input(":IN.6", 0x01, 0.5) -- LEV
	interface.send_pos(x)
	interface.send_pos(y)
	send_input(":IN.2", 0x01, 0.5) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)

	interface.cur_level = "a3"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.4", 0x01, 0.5) -- STA
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit3")
	local d1 = machine:outputs():get_value("digit2")
	local d2 = machine:outputs():get_value("digit1")
	local d3 = machine:outputs():get_value("digit0")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.1", 0x01, 0.5)
	elseif (p == 2)	then	send_input(":IN.3", 0x01, 0.5)
	elseif (p == 3)	then	send_input(":IN.5", 0x01, 0.5)
	elseif (p == 4)	then	send_input(":IN.7", 0x01, 0.5)
	elseif (p == 5)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.3", 0x02, 0.5)
	elseif (p == 7)	then	send_input(":IN.5", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.7", 0x02, 0.5)
	end
end

function interface.select_piece(x, y, event)
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	else
		sb_select_piece(":board", 1.0, x, y, event)
	end
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
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
