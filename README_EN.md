# Claude Code Proxy Manager

[中文文档](README.md) | **English**

A command-line tool for managing multiple Claude Code proxy configurations with quick switching capabilities.

## Features

- 🚀 **Quick Switching**: One-click switching between different Claude Code proxies
- 📝 **Configuration Management**: Add, remove, update proxy configurations
- 🔧 **Auto Configuration**: Automatically updates shell config files (`.bash_profile`, `.bashrc`, `.zshrc`)
- 💾 **Persistent Storage**: Secure local storage of configuration data
- 🎨 **User-Friendly Interface**: Colorful output with clear status indicators
- 🛡️ **Secure & Reliable**: Local storage only, no sensitive data uploaded

## System Requirements

- macOS system
- Homebrew (will be installed automatically)
- jq (will be installed automatically)

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

# Add proxy provider
claude-proxy add <name> <token> <base_url>

# List all providers
claude-proxy list

# Switch to provider
claude-proxy switch <name>

# Show current provider
claude-proxy current

# Update provider info
claude-proxy update <name> <new_token> <new_url>

# Remove provider
claude-proxy remove <name>
```

### Usage Examples

```bash
# Add official API
claude-proxy add official sk-ant-api03-xxx https://api.anthropic.com

# Add proxy provider 1
claude-proxy add proxy1 sk-ant-api03-yyy https://api.proxy1.com

# Add proxy provider 2  
claude-proxy add proxy2 sk-ant-api03-zzz https://api.proxy2.com

# List all configured providers
claude-proxy list

# Switch to proxy1
claude-proxy switch proxy1

# Show current provider
claude-proxy current

# Update provider info
claude-proxy update proxy1 sk-ant-api03-new https://new.proxy1.com

# Remove unwanted provider
claude-proxy remove proxy2
```

## Configuration Files

The tool automatically manages environment variables in these configuration files:

- `~/.bash_profile`
- `~/.bashrc` 
- `~/.zshrc`

Managed environment variables:
- `ANTHROPIC_AUTH_TOKEN`: Claude API authentication token
- `ANTHROPIC_BASE_URL`: Claude API base URL

## Configuration Storage

All configuration data is stored in the `~/.claude-proxy-manager/` directory:

- `providers.json`: Provider configuration information
- `current`: Current active provider name

## Important Notes

1. **Restart Terminal**: After switching providers, restart your terminal or run `source ~/.zshrc` to apply changes
2. **Token Security**: All token information is stored locally only, please keep it secure
3. **Backup Configuration**: Recommend regular backup of `~/.claude-proxy-manager/` directory

## Troubleshooting

### Common Issues

**Q: Environment variables not taking effect after switching providers?**
A: Please restart your terminal or run `source ~/.zshrc`

**Q: jq command not found error?**
A: Run `brew install jq` to install jq

**Q: Cannot write to configuration files?**
A: Check permissions of shell configuration files, ensure current user has write access

**Q: Provider list is empty?**
A: Use `claude-proxy add` command to add your first provider configuration

### Manual Uninstall

```bash
# Remove command
sudo rm -f /usr/local/bin/claude-proxy

# Remove configuration directory
rm -rf ~/.claude-proxy-manager

# Manually clean environment variables (optional)
# Edit ~/.zshrc etc., remove ANTHROPIC_AUTH_TOKEN and ANTHROPIC_BASE_URL related lines
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

### v1.0.0 (2025-01-17)
- Initial release
- Add/remove/update/list proxy providers
- Quick switching functionality
- Complete test suite
- Comprehensive documentation

## Support

If you find this tool useful, please give it a ⭐️ Star!

For issues or suggestions, please submit an [Issue](https://github.com/greezi/claude-proxy-manager/issues).