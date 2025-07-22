# Claude Code Proxy Manager

> 🤖 **This project is fully developed by Claude Code**

[中文文档](README.md) | **English**

A command-line tool for managing multiple Claude Code proxy configurations with quick switching capabilities.

## Features

- 🚀 **Quick Switching**: One-click switching between different Claude Code proxies
- 📝 **Configuration Management**: Add, remove, update proxy configurations
- 🔧 **Auto Configuration**: Automatically updates shell config files (`.bash_profile`, `.bashrc`, `.zshrc`)
- 🔑 **Dual Authentication**: Supports both AUTH_TOKEN and API_KEY authentication methods
- 🔄 **Smart Switching**: Automatically handles switching between different auth types without conflicts
- 💾 **Persistent Storage**: Secure local storage of configuration data
- 🎨 **User-Friendly Interface**: Colorful output with clear status indicators
- 🛡️ **Secure & Reliable**: Local storage only, no sensitive data uploaded

## System Requirements

- macOS or Linux system
- jq (will be installed automatically)
- macOS: Homebrew (will be installed automatically)
- Linux: Supported package managers (apt-get, yum, dnf, pacman, zypper)

## One-Click Installation

```bash
curl -fsSL https://raw.githubusercontent.com/greezi/claude-proxy-manager/main/install.sh | bash
```

Or manual installation:

```bash
# Clone repository
git clone https://github.com/greezi/claude-proxy-manager.git
cd claude-proxy-manager

# Run installation script
./install.sh
```

## Usage

### Basic Commands

```bash
# Show help
claude-proxy help

# Add proxy provider (defaults to AUTH_TOKEN)
claude-proxy add <name> <token> <base_url>

# Add proxy provider with auth type
claude-proxy add <name> <token> <base_url> <AUTH_TOKEN|API_KEY>

# List all providers
claude-proxy list

# Switch to provider
claude-proxy switch <name>

# Show current provider
claude-proxy current

# Update provider info
claude-proxy update <name> <new_token> <new_url> [auth_type]

# Remove provider
claude-proxy remove <name>
```

### Usage Examples

```bash
# Add official API (using API_KEY auth)
claude-proxy add official sk-ant-api03-xxx https://api.anthropic.com API_KEY

# Add proxy provider 1 (using AUTH_TOKEN auth)
claude-proxy add proxy1 sk-ant-api03-yyy https://api.proxy1.com AUTH_TOKEN

# Add proxy provider 2 (defaults to AUTH_TOKEN)
claude-proxy add proxy2 sk-ant-api03-zzz https://api.proxy2.com

# List all configured providers (shows auth type)
claude-proxy list

# Switch to proxy1
claude-proxy switch proxy1

# Show current provider
claude-proxy current

# Update provider info (including auth type change)
claude-proxy update proxy1 sk-ant-api03-new https://new.proxy1.com API_KEY

# Remove unwanted provider
claude-proxy remove proxy2
```

## Configuration Files

The tool automatically manages environment variables in the appropriate configuration files based on your operating system and shell:

**Supported Shells and Configuration Files:**
- Bash: `~/.bashrc` (Linux), `~/.bash_profile` (macOS)
- Zsh: `~/.zshrc`
- Fish: `~/.config/fish/config.fish`
- Others: `~/.profile`

Managed environment variables:
- `ANTHROPIC_AUTH_TOKEN`: Claude API authentication token (AUTH_TOKEN type)
- `ANTHROPIC_API_KEY`: Claude API key (API_KEY type)
- `ANTHROPIC_BASE_URL`: Claude API base URL

**Note**: The tool automatically manages the appropriate environment variables based on the provider's auth type and ensures only one authentication method exists at a time to avoid conflicts.

## Configuration Storage

All configuration data is stored in the `~/.claude-proxy-manager/` directory:

- `providers.json`: Provider configuration information
- `current`: Current active provider name

## Important Notes

1. **Restart Terminal**: After switching providers, restart your terminal or run the appropriate command based on your shell to apply changes:
   - Bash (Linux): `source ~/.bashrc`
   - Bash (macOS): `source ~/.bash_profile`
   - Zsh: `source ~/.zshrc`
   - Fish: `source ~/.config/fish/config.fish`
2. **Token Security**: All token information is stored locally only, please keep it secure
3. **Backup Configuration**: Recommend regular backup of `~/.claude-proxy-manager/` directory

## Troubleshooting

### Common Issues

**Q: Environment variables not taking effect after switching providers?**
A: Please restart your terminal or run the appropriate command based on your shell:
- Bash (Linux): `source ~/.bashrc`
- Bash (macOS): `source ~/.bash_profile`
- Zsh: `source ~/.zshrc`
- Fish: `source ~/.config/fish/config.fish`

**Q: jq command not found error?**
A: Run the appropriate command for your system to install jq:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt-get install jq`
- CentOS/RHEL: `sudo yum install epel-release && sudo yum install jq` (RHEL 7) or `sudo dnf install jq` (RHEL 8+)
- Fedora: `sudo dnf install jq`
- Arch Linux: `sudo pacman -S jq`
- openSUSE: `sudo zypper install jq`

**Q: Cannot write to configuration files?**
A: Check permissions of shell configuration files, ensure current user has write access

**Q: Provider list is empty?**
A: Use `claude-proxy add` command to add your first provider configuration

**Q: Authentication conflict error after switching providers?**
A: This typically occurs when switching between providers with different auth types. The tool automatically handles this issue - ensure you restart the terminal or run the source command to apply changes. If issues persist, manually edit your shell config file to ensure only one authentication environment variable exists.

### Manual Uninstall

```bash
# Remove command
sudo rm -f /usr/local/bin/claude-proxy

# Remove configuration directory
rm -rf ~/.claude-proxy-manager

# Manually clean environment variables (optional)
# Edit ~/.zshrc etc., remove the following lines:
# - export ANTHROPIC_AUTH_TOKEN=...
# - export ANTHROPIC_API_KEY=...
# - export ANTHROPIC_BASE_URL=...
# - unset ANTHROPIC_AUTH_TOKEN
# - unset ANTHROPIC_API_KEY
```

## Development

### Local Development

```bash
# Clone repository
git clone https://github.com/greezi/claude-proxy-manager.git
cd claude-proxy-manager

# Run script directly
./claude-proxy-manager.sh help

# Local installation test
./install.sh
```

### Contributing

Contributions are welcome! Please submit Issues and Pull Requests.

1. Fork this repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### v1.0.1 (2025-07-22)
- Fix: Resolve environment variable conflicts when switching between different auth type providers
- Add: Automatically clean opposing auth environment variables to avoid authentication conflicts
- Improve: Update documentation to explain auth type functionality

### v1.0.0 (2025-07-17)
- Initial release
- Add/remove/update/list proxy providers
- Quick switching functionality
- Support for both AUTH_TOKEN and API_KEY authentication methods
- Complete test suite
- Comprehensive documentation

## Support

If you find this tool useful, please give it a ⭐️ Star!

For issues or suggestions, please submit an [Issue](https://github.com/greezi/claude-proxy-manager/issues).