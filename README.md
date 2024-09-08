# Picotron Game Template

This template serves as a foundation for developing games using the Picotron fantasy computer environment. It offers a well-organized setup for managing Lua code, logging, and unit testing, ensuring your game's stability and scalability during development.

- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
    - [Running the Game](#running-the-game)
    - [Customizing Configuration](#customizing-configuration)
- [Lua `require()` and Module System](#lua-require-and-module-system)
- [Logging System](#logging-system)
    - [Using the Logging System](#using-the-logging-system)
    - [Logging Example](#logging-example)
    - [Log Viewer (`logview.lua`)](#log-viewer-logviewlua)
    - [Important Notes](#important-notes)
- [Unit Testing](#unit-testing)
    - [Running Unit Tests](#running-unit-tests)
    - [Writing Unit Tests](#writing-unit-tests)
        - [Test Fixture Example for `player.lua`](#test-fixture-example-for-playerlua)
        - [Test Lifecycle Details](#test-lifecycle-details)
        - [Running the Tests](#running-the-tests)
        - [Sample Test Output](#sample-test-output)
- [Assertion Library](#assertion-library)
    - [Practical Assertion Examples](#practical-assertion-examples)
    - [Error Handling in Assertions](#error-handling-in-assertions)
- [License](#license)
- [Additional Resources](#additional-resources)
- [Contributing](#contributing)
    - [How to Contribute](#how-to-contribute)
    - [Contribution Guidelines](#contribution-guidelines)
    - [Reporting Issues](#reporting-issues)

## Introduction

Picotron is a fantasy computer developed by Lexaloffle, offering a creative platform for developing games, demos, and tools using pixel graphics and Lua programming. This template streamlines game development by providing an organized project structure, essential utilities (such as logging and assertion tools), and a unit testing framework.

## Project Structure

The project is structured as follows:

```plaintext
PROJECT_ROOT/
├── lib/
│    ├── assert.lua         # Assertion utilities for testing
│    ├── log.lua            # Logging utilities for runtime events
├── src/                    # Source code for your game (expandable)
├── test/                   # Directory for unit tests
├── .gitattributes          # Git configuration for handling line endings
├── configuration.lua       # Global configuration settings
├── globals.lua             # Global utility functions
├── LICENSE                 # License file for the project (GNU GPLv3)
├── logview.lua             # Log viewer for inspecting logs in a GUI window
├── main.lua                # Entry point for the game
├── README.md               # Project documentation
├── require.lua             # Module loading system (custom `require()`)
├── run_tests.lua           # Script to run unit tests
└── test_configuration.lua  # Configuration settings for tests
```

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/yourusername/picotron-game-template.git
    ```

2. Install the [Picotron Fantasy Computer](https://www.lexaloffle.com/dl/docs/picotron_manual.html) following the official instructions.

3. Copy your project folder into the Picotron workspace to begin developing.

## Usage

### Running the Game

To start your game, open Picotron and navigate to the `main.lua` file. This file serves as the entry point for your game. Customize it as needed to incorporate your game's logic.

### Customizing Configuration

Global settings, such as enabling/disabling features like logging or defining game-specific variables, can be modified in the `configuration.lua` file. This file centralizes all critical configurations for the game.

## Lua `require()` and Module System

This template includes a custom implementation of the Lua `require()` function, compatible with Lua 5.4, to simplify module loading and caching, making your game easier to manage and test.

1. **Modular Design**:
    Organize your code by distributing functionality across different modules (files). Modules can contain game logic, utilities, or configuration settings. Use `require()` to load them.

2. **Module Caching**:
    Once a module is loaded, it is cached to avoid multiple reloads, improving performance by reusing loaded modules.

3. **Using `require()` to Load Modules**:
    Load a module using its filename. The `require()` function returns the module's content, typically a table of functions or data.

    Example:
    ```lua
    local player = require("player")
    player.move(10, 20)
    print("Player health: " .. player.health)
    player.take_damage(5)
    print("Player health after damage: " .. player.health)
    ```

4. **Adding Custom Search Paths**:
    Define additional search paths to organize your modules in different directories.

    Example:
    ```lua
    add_module_path("/additional_module_directory/")
    ```

5. **Clearing the Module Cache**:
    Clear the module cache to reload specific modules, which is useful during testing.

    Example:
    ```lua
    clear_module_cache({ "log" })  -- Clears all cached modules except the log module
    ```

6. **Mock Modules for Testing**:
    Load mock versions of modules during testing by using aliases, allowing you to simulate behavior without affecting the actual game.

    Example:
    ```lua
    local log = require("mock_log", "log")  -- Mock log module under the real log alias
    log.info("Testing started")
    ```

## Logging System

This template includes a comprehensive logging system to track game events, debug information, and errors. The system allows you to log messages to either the console or an external process, such as the included log viewer, providing real-time visibility into your game’s behavior.

1. **Log Levels**:
    Different log levels control the verbosity of the output. Set the appropriate log level before initializing the logging system. Available log levels are:
    - `TRACE`: Very detailed logging, useful for tracing function calls.
    - `DEBUG`: Detailed information to help with debugging.
    - `INFO`: General game execution information (e.g., "Game started").
    - `WARN`: Warnings about potential issues that do not stop the game.
    - `ERROR`: Critical errors requiring immediate attention.

2. **Log Targets**:
    Logs can be directed to either:
    - **Console**: Logs printed directly in the console.
    - **External Process**: Logs sent to an external process such as the log viewer (`logview.lua`).

3. **External Logging**:
    When logging to an external process, the system sends messages to another program (e.g., `logview.lua`), allowing real-time monitoring in a separate window.

4. **Timestamped Entries**:
    Each log entry is automatically timestamped, which helps with debugging and tracking event order.

5. **Dynamic Control Over Logging**:
    Adjust the log level to control which messages are logged. For example, setting the log level to `ERROR` will only log critical errors.

### Using the Logging System

1. **Setting Log Level and Target**:
    Set the log level and target before calling `init()`.

    Example:
    ```lua
    log.set_level(log.levels.DEBUG)      -- Set log level to DEBUG
    log.set_target(log.targets.CONSOLE)  -- Set log target to console
    log.init()                           -- Initialize logging
    ```

2. **Logging Messages**:
    Log messages at different levels (`TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`).

    ```lua
    log.info("Game initialized")       -- Logs an info message
    log.error("Failed to load asset")  -- Logs an error message
    ```

3. **Reinitializing the Log System**:
    If you change the log level or target after the initial setup, reinitialize the logging system by calling `init()` again.

    ```lua
    log.set_level(log.levels.TRACE)               -- Change log level to TRACE
    log.set_target(log.targets.EXTERNAL_PROCESS)  -- Change target to external process
    log.init()                                    -- Reinitialize logging system
    ```

4. **Tracing Function Calls**:
    Use `trace_function()` to log function entry and exit points, making it easier to trace the flow of function calls.

    ```lua
    local result = log.trace_function("move_player", move_player, player, dx, dy)
    ```

### Logging Example

```lua
log.set_level(log.levels.INFO)
log.set_target(log.targets.EXTERNAL_PROCESS)
log.init()  -- Initialize logging

log.info("Game started")
log.warn("Low player health detected")

if not player then
    log.error("Failed to load player data")
end
```

### Log Viewer (`logview.lua`)

The `logview.lua` script provides a graphical interface for viewing log messages in real-time. It displays up to 500 log entries, removing the oldest entries as new ones are added.

### Important Notes
- Always set the log level and target **before** calling `log.init()`.
- Reinitialize the logging system if the log level or target is changed after initialization.

## Unit Testing

This template includes a unit testing system to ensure that your game functions reliably and as expected. It allows for organized testing with modular test files, setup/teardown functions, and integration with the logging system to maintain code quality and catch bugs early.

1. **Modular Test Structure**: 
    Tests are organized into Lua files (fixtures) stored in the `test/` directory. Each fixture contains multiple test cases, focusing on specific parts of the game.

2. **Test Lifecycle Management**: 
    The framework supports lifecycle hooks to manage the test environment:
    - **`before_all()`**: Runs once before any tests in the fixture, useful for initializing resources.
    - **`before_each()`**: Runs before each test case to prepare or reset the environment.
    - **Test Functions**: Each test case is defined as a separate function in the fixture.
    - **`after_each()`**: Cleans up after each test case to ensure a fresh state.
    - **`after_all()`**: Runs after all tests in the fixture, typically used for final cleanup of shared resources.

    Example test fixture structure:
    ```lua
    -- Importing required modules
    local assert = require("assert")  -- Used for assertions in test cases
    local log = require("log")        -- Used for logging during test execution

    -- Define a fixture table to hold the test setup, teardown, and test functions
    local fixture = { }

    -- Called once before any tests are run (fixture initialization)
    function fixture.before_all()
        -- Setup logic that runs before all tests in the fixture
    end

    -- Called before each individual test is executed (test case initialization)
    function fixture.before_each()
        -- Setup logic that runs before each test case in the fixture
    end

    -- First test case: Write your test logic here
    function fixture.test_something()
        -- Test something
    end

    -- Second test case: Another example test
    function fixture.test_something2()
        -- Test something else
    end

    -- Called after each individual test is executed (test case cleanup)
    function fixture.after_each()
        -- Cleanup logic that runs after each test case in the fixture
    end

    -- Called once after all tests are run (fixture cleanup)
    function fixture.after_all()
        -- Cleanup logic that runs after all tests in the fixture
    end

    -- Return the fixture table to be used by the test framework
    return fixture
    ```

3. **Logging Integration**: 
    The system logs test results in real-time, providing detailed error messages if tests fail.

4. **Automatic Test Discovery**: 
    The `run_tests.lua` script automatically detects and runs all test files in the `test/` directory.

5. **Detailed Error Reporting**: 
    The system logs detailed error messages, including the line number, making it easy to identify the source of problems.

### Running Unit Tests

To run all tests, execute the `run_tests.lua` script:

```
run_tests.lua
```

To run specific tests:

```
run_tests.lua test_player.lua test_inventory.lua
```

### Writing Unit Tests

Each test file (fixture) contains multiple test cases using lifecycle hooks to manage setup and teardown. Below is an example test fixture for the `player.lua` module.

#### Test Fixture Example for `player.lua`

```lua
local assert = require("assert")
local log = require("log")
local player = require("player")

local fixture = {}

function fixture.before_each()
    player.x, player.y = 0, 0
    player.health = 100
    player.inventory = {}
    log.info("Player state reset for a new test")
end

function fixture.test_player_moves_correctly()
    local initial_x, initial_y = player.x, player.y
    local dx, dy = 5, 3
    player.move(dx, dy)
    assert.are_equal(player.x, initial_x + dx, "Player x-coordinate should update correctly")
    assert.are_equal(player.y, initial_y + dy, "Player y-coordinate should update correctly")
end

function fixture.test_player_takes_damage_correctly()
    local damage = 40
    local initial_health = player.health
    player.take_damage(damage)
    assert.are_equal(player.health, initial_health - damage, "Player health should decrease by the damage amount")
end

function fixture.test_player_healing_limits_to_maximum()
    player.take_damage(50)
    local heal_amount = 60
    player.heal(heal_amount)
    assert.are_equal(player.health, 100, "Player health should not exceed 100")
end

return fixture
```

#### Test Lifecycle Details

1. **`before_each()`**: 
    Resets the player state before each test case.

2. **Test Functions**:
    Each test case checks specific behavior, such as player movement, health management, or inventory handling.

3. **`after_each()`**: 
    Cleans up after each test.

4. **Error Handling**:
    If a test fails, the system captures and logs the error, continuing to the next test.

#### Running the Tests

Run the tests using `run_tests.lua`. The system will execute each test case and log the results.

```
run_tests.lua
```

#### Sample Test Output

```plaintext
[INFO] Test 'test_player_moves_correctly' passed.
[INFO] Test 'test_player_takes_damage_correctly' passed.
[INFO] Test 'test_player_healing_limits_to_maximum' passed.
```

## Assertion Library

The `assert.lua` module provides custom assertion functions to assist with testing. Assertions are conditions that must be true during program execution, and if they fail, the program halts and reports an error.

1. **Comparison Assertions**:
    - **`assert.are_equal(actual, expected, message)`**: Verifies that two values are equal.
    - **`assert.are_not_equal(actual, expected, message)`**: Verifies that two values are not equal.
    - **`assert.are_equal_tables(actual, expected, message)`**: Verifies that two tables are deeply equal.
    - **`assert.are_equal_tables_ignore_nil(actual, expected, message)`**: Ignores `nil` values during table comparison.

2. **Type and Value Assertions**:
    - **`assert.is_nil(value, message)`**: Ensures that the value is `nil`.
    - **`assert.is_not_nil(value, message)`**: Ensures the value is not `nil`.
    - **`assert.is_type(value, expected_type, message)`**: Ensures that the value is of a specific type.
    - **`assert.is_true(value, message)`**: Ensures the value is `true`.
    - **`assert.is_false(value, message)`**: Ensures the value is `false`.

3. **Number Comparisons**:
    - **`assert.is_greater_than(actual, threshold, message)`**: Ensures a number is greater than a given threshold.
    - **`assert.is_less_than(actual, threshold, message)`**: Ensures a number is less than a given threshold.

4. **Table Assertions**:
    - **`assert.contains(table, value, message)`**: Ensures a table contains a specific value.
    - **`assert.has_key(table, key, message)`**: Ensures a table contains a specific key.
    - **`assert.has_length(table, expected_length, message)`**: Ensures a table or string has the expected length.

5. **Pattern Matching**:
    - **`assert.matches_pattern(value, pattern, message)`**: Ensures that a string matches a given Lua pattern.

### Practical Assertion Examples

In unit testing, assertions verify that functions behave as expected. Here’s a simple example:

```lua
local assert = require("assert")

local player = { health = 100 }

assert.are_equal(player.health, 100, "Player health should start at 100")

player.health = player.health - 20
assert.is_greater_than(player.health, 0, "Player should have health after damage")

player.health = player.health - 90
assert.is_greater_than(player.health, 0, "Player health should not go below zero")
```

### Error Handling in Assertions

If an assertion fails, an error message is thrown and the program halts.

Example error message for a failed `are_equal` assertion:

```
Assertion failed: expected '100', got '90'
```

## Contributing

We welcome contributions to the Picotron Game Template! Whether you want to improve existing features, add new ones, or fix bugs, your help is greatly appreciated. To contribute, please follow these steps:

### How to Contribute

1. **Fork the Repository**:
    Fork this repository to your GitHub account by clicking the "Fork" button at the top of the page.

2. **Clone Your Fork**:
    Clone the forked repository to your local machine:
    
    ```bash
    git clone https://github.com/yourusername/picotron-game-template.git
    ```

3. **Create a New Branch**:
    Create a new branch for your feature or bug fix:
    
    ```bash
    git checkout -b my-new-feature
    ```

4. **Make Your Changes**:
    Implement your feature, bug fix, or improvement. Be sure to write clear, concise, and well-documented code. Ensure that your changes do not break existing functionality by running the unit tests.

5. **Test Your Changes**:
    Before submitting your changes, run all tests to ensure that everything is working as expected:
    
    ```bash
    run_tests.lua
    ```

6. **Commit and Push**:
    Once you're satisfied with your changes, commit your work with a descriptive message and push it to your fork:
    
    ```bash
    git add .
    git commit -m "Add my feature or fix a bug"
    git push origin my-new-feature
    ```

7. **Submit a Pull Request**:
    Open a pull request from your fork back to the main repository. Provide a clear explanation of your changes and why they should be merged.

### Contribution Guidelines

- **Follow the Existing Code Style**: Ensure that your code matches the style and conventions used in the rest of the project.
- **Write Tests**: If applicable, add unit tests for new features or bug fixes.
- **Keep It Modular**: Ensure your changes are well-structured and maintainable, adhering to the modular nature of the project.
- **Document Your Changes**: Update relevant sections of the README and add comments to the code where necessary to help others understand your contribution.

### Reporting Issues

If you find a bug or have suggestions for improvements, feel free to open an issue on GitHub. Please provide detailed information to help us understand the issue or your proposal.

We look forward to your contributions!

## License

This project is licensed under the GNU General Public License v3.0. See the `LICENSE` file for more details.

## Additional Resources

- [Picotron Manual](https://www.lexaloffle.com/dl/docs/picotron_manual.html)
