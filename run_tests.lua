--[[pod_format="raw",created="2024-09-08 16:10:59",modified="2025-03-07 13:16:21",revision=5]]
--[[
	run_tests.lua - Program entry point for test execution
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

-- Add paths for module search
add_module_path("lib/")
add_module_path("src/")
add_module_path("test/")

local _TEST_PREFIX = "test_"

local log = require("log")

-- Initialize logging
log.set_level(log.levels.DEBUG)
log.set_target(log.targets.CONSOLE)
log.init()

local total_tests = 0
local total_passed = 0
local total_failed = 0
local failed_tests = {}

-- Utility function to extract line number and error message from Lua errors
local function extract_error_info(err)
	local line_number, message = err:match(":(%d+): (.+)$")
	return line_number or "unknown", message or err
end

-- Clears the environment and includes necessary configurations
local function initialize_environment()
	clear_module_cache({ "log" })
	include("test_configuration.lua")
end

-- Runs a single fixture and handles its lifecycle
local function run_fixture(filename)
	log.info("Executing fixture: '%s'", filename)
	initialize_environment()

	local fixture = require(filename)
	local fixture_tests, fixture_passed, fixture_failed = 0, 0, 0
	failed_tests[filename] = {} -- Initialize table for failed tests in this fixture

	if fixture.before_all then
		local success, err = pcall(fixture.before_all)
		if not success then
			for name, _ in pairs(fixture) do
				if string.sub(name, 1, string.len(_TEST_PREFIX)) == _TEST_PREFIX then
					fixture_tests, total_tests = fixture_tests + 1, total_tests + 1
				end
			end
			local line_number, message = extract_error_info(err)
			log.error("Error in 'before_all' hook on line %s, affecting %d test(s).", line_number, fixture_tests)
			log.error("Details: %s", message)
			table.insert(failed_tests[filename], string.format("'before_all' hook failure affecting %d test(s) on line %s.", fixture_tests, line_number))
			table.insert(failed_tests[filename], string.format("Error details: %s", message))
			total_failed = total_failed + fixture_tests

			log.error("Fixture '%s' summary: %d test(s), 0 passed, %d failed.", filename, fixture_tests, fixture_tests)
			return
		end
	end

	for name, test in pairs(fixture) do
		if string.sub(name, 1, string.len(_TEST_PREFIX)) == _TEST_PREFIX then
			fixture_tests, total_tests = fixture_tests + 1, total_tests + 1
			local test_passed = true
			local already_failed = false

			if fixture.before_each then
				local success, err = pcall(fixture.before_each)
				if not success then
					local line_number, message = extract_error_info(err)
					log.error("Error in 'before_each' hook for test '%s' on line %s.", name, line_number)
					log.error("Details: %s", message)
					table.insert(failed_tests[filename], string.format("Test '%s' -> 'before_each' hook failure on line %s.", name, line_number))
					table.insert(failed_tests[filename], string.format("Error details: %s", message))
					total_failed, fixture_failed = total_failed + 1, fixture_failed + 1
					test_passed = false
					already_failed = true
				end
			end

			if test_passed then
				local success, err = pcall(test)
				if not success then
					local line_number, message = extract_error_info(err)
					log.error("Test '%s' failed on line %s.", name, line_number)
					log.error("Details: %s", message)
					table.insert(failed_tests[filename], string.format("Test '%s' -> failure on line %s.", name, line_number))
					table.insert(failed_tests[filename], string.format("Error details: %s", message))
					total_failed, fixture_failed = total_failed + 1, fixture_failed + 1
					test_passed = false
					already_failed = true
				end
			end

			if fixture.after_each then
				local success, err = pcall(fixture.after_each)
				if not success then
					local line_number, message = extract_error_info(err)
					log.error("Error in 'after_each' hook for test '%s' on line %s.", name, line_number)
					log.error("Details: %s", message)
					test_passed = false
					if not already_failed then
						table.insert(failed_tests[filename], string.format("Test '%s' -> 'after_each' hook failure on line %s.", name, line_number))
						table.insert(failed_tests[filename], string.format("Error details: %s", message))
						total_failed, fixture_failed = total_failed + 1, fixture_failed + 1
					end
				end
			end

			if test_passed then
				log.info("Test '%s' passed.", name)
				total_passed, fixture_passed = total_passed + 1, fixture_passed + 1
			end
		end
	end

	if fixture.after_all then
		local success, err = pcall(fixture.after_all)
		if not success then
			local line_number, message = extract_error_info(err)
			log.warn("Error in 'after_all' hook on line %s, affecting %d test(s).", line_number, fixture_tests)
			log.warn("Details: %s", message)
			table.insert(failed_tests[filename], string.format("'after_all' hook failure affecting %d test(s) on line %s.", fixture_tests, line_number))
			table.insert(failed_tests[filename], string.format("Error details: %s", message))
		end
	end

	if fixture_failed > 0 then
		log.error("Fixture '%s' summary: %d test(s), %d passed, %d failed.", filename, fixture_tests, fixture_passed, fixture_failed)
	else
		log.info("Fixture '%s' summary: %d test(s), %d passed, %d failed.", filename, fixture_tests, fixture_passed, fixture_failed)
	end
end

-- Runs a list of test fixtures provided as input
local function run_fixtures_from_list(fixture_list)
	for _, fixture_module_name in ipairs(fixture_list) do
		run_fixture(fixture_module_name)
	end
end

-- Provides a summary of the test results
local function report_test_summary()
	if total_failed > 0 then
		log.error("Test run summary: %d test(s) executed, %d passed, %d failed.", total_tests, total_passed, total_failed)
		log.error("Detailed report of failed test(s):")
		for fixture, errors in pairs(failed_tests) do
			log.error("Fixture '%s' encountered the following failures:", fixture)
			for _, error in ipairs(errors) do
				log.error("\t%s", error)
			end
		end
	else
		log.info("Test run summary: %d test(s) executed, %d passed, %d failed.", total_tests, total_passed, total_failed)
		log.info("All tests passed successfully.")
	end
end

-- Main function to handle command-line arguments and run appropriate tests
local function main()
	local params = env().argv
	local fixture_names = {}

	if #params > 0 then
		for _, filename in ipairs(params) do
			local module_name = filename:gsub("%.lua$", "")
			table.insert(fixture_names, module_name)
		end

		log.info("Executing selected fixtures: %s", table.concat(fixture_names, ", "))
	else
		for _, filename in ipairs(ls("test/")) do
			if filename:match("%.lua$") then
				local module_name = filename:gsub("%.lua$", "")
				table.insert(fixture_names, module_name)
			end
		end

		log.info("Executing all fixtures: %s", table.concat(fixture_names, ", "))
	end

	run_fixtures_from_list(fixture_names)

	report_test_summary()
end

main()
