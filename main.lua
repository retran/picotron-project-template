--[[pod_format="raw",created="2024-09-08 09:50:07",modified="2025-03-07 13:16:33",revision=5]]
--[[
	main.lua - program entry points
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

include("globals.lua")
include("require.lua")
include("configuration.lua")

add_module_path("lib/")
add_module_path("src/")

local log = require("log")

if configuration.log.enabled then
	log.set_level(configuration.log.level)
	log.init()
end

-- Main initialization function
-- Called once when the program starts
function _init()
	log.info("Initializing application...")

	local success, err = pcall(function()
		-- Initialization logic here
	end)

	if not success then
		wtf(tostring(err))
	end

	log.info("Application initialized successfully.")
end

-- Main update function
-- Called every frame to update the program's state
function _update()
	log.trace("> Entering _update()")

	local success, err = pcall(function()
		-- Update logic here
	end)

	if not success then
		log.error("Error during update: " .. tostring(err))
	end

	log.trace("< Exiting _update()")
end

-- Main draw function
-- Called every frame to render visuals to the screen
function _draw()
	log.trace("> Entering _draw()")

	local success, err = pcall(function()
		-- Draw logic here
	end)

	if not success then
		log.error("Error during draw: " .. tostring(err))
	end

	log.trace("< Exiting _draw()")
end
