--[[pod_format="raw",created="2024-09-08 16:18:39",modified="2024-09-08 22:44:14",revision=1]]
--[[
	log.lua - logging and tracing
	(c) 2024 Andrew Vasilyev. All rights reserved.

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

local log = {}

-- Log levels table
log.levels = {
	TRACE = 1,
	DEBUG = 2,
	INFO  = 3,
	WARN  = 4,
	ERROR = 5
}

-- Log level color codes for console output
local log_level_colors = {
	"\f6", -- TRACE
	"\f7", -- DEBUG
	"\fb", -- INFO
	"\fa", -- WARN
	"\f8"  -- ERROR
}

-- Log output targets
log.targets = {
	CONSOLE = 1,         -- Logs to console
	EXTERNAL_PROCESS = 2 -- Logs to an external process
}

-- Current log level (default to INFO)
log.current_level = log.levels.INFO

-- Default log target (set to external process)
log.target = log.targets.EXTERNAL_PROCESS
log.target_process_name = "logview" -- Name of external process
log.target_process_id = -1          -- Process ID of the log target

-- Formats a timestamp into MM:SS.mmm format
local function format_timestamp(timestamp)
	local minutes = math.floor(timestamp / 60)
	local seconds = math.floor(timestamp % 60)
	local milliseconds = math.floor((timestamp % 1) * 1000)
	return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

-- Formats a log entry with level color, timestamp, and message
local function format_log_entry(level, timestamp, message)
	return log_level_colors[level] .. format_timestamp(timestamp) .. "\t" .. message
end

-- Logs a message if it meets the current log level
local function log_message(level, message, ...)
	if level < log.current_level then
		return
	end

	if log.target == log.targets.EXTERNAL_PROCESS and log.target_process_id == -1 then
		-- Logging target process ID not resolved. Unable to log message.
		return
	end

	local formatted_message = string.format(message, ...)
	local timestamp = time()

	local presentation = format_log_entry(level, timestamp, formatted_message)

	if log.target == log.targets.EXTERNAL_PROCESS then
		send_message(log.target_process_id, {
			event = "entry",
			entry = {
				timestamp = timestamp,
				level = level,
				message = formatted_message
			},
			presentation = presentation
		})
	elseif log.target == log.targets.CONSOLE then
		print(presentation)
	end
end

-- Initializes the logging system and resolves the external process ID
function log.init()
	if log.target == log.targets.EXTERNAL_PROCESS then
		log.target_process_id = get_pid_by_name(log.target_process_name)
		if log.target_process_id == -1 then
			log.set_target(log.targets.CONSOLE)
			log.warn("External logging process '" .. log.target_process_name .. "' not found. Defaulting to console output...")
		end
	end
end

-- Logs function entry and exit points for tracing
function log.trace_function(fn_name, fn, ...)
	log.trace("Entering %s()", fn_name)
	local result = { fn(...) }
	log.trace("Exiting %s()", fn_name)
	return table.unpack(result)
end

-- Log message functions for different levels
function log.trace(message, ...) log_message(log.levels.TRACE, message, ...) end

function log.debug(message, ...) log_message(log.levels.DEBUG, message, ...) end

function log.info(message, ...) log_message(log.levels.INFO, message, ...) end

function log.warn(message, ...) log_message(log.levels.WARN, message, ...) end

function log.error(message, ...) log_message(log.levels.ERROR, message, ...) end

-- Sets the current logging level
function log.set_level(level)
	log.current_level = level
end

-- Sets the logging target and optionally updates the external process name
function log.set_target(target_type, process_name)
	log.target = target_type

	if process_name then
		log.target_process_name = process_name
		log.target_process_id = -1
	end
end

return log
