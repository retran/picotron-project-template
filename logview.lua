--[[pod_format="raw",created="2024-09-08 09:51:03",modified="2025-03-07 13:16:38",revision=5]]
--[[
	logview.lua - log viewer utility
	(c) 2025 Andrew Vasilyev. All rights reserved.

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <https://www.gnu.org/licenses/>.
]]

local gui = create_gui()

-- Initializes the log viewer window and sets up the log display.
function _init()
	window({
		width      = 320,
		height     = 200,
		resizeable = true,
		title      = "Log Viewer"
	})

	local lines = {}

	-- Attach a log display panel to the GUI
	gui:attach({
		x = 1,
		y = 1,
		width = 480,
		height = 0,
		update = function(self, ev)
			self.height = #lines * 9  -- Adjust the height dynamically based on the number of lines
		end,
		draw = function(self, ev)
			for i = 1, #lines do
				print(lines[i], 0, (i - 1) * 9)
			end
		end
	})

	-- Attach scrollbars to the GUI, with autohide enabled
	gui:attach_scrollbars({
		autohide = true
	})

	-- Event listener to handle incoming log entries
	on_event("entry", function(entry)
		table.insert(lines, entry.presentation)

		-- Ensure the log display doesn't exceed 500 lines
		while (#lines > 500) do
			table.remove(lines, 1)
		end
	end)
end

-- Clears the screen and draws the GUI.
-- This function is called every frame to refresh the display.
function _draw()
	cls(1)
	gui:draw_all()
end

-- Updates the GUI state based on input or events.
-- Called every frame to handle updates to the GUI.
function _update()
	gui:update_all()
end
