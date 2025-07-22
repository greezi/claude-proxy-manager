# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Proxy Manager is a command-line tool for managing multiple Claude Code proxy configurations with quick switching capabilities. It's a bash-based tool that helps users manage different API endpoints and tokens for Claude Code.

## Core Architecture

### Main Components

- `claude-proxy-manager.sh` - Main script containing all functionality
- `install.sh` - Installation script for macOS systems
- `test.sh` - Comprehensive test suite for all functions

### Key Functions in claude-proxy-manager.sh

- `add_provider()` - Add new proxy configurations
- `remove_provider()` - Remove existing configurations  
- `switch_provider()` - Switch between different proxy providers
- `list_providers()` - Display all configured providers
- `update_provider()` - Update existing provider information
- `update_env_vars()` - Manage environment variables in shell config files

### Configuration Management

The tool manages configurations in `~/.claude-proxy-manager/`:
- `providers.json` - JSON file storing all provider configurations
- `current` - File containing the name of currently active provider

Environment variables managed:
- `ANTHROPIC_AUTH_TOKEN` - API authentication token
- `ANTHROPIC_BASE_URL` - API base URL

Shell configuration files updated automatically based on OS and shell:
- **Bash**: `~/.bashrc` (Linux), `~/.bash_profile` (macOS)
- **Zsh**: `~/.zshrc`
- **Fish**: `~/.config/fish/config.fish`
- **Others**: `~/.profile`

## Development Commands

### Testing
```bash
# Run comprehensive test suite
./test.sh
```

### Local Development
```bash
# Run script directly for testing
./claude-proxy-manager.sh help

# Test specific commands
./claude-proxy-manager.sh add test-provider sk-test-token https://test.com
./claude-proxy-manager.sh list
./claude-proxy-manager.sh switch test-provider
```

### Installation Testing
```bash
# Local installation (for development)
./install.sh
```

## Dependencies

- `jq` - JSON processing (automatically installed by install script)
- `curl` - HTTP requests
- `sed` - Text processing
- **macOS**: Homebrew (automatically installed if missing)
- **Linux**: Supported package managers (apt-get, yum, dnf, pacman, zypper)

## System Requirements

- macOS or Linux systems (Windows not supported)
- Bash shell environment (also supports Zsh, Fish)
- Administrative privileges for installation (`/usr/local/bin` access)

## Important Notes

- All configuration data is stored locally only
- The tool automatically backs up shell config files before modifications
- Provider switching requires terminal restart or `source ~/.zshrc` to take effect
- JSON configuration uses jq for safe parsing and manipulation
- Color-coded output for better user experience