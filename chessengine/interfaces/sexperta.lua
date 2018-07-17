-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) == 0) or (req_pos == false and port_val & (1 << (7 - x)) ~= 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end

	emu.wait(4)
	send_input(":IN.7", 0x100, 1)
	emu.wait(2)
end

function interface.start_play()
	send_input(":IN.0", 0x100, 1)
	emu.wait(1)
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value(tostring(y - 1) .. ".", 8 - x) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(y - 1), 1 << (8 - x), 1)
end

function interface.get_promotion()
	-- HD44780 Display Data RAM
	local ddram = emu.item(machine.devices[':hd44780'].items['0/m_ddram']):read_block(0x00, 0x80)
	local ch9 = ddram:sub(0x42,0x42)

	if     (ch9 == '\x02' or ch9 == '\x0a') then	return 'q'
	elseif (ch9 == '\x03' or ch9 == '\x0b') then	return 'r'
	elseif (ch9 == '\x04' or ch9 == '\x0c') then	return 'b'
	elseif (ch9 == '\x05' or ch9 == '\x0d') then	return 'n'
	end
	return nil
end

function interface.promote(x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.6", 0x200, 1)
	elseif (piece == "r") then	send_input(":IN.3", 0x200, 1)
	elseif (piece == "b") then	send_input(":IN.5", 0x200, 1)
	elseif (piece == "n") then	send_input(":IN.4", 0x200, 1)
	end
end

return interface