--[[pod_format="raw",created="2024-09-08 09:49:37",modified="2025-03-07 13:16:47",revision=5]]
--[[
	globals.lua - global utility functions
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

local wm_pid = 3 -- Process ID of Picotron's window manager and info bar

-- Reports a fatal error, logs the message and traceback, and exits the program.
-- @param message: The format string for the error message
-- @param exit_code: Optional custom exit code (default is 1)
-- @param ...: Additional arguments to format the message
function wtf(message, exit_code, ...)
	local error_report = debug.traceback(string.format(message, ...), 2)

	send_message(wm_pid, { event = "report_error", content = "*wtf?!" })
	send_message(wm_pid, { event = "report_error", content = error_report })

	exit(exit_code or 1)
end

-- Retrieves the process ID (PID) by process name.
-- @param name: The name of the process to search for.
-- @return: The process ID if found, or -1 if not found.
function get_pid_by_name(name)
	local processes = fetch("/ram/system/processes.pod")

	for i = 1, #processes do
		local process = processes[i]
		if (process.name == name) then
			-- Return the process ID if found
			return process.id
		end
	end

	return -1
end
