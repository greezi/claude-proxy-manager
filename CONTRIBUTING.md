# 贡献指南

感谢您对 Claude Proxy Manager 项目的关注！我们欢迎各种形式的贡献。

## 如何贡献

### 报告 Bug

如果您发现了 bug，请通过 [GitHub Issues](https://github.com/greezi/claude-proxy-manager/issues) 报告：

1. 使用清晰、描述性的标题
2. 详细描述重现步骤
3. 提供预期行为和实际行为的对比
4. 包含系统信息（macOS 版本、shell 类型等）
5. 如果可能，提供错误日志

### 建议功能

我们欢迎新功能建议：

1. 检查是否已有相似的建议
2. 详细描述功能需求和使用场景
3. 解释为什么这个功能对用户有价值

### 提交代码

#### 开发环境设置

```bash
# 克隆仓库
git clone https://github.com/greezi/claude-proxy-manager.git
cd claude-proxy-manager

# 安装依赖
brew install jq

# 运行测试
./test.sh
```

#### 代码规范

- 使用 4 个空格缩进
- 函数名使用下划线命名法 (snake_case)
- 变量名使用下划线命名法
- 添加适当的注释
- 保持代码简洁易读

#### 提交流程

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 进行更改
4. 运行测试确保通过 (`./test.sh`)
5. 提交更改 (`git commit -m 'Add amazing feature'`)
6. 推送到分支 (`git push origin feature/amazing-feature`)
7. 创建 Pull Request

#### 提交信息规范

使用清晰的提交信息：

```
类型(范围): 简短描述

详细描述（可选）

- 相关 issue: #123
```

类型：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 测试

在提交代码前，请确保：

1. 所有现有测试通过
2. 新功能包含相应测试
3. 代码覆盖率不降低

运行测试：
```bash
./test.sh
```

### 文档

如果您的更改影响用户界面或功能：

1. 更新 README.md
2. 更新相关示例
3. 更新 CHANGELOG.md

## 代码审查

所有提交都需要经过代码审查：

1. 确保代码符合项目规范
2. 功能正确实现
3. 包含适当的测试
4. 文档完整

## 发布流程

维护者负责版本发布：

1. 更新版本号
2. 更新 CHANGELOG.md
3. 创建 Git 标签
4. 发布 GitHub Release

## 社区准则

请遵循以下准则：

- 保持友善和专业
- 尊重不同观点
- 专注于建设性反馈
- 帮助新贡献者

## 获得帮助

如果您需要帮助：

1. 查看现有文档
2. 搜索已有 Issues
3. 创建新 Issue 询问

感谢您的贡献！