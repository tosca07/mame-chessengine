-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = 2
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	if (interface.level == 7 or interface.level == 8) then
		return
	end
	send_input(":LINE1", 0x20, 1) -- LEV
	if     (interface.level == 0) then	send_input(":LINE1", 0x04, 1)
	elseif (interface.level == 1) then	send_input(":LINE0", 0x20, 1)
	elseif (interface.level == 2) then	send_input(":LINE0", 0x80, 1)
	elseif (interface.level == 3) then	send_input(":LINE0", 0x04, 1)
	elseif (interface.level == 4) then	send_input(":LINE0", 0x10, 1)
	elseif (interface.level == 5) then	send_input(":LINE1", 0x01, 1)
	elseif (interface.level == 6) then	send_input(":LINE0", 0x40, 1)
	elseif (interface.level == 7) then	send_input(":LINE1", 0x40, 1)
	elseif (interface.level == 8) then	send_input(":LINE1", 0x10, 1)
	elseif (interface.level == 9) then	send_input(":LINE0", 0x01, 1)
	end
	send_input(":LINE0", 0x08, 1) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
--	send_input(":LINE0", 0x02, 1) -- CLR
--	emu.wait(1.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":LINE0", 0x08, 1) -- ENT
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d2 = machine:outputs():get_value("digit2") & 0x7f
	local d3 = machine:outputs():get_value("digit3") & 0x7f
	return ((xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)) and machine:outputs():get_value("led" .. tostring(8 * (y - 1) + (x - 1))) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board:board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "2", "0", "6"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 6) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	send_input(":LINE1", 0x02, 0.5)	-- INFO
	send_input(":LINE1", 0x02, 0.5)	-- INFO
	send_input(":LINE0", 0x20, 0.5)	-- 1

	local d3 = 0
	for i=0,5 do
		local d0 = machine:outputs():get_value("digit0") & 0x7f
		local d1 = machine:outputs():get_value("digit1") & 0x7f

		if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
			d3 = machine:outputs():get_value("digit3") & 0x7f
			break
		end
		send_input(":LINE1", 0x04, 0.5)	-- 0
	end

	send_input(":LINE0", 0x02, 0.5)	-- CLR

	if     (d3 == 0x5e) then	return "q"
	elseif (d3 == 0x31) then	return "r"
	elseif (d3 == 0x38) then	return "b"
	elseif (d3 == 0x6d) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board:board", x, y, piece)
	if     (piece == "q") then	send_input(":LINE0", 0x40, 1)
	elseif (piece == "r") then	send_input(":LINE1", 0x01, 1)
	elseif (piece == "b") then	send_input(":LINE0", 0x10, 1)
	elseif (piece == "n") then	send_input(":LINE0", 0x04, 1)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":LINE0", 0x08, 1)
	end
end

return interface
