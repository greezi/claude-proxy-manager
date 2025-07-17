# 快速开始

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-proxy-manager/main/install.sh | bash
```

## 基本使用

### 1. 添加代理商

```bash
# 添加官方 API
claude-proxy add official sk-ant-api03-xxx https://api.anthropic.com

# 添加代理商
claude-proxy add proxy1 sk-ant-api03-yyy https://proxy1.example.com
```

### 2. 切换代理商

```bash
# 查看所有代理商
claude-proxy list

# 切换到指定代理商
claude-proxy switch proxy1

# 查看当前代理商
claude-proxy current
```

### 3. 使配置生效

```bash
# 重新加载配置
source ~/.zshrc

# 或重启终端
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `claude-proxy add <name> <token> <url>` | 添加代理商 |
| `claude-proxy list` | 列出所有代理商 |
| `claude-proxy switch <name>` | 切换代理商 |
| `claude-proxy current` | 查看当前代理商 |
| `claude-proxy update <name> <token> <url>` | 更新代理商 |
| `claude-proxy remove <name>` | 删除代理商 |
| `claude-proxy help` | 查看帮助 |

就是这么简单！🎉