# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal utilities repository containing bash configuration scripts and Home Assistant automation configurations. The repository is primarily used for:
- Sharing bash utility functions and aliases across development environments
- Managing Home Assistant automations (YAML configurations)
- Quick deployment of bash configurations

## Repository Structure

```
.
├── .bashrc              # Bash configuration with custom functions/aliases
├── .grc.conf           # GRC (Generic Colouriser) configuration
├── deploy              # Deployment script to copy configs to home directory
└── HomeAssistant/
    └── Automations/
        ├── AC/
        ├── ElectricCarCharging/    # EV smart charging automations
        └── HeatPump/
```

## Deployment

To deploy bash configurations to the local environment:

```bash
./deploy
```

This script copies `.bashrc` and `.grc.conf` to the home directory and sources the bashrc.

## Bash Utilities

The `.bashrc` file contains numerous custom functions for different development workflows:

### Docker & Development Environment
- `dl [container_name] [user]` - Log into Docker containers (project-aware)
- `up` - Start project-specific services (project-aware: api, web, car-bro-crm)
- `copy-bashrc` / `copy-bashrc-ci` - Copy bashrc into running containers

### PHP/Laravel Specific
- `a <artisan_command>` - Run Laravel artisan commands in Docker
- `s <command>` - Run PHP Spark (CodeIgniter)
- `ide` - Generate Laravel IDE helper files
- `tests` - Run PHPUnit tests in parallel
- `apidoc` - Generate API documentation
- `tinker` - Launch Laravel Tinker

### Git & Deployment
- `dt` - Deploy to test/staging (auto-merges current branch to staging)

### Database Operations
- `get-db <server>` - Fetch database dumps from remote servers (gardest, shopper-shadow, carbro)
- `fetch-db` - Generic database fetch function

### AWS/S3
- `s3 <get|put> <staging|production>` - Manage environment files in S3 with diff preview
- `login` - AWS ECR login

### Logging
- `log [env]` - Tail project-specific log files with GRC colorization

### Permissions
- `cmod` - Set correct file ownership/permissions for Docker web projects

### Other
- `carbro-prod` - SSH and exec into production CarBro container
- `npmw` - Run npm watch with increased memory
- `fixpath` - Set Docker path conversion for Windows

## Home Assistant

This repository contains Home Assistant configurations and automations that run on a separate Home Assistant instance. All YAML files should follow modern Home Assistant best practices.

### Directory Structure

- `HomeAssistant/Automations/` - Automation YAML files organized by feature
  - `ElectricCarCharging/` - EV smart charging system
  - `AC/` - Air conditioning automations
  - `HeatPump/` - Heat pump control automations
- `HomeAssistant/Configurations/` - Configuration files and sensors

### Working with Home Assistant Configurations

**IMPORTANT - Entity IDs:**
When creating or modifying Home Assistant automations, scripts, or templates, **ALWAYS ask the user for specific entity IDs** rather than making them up or using placeholder names. Entity IDs are installation-specific and must match the user's actual Home Assistant setup.

**Why this matters:**
- Entity IDs vary between installations (e.g., `sensor.temperature_living_room` vs `sensor.temp_lr`)
- Users should be able to copy-paste the generated YAML directly into Home Assistant for testing
- Incorrect entity IDs cause automations to fail silently or produce errors
- Generic placeholders like `sensor.example` or `light.placeholder` are not helpful

**How to handle entity IDs:**
1. **Ask first** - Request the specific entity IDs from the user before writing automations
2. **Be specific** - Ask for each entity type needed (sensors, switches, lights, etc.)
3. **Confirm format** - Verify the entity domain matches the usage (e.g., `switch.` for switches, `sensor.` for sensors)
4. **List requirements** - If multiple entities are needed, list them all upfront

**Example interaction:**
```
User: Create an automation to turn on the lights when motion is detected
Assistant: I'll help you create that automation. To make it ready for copy-paste testing,
I need the following entity IDs from your Home Assistant:
- Motion sensor entity ID (e.g., binary_sensor.motion_living_room)
- Light entity ID to control (e.g., light.living_room)
- (Optional) Any condition sensors or helper entities

Once you provide these, I'll create the complete automation.
```

### Modern Home Assistant Best Practices

#### YAML Structure & Organization

**File Organization:**
- Group related automations by feature in subdirectories
- Use descriptive filenames that reflect the automation's purpose
- Keep individual YAML files focused on a single responsibility
- Use `!include` directives in main configuration to split large files

**YAML Syntax:**
- Use 2 spaces for indentation (never tabs)
- Always include `alias` and `description` fields for automations
- Add descriptive comments using `#` for complex logic
- Use multi-line strings with `>` or `>-` for long descriptions/templates
- Use `|` for multi-line strings where line breaks matter

**Automation Structure:**
```yaml
alias: Descriptive Name - Action Pattern
description: >-
  Clear explanation of what this automation does,
  when it triggers, and what actions it performs
trigger:
  - platform: state
    entity_id: sensor.example
    to: "on"
condition:
  - condition: state
    entity_id: input_boolean.enable_feature
    state: "on"
action:
  - service: light.turn_on
    target:
      entity_id: light.example
mode: single  # Options: single, restart, queued, parallel
```

#### Trigger Best Practices

**State Triggers:**
- Always specify `to:` or `from:` to avoid unnecessary triggers
- Use `for:` duration to debounce rapid state changes
- Prefer specific state values over checking for "not off"

**Time Triggers:**
- Use `platform: time` for specific times
- Use `platform: time_pattern` for recurring intervals
- Consider timezone implications for cross-day calculations

**Template Triggers:**
- Keep templates simple and efficient
- Avoid triggers that evaluate constantly
- Use `for:` to prevent trigger spam

#### Condition Best Practices

**Condition Structure:**
- Use `and` conditions by default (implicit at root level)
- Use explicit `or` and `not` for complex logic
- Order conditions from cheapest to most expensive evaluation
- Use `condition: template` for complex checks that can't use other condition types

**Time-based Conditions:**
```yaml
condition:
  - condition: time
    after: "06:00:00"
    before: "22:00:00"
  - condition: sun
    after: sunset
    before: sunrise
```

#### Action Best Practices

**Service Calls:**
- Use `target:` instead of deprecated `entity_id:` in data
- Use `data:` for static values, `data_template:` only when templating is needed
- Add delays between rapid service calls to prevent race conditions
- Use `continue_on_error: true` for non-critical actions

**Choose-When Pattern:**
```yaml
action:
  - choose:
      - conditions:
          - condition: state
            entity_id: input_boolean.mode_a
            state: "on"
        sequence:
          - service: switch.turn_on
            target:
              entity_id: switch.device_a
      - conditions:
          - condition: state
            entity_id: input_boolean.mode_b
            state: "on"
        sequence:
          - service: switch.turn_on
            target:
              entity_id: switch.device_b
    default:
      - service: switch.turn_off
        target:
          entity_id: switch.all_devices
```

#### Jinja2 Templating Best Practices

**Template Structure:**
- Break complex templates into sections with comments
- Use meaningful variable names that explain purpose
- Define all variables at the top of the template
- Use `{% set %}` for variables, avoid reassignment
- Use filters for data transformation: `| float(0)`, `| int(0)`, `| default('unknown')`

**Common Patterns:**
```jinja2
{# Define variables #}
{% set sensor_value = states('sensor.example') | float(0) %}
{% set threshold = 25.0 %}

{# Safe state access with defaults #}
{% set temperature = states('sensor.temperature') | float(0) %}
{% set humidity = state_attr('sensor.weather', 'humidity') | float(0) %}

{# Date/time handling #}
{% set now_dt = now() %}
{% set next_hour = (now_dt.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)) %}
{% set tomorrow_8am = today_at('08:00') + timedelta(days=1) %}

{# List operations #}
{% set prices = state_attr('sensor.nordpool', 'today') or [] %}
{% set filtered = prices | selectattr('value', 'lt', 50) | list %}
{% set sorted_prices = prices | sort(attribute='value') %}
{% set total = prices | map(attribute='value') | sum %}

{# Safe dictionary access #}
{% if item is mapping %}
  {% set value = item.value if 'value' in item else item.price %}
{% endif %}
```

**Performance Considerations:**
- Cache expensive calculations in variables
- Avoid nested loops when possible
- Use `| selectattr()` and `| map()` for filtering/transformation
- Limit template re-evaluation by using input_number/input_text for intermediate values
- Use `{% break %}` to exit loops early when condition is met

**Error Handling:**
- Always provide default values: `| float(0)`, `| default('unknown')`
- Check for `none` and `'unknown'` before accessing attributes
- Handle edge cases (e.g., "24:00" time format, missing tomorrow data)
- Test templates with missing/invalid sensor data

#### State Management

**Helper Entities:**
- Use `input_number` for numeric values that need persistence
- Use `input_boolean` for toggles and mode switches
- Use `input_text` for string storage
- Use `input_select` for dropdown choices
- Use `input_datetime` for time/date pickers

**Entity Naming:**
- Use descriptive, hierarchical names: `input_number.charging_start`
- Prefix related entities: `ev_charging_hours_needed`, `ev_charging_debug`
- Use snake_case for entity IDs
- Use friendly names for UI display

#### Debugging & Testing

**Debug Patterns:**
- Use `input_boolean` flags to enable/disable debug mode
- Use `logbook.log` for structured logging
- Use `persistent_notification.create` for visible debug output
- Include relevant state information in debug messages
- Log calculation inputs and outputs for complex templates

**Debug Mode Example:**
```yaml
- choose:
    - conditions:
        - condition: state
          entity_id: input_boolean.debug_mode
          state: "on"
      sequence:
        - service: logbook.log
          data:
            name: "Feature Name"
            message: >
              Input: {{ states('sensor.input') }} |
              Calculated: {{ calculated_value }} |
              Result: {{ final_result }}
        - service: persistent_notification.create
          data:
            title: "Debug: Feature Name"
            message: "Detailed debug information here"
```

**Testing Approaches:**
- Test automations with Developer Tools > Services
- Use Template Editor in Developer Tools for Jinja2 testing
- Enable debug mode to verify calculation logic
- Test edge cases: missing sensors, invalid data, boundary conditions
- Test time-based automations by temporarily adjusting trigger times

#### Integration Patterns

**Nord Pool Price Integration:**
- Handle both 15-minute and hourly intervals
- Check `tomorrow_valid` before using tomorrow data
- Convert interval data to hourly averages when needed
- Handle edge cases like "24:00" time format
- Sort by timestamp to ensure chronological order

**Multi-day Scheduling:**
- Use `today_at()` + `timedelta(days=1)` for next-day calculations
- Filter time ranges with `>=` and `<` comparisons
- Handle transitions across midnight properly
- Consider timezone conversions with `as_local()`

**Sensor Dependencies:**
- Check sensor availability before accessing attributes
- Provide sensible fallbacks for offline sensors
- Use `states()` function for current state
- Use `state_attr()` for attributes
- Test automations when dependent sensors are unavailable

#### Mode Selection

Choose the appropriate mode for your automation:

- `single` - Default. Ignores new triggers while running
- `restart` - Starts over when triggered while running
- `queued` - Queues triggers and runs them sequentially (optionally with `max`)
- `parallel` - Allows multiple simultaneous runs (optionally with `max`)

Use `queued` or `parallel` with `max: 10` to prevent runaway automations.

#### Performance & Resource Management

**Optimization:**
- Minimize template sensor updates by using good trigger conditions
- Avoid unnecessary service calls with proper conditions
- Use `state_attr()` instead of `states.sensor.x.attributes.y`
- Cache attribute lookups in variables when using multiple times
- Prefer binary sensors over template sensors when possible

**Resource Limits:**
- Limit automation triggers to necessary events
- Use `for:` duration to debounce sensors
- Avoid rapidly repeating time_pattern triggers
- Set appropriate `max_exceeded` behavior for queued/parallel modes

### Example Automations in This Repository

### Electric Car Charging System

Located in `HomeAssistant/Automations/ElectricCarCharging/`, this is a smart EV charging system that optimizes charging times based on Nord Pool electricity prices:

**mainCharging.yaml**: Main scheduling automation
- Triggers when car is plugged in (sensor: `sensor.laadimise_olek_2`)
- Calculates optimal charging start time using Nord Pool price data
- Finds cheapest consecutive block of hours before 08:00 deadline
- Sets `input_number.charging_start` (hour 0-23) and `input_number.charging_time` (duration in hours)
- Uses complex Jinja2 template logic to:
  - Parse today/tomorrow prices from `sensor.nordpool`
  - Filter available time slots between next full hour and deadline
  - Find cheapest consecutive block using sum minimization
  - Includes debug mode with logbook entries and persistent notifications

**startCharging.yaml**: Start automation
- Triggers every hour (minutes=0, seconds=0)
- Checks if car is plugged in
- Compares current hour to scheduled start hour
- Turns on `switch.zoe_3em` at scheduled time

**stopCharging.yaml**: Stop automation
- Triggers when charging duration elapsed or car unplugged
- Calculates end time from start hour + duration
- Turns off `switch.zoe_3em`

The system is designed to minimize electricity costs by charging during the cheapest hours while ensuring the car is fully charged by 08:00.

## Development Context

This repository appears to be used across multiple projects including:
- Laravel/PHP applications (CarBro, Casafy, Fractory)
- CodeIgniter applications (Shopper Shadow)
- React/Node.js applications (admin, client, web)

The bash functions are context-aware and behave differently based on the current working directory.
