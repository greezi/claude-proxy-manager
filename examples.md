# 使用示例

## 快速开始

### 1. 安装工具

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-proxy-manager/main/install.sh | bash
```

### 2. 添加第一个代理商

```bash
# 添加官方 API（如果您有官方访问权限）
claude-proxy add official sk-ant-api03-your-official-token https://api.anthropic.com

# 添加代理商（替换为您的实际配置）
claude-proxy add proxy1 sk-ant-api03-your-proxy-token https://your-proxy-domain.com
```

### 3. 查看配置

```bash
# 列出所有代理商
claude-proxy list

# 输出示例：
# 已配置的代理商:
# 
# * official - https://api.anthropic.com - sk-ant-api03-your-of...
#   proxy1 - https://your-proxy-domain.com - sk-ant-api03-your-pr...
```

### 4. 切换代理商

```bash
# 切换到代理商
claude-proxy switch proxy1

# 查看当前使用的代理商
claude-proxy current
```

### 5. 使配置生效

```bash
# 重新加载配置
source ~/.zshrc

# 或者重启终端
```

## 常用场景

### 场景1: 多个代理商管理

```bash
# 添加多个代理商
claude-proxy add proxy-us sk-ant-xxx https://us.proxy.com
claude-proxy add proxy-eu sk-ant-yyy https://eu.proxy.com  
claude-proxy add proxy-asia sk-ant-zzz https://asia.proxy.com

# 根据需要切换
claude-proxy switch proxy-us    # 使用美国代理
claude-proxy switch proxy-eu    # 使用欧洲代理
claude-proxy switch proxy-asia  # 使用亚洲代理
```

### 场景2: 开发和生产环境

```bash
# 开发环境
claude-proxy add dev sk-ant-dev-token https://dev-api.example.com

# 生产环境  
claude-proxy add prod sk-ant-prod-token https://api.example.com

# 切换环境
claude-proxy switch dev   # 开发环境
claude-proxy switch prod  # 生产环境
```

### 场景3: 更新配置

```bash
# 更新代理商的令牌或URL
claude-proxy update proxy1 sk-ant-new-token https://new-url.com

# 如果当前正在使用该代理商，配置会自动生效
```

### 场景4: 清理不需要的配置

```bash
# 删除不再使用的代理商
claude-proxy remove old-proxy

# 查看剩余配置
claude-proxy list
```

## 验证配置

### 检查环境变量

```bash
# 查看当前环境变量
echo $ANTHROPIC_AUTH_TOKEN
echo $ANTHROPIC_BASE_URL
```

### 测试 Claude Code 连接

```bash
# 如果您安装了 claude-cli 或类似工具
claude --version

# 或者使用 curl 测试 API 连接
curl -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
     -H "Content-Type: application/json" \
     "$ANTHROPIC_BASE_URL/v1/messages" \
     -d '{"model":"claude-3-sonnet-20240229","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}'
```

## 故障排除示例

### 问题1: 环境变量未生效

```bash
# 检查当前 shell
echo $SHELL

# 手动加载配置
source ~/.zshrc

# 或者检查配置文件
cat ~/.zshrc | grep ANTHROPIC
```

### 问题2: 配置文件权限问题

```bash
# 检查配置文件权限
ls -la ~/.zshrc ~/.bash_profile ~/.bashrc

# 修复权限（如果需要）
chmod 644 ~/.zshrc
```

### 问题3: jq 未安装

```bash
# 手动安装 jq
brew install jq

# 验证安装
jq --version
```

## 高级用法

### 备份和恢复配置

```bash
# 备份配置
cp -r ~/.claude-proxy-manager ~/claude-proxy-backup

# 恢复配置
cp -r ~/claude-proxy-backup ~/.claude-proxy-manager
```

### 查看配置文件

```bash
# 查看代理商配置
cat ~/.claude-proxy-manager/providers.json | jq .

# 查看当前使用的代理商
cat ~/.claude-proxy-manager/current
```

### 批量操作

```bash
# 批量添加代理商（示例脚本）
#!/bin/bash
claude-proxy add proxy1 token1 https://proxy1.com
claude-proxy add proxy2 token2 https://proxy2.com
claude-proxy add proxy3 token3 https://proxy3.com
```