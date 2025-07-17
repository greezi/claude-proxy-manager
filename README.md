# Claude Code 代理商管理器

一个用于管理多个 Claude Code 代理商配置的命令行工具，支持快速切换不同的 API 服务提供商。

## 功能特性

- 🚀 **快速切换**: 一键切换不同的 Claude Code 代理商
- 📝 **配置管理**: 支持添加、删除、更新代理商配置
- 🔧 **自动配置**: 自动更新 shell 配置文件 (`.bash_profile`, `.bashrc`, `.zshrc`)
- 💾 **持久化存储**: 配置信息安全存储在本地
- 🎨 **友好界面**: 彩色输出，清晰的状态提示
- 🛡️ **安全可靠**: 本地存储，不上传任何敏感信息

## 系统要求

- macOS 系统
- Homebrew (安装脚本会自动安装)
- jq (安装脚本会自动安装)

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-proxy-manager/main/install.sh | bash
```

或者手动安装：

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/claude-proxy-manager.git
cd claude-proxy-manager

# 运行安装脚本
./install.sh
```

## 使用方法

### 基本命令

```bash
# 查看帮助
claude-proxy help

# 添加代理商
claude-proxy add <名称> <令牌> <基础URL>

# 列出所有代理商
claude-proxy list

# 切换代理商
claude-proxy switch <名称>

# 查看当前代理商
claude-proxy current

# 更新代理商信息
claude-proxy update <名称> <新令牌> <新URL>

# 删除代理商
claude-proxy remove <名称>
```

### 使用示例

```bash
# 添加官方 API
claude-proxy add official sk-ant-api03-xxx https://api.anthropic.com

# 添加代理商1
claude-proxy add proxy1 sk-ant-api03-yyy https://api.proxy1.com

# 添加代理商2  
claude-proxy add proxy2 sk-ant-api03-zzz https://api.proxy2.com

# 查看所有配置的代理商
claude-proxy list

# 切换到代理商1
claude-proxy switch proxy1

# 查看当前使用的代理商
claude-proxy current

# 更新代理商信息
claude-proxy update proxy1 sk-ant-api03-new https://new.proxy1.com

# 删除不需要的代理商
claude-proxy remove proxy2
```

## 配置文件

工具会自动管理以下配置文件中的环境变量：

- `~/.bash_profile`
- `~/.bashrc` 
- `~/.zshrc`

管理的环境变量：
- `ANTHROPIC_AUTH_TOKEN`: Claude API 认证令牌
- `ANTHROPIC_BASE_URL`: Claude API 基础URL

## 配置存储

所有配置信息存储在 `~/.claude-proxy-manager/` 目录下：

- `providers.json`: 代理商配置信息
- `current`: 当前使用的代理商名称

## 注意事项

1. **重启终端**: 切换代理商后需要重启终端或运行 `source ~/.zshrc` 使配置生效
2. **令牌安全**: 所有令牌信息仅存储在本地，请妥善保管
3. **备份配置**: 建议定期备份 `~/.claude-proxy-manager/` 目录

## 故障排除

### 常见问题

**Q: 切换代理商后环境变量没有生效？**
A: 请重启终端或运行 `source ~/.zshrc`

**Q: 提示 jq 命令未找到？**
A: 运行 `brew install jq` 安装 jq

**Q: 无法写入配置文件？**
A: 检查 shell 配置文件的权限，确保当前用户有写入权限

**Q: 代理商列表为空？**
A: 使用 `claude-proxy add` 命令添加第一个代理商配置

### 手动卸载

```bash
# 删除命令
sudo rm -f /usr/local/bin/claude-proxy

# 删除配置目录
rm -rf ~/.claude-proxy-manager

# 手动清理环境变量（可选）
# 编辑 ~/.zshrc 等文件，删除 ANTHROPIC_AUTH_TOKEN 和 ANTHROPIC_BASE_URL 相关行
```

## 开发

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/claude-proxy-manager.git
cd claude-proxy-manager

# 直接运行脚本
./claude-proxy-manager.sh help

# 本地安装测试
./install.sh
```

### 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 更新日志

### v1.0.0 (2024-07-17)
- 初始版本发布
- 支持代理商的增删改查
- 支持快速切换功能
- 一键安装脚本
- 完整的文档

## 支持

如果您觉得这个工具有用，请给个 ⭐️ Star！

如有问题或建议，请提交 [Issue](https://github.com/YOUR_USERNAME/claude-proxy-manager/issues)。