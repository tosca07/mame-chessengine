-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("npresto")

function interface.select_piece(x, y, event)
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 0.3, x, y, event)
	end
end

return interface
