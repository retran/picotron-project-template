--[[pod_format="raw",created="2024-09-08 16:18:35",modified="2025-03-07 13:17:35",revision=2]]
--[[
	assert.lua - Custom assertion library for Lua
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

local assert = {}

-- Helper function to compare two tables
local function deep_compare(table1, table2)
	if table1 == table2 then
		return true
	end

	if type(table1) ~= "table" or type(table2) ~= "table" then
		return false
	end

	for key, value1 in pairs(table1) do
		local value2 = table2[key]
		if not deep_compare(value1, value2) then
			return false
		end
	end

	for key in pairs(table2) do
		if table1[key] == nil then
			return false
		end
	end

	return true
end

-- Helper function to compare two tables while ignoring nil values
local function deep_compare_ignore_nil(table1, table2)
	if table1 == table2 then
		return true
	end

	if type(table1) ~= "table" or type(table2) ~= "table" then
		return false
	end

	for key, value1 in pairs(table1) do
		local value2 = table2[key]
		if value1 ~= nil and value2 ~= nil then
			if not deep_compare_ignore_nil(value1, value2) then
				return false
			end
		end
	end

	for key, value2 in pairs(table2) do
		local value1 = table1[key]
		if value1 ~= nil and value2 ~= nil then
			if not deep_compare_ignore_nil(value1, value2) then
				return false
			end
		end
	end

	return true
end

-- Asserts that two values are equal
function assert.are_equal(actual, expected, message)
	if actual ~= expected then
		error(message or string.format("Assertion failed: expected '%s', got '%s'", tostring(expected), tostring(actual)), 2)
	end
end

-- Asserts that two tables are deeply equal, ignoring nil values
function assert.are_equal_tables_ignore_nil(actual, expected, message)
	if not deep_compare_ignore_nil(actual, expected) then
		error(message or "Assertion failed: Tables are not equal (ignoring nil values)", 2)
	end
end

-- Asserts that two values are not equal
function assert.are_not_equal(actual, expected, message)
	if actual == expected then
		error(message or string.format("Assertion failed: expected values to be different, but both are '%s'", tostring(actual)), 2)
	end
end

-- Asserts that two tables are deeply equal
function assert.are_equal_tables(actual, expected, message)
	if not deep_compare(actual, expected) then
		error(message or "Assertion failed: Tables are not equal", 2)
	end
end

-- Asserts that a value is nil
function assert.is_nil(value, message)
	if value ~= nil then
		error(message or string.format("Assertion failed: expected nil, got '%s'", tostring(value)), 2)
	end
end

-- Asserts that a value is not nil
function assert.is_not_nil(value, message)
	if value == nil then
		error(message or "Assertion failed: expected value to not be nil", 2)
	end
end

-- Asserts that a value is of a specific type
function assert.is_type(value, expected_type, message)
	if type(value) ~= expected_type then
		error(message or string.format("Assertion failed: expected type '%s', got '%s'", expected_type, type(value)), 2)
	end
end

-- Asserts that a value is true
function assert.is_true(value, message)
	if not value then
		error(message or string.format("Assertion failed: expected true, got '%s'", tostring(value)), 2)
	end
end

-- Asserts that a value is false
function assert.is_false(value, message)
	if value then
		error(message or string.format("Assertion failed: expected false, got '%s'", tostring(value)), 2)
	end
end

-- Asserts that a number is greater than a threshold
function assert.is_greater_than(actual, threshold, message)
	if actual <= threshold then
		error(
		message or
		string.format("Assertion failed: expected '%s' to be greater than '%s'", tostring(actual), tostring(threshold)),
			2)
	end
end

-- Asserts that a number is less than a threshold
function assert.is_less_than(actual, threshold, message)
	if actual >= threshold then
		error(
		message or
		string.format("Assertion failed: expected '%s' to be less than '%s'", tostring(actual), tostring(threshold)), 2)
	end
end

-- Asserts that a table contains a specific value
function assert.contains(table, value, message)
	for _, v in pairs(table) do
		if v == value then
			return true -- Value found
		end
	end
	error(message or string.format("Assertion failed: expected table to contain '%s'", tostring(value)), 2)
end

-- Asserts that a table contains a specific key
function assert.has_key(table, key, message)
	if table[key] == nil then
		error(message or string.format("Assertion failed: expected table to have key '%s'", tostring(key)), 2)
	end
end

-- Asserts that a table or string has a specific length
function assert.has_length(value, expected_length, message)
	local len = #value
	if len ~= expected_length then
		error(message or string.format("Assertion failed: expected length '%d', got '%d'", expected_length, len), 2)
	end
end

-- Asserts that a string matches a given Lua pattern
function assert.matches_pattern(value, pattern, message)
	if not string.match(value, pattern) then
		error(message or string.format("Assertion failed: expected '%s' to match pattern '%s'", value, pattern), 2)
	end
end

return assert
