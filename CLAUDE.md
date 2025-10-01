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

## Home Assistant Automations

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
