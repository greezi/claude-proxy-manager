#!/bin/bash

# Claude Code 代理商管理器 - 一键安装脚本
# 版本: 1.0.0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 安装路径
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="claude-proxy"
SCRIPT_URL="https://raw.githubusercontent.com/greezi/claude-proxy-manager/main/claude-proxy-manager.sh"

echo -e "${BLUE}Claude Code 代理商管理器 - 安装程序${NC}"
echo "========================================"

# 检查是否为 macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}错误: 此脚本仅支持 macOS 系统${NC}"
    exit 1
fi

# 检查是否安装了 jq
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}检测到未安装 jq，正在安装...${NC}"
        
        # 检查是否安装了 Homebrew
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}检测到未安装 Homebrew，正在安装...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # 添加 Homebrew 到 PATH
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        
        # 安装 jq
        brew install jq
        
        if ! command -v jq &> /dev/null; then
            echo -e "${RED}错误: jq 安装失败${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}jq 安装成功${NC}"
    else
        echo -e "${GREEN}jq 已安装${NC}"
    fi
}

# 下载并安装脚本
install_script() {
    echo -e "${YELLOW}正在下载脚本...${NC}"
    
    # 如果是从本地安装（开发模式）
    if [[ -f "claude-proxy-manager.sh" ]]; then
        echo -e "${YELLOW}检测到本地脚本文件，使用本地版本...${NC}"
        sudo cp claude-proxy-manager.sh "$INSTALL_DIR/$SCRIPT_NAME"
    else
        # 从 GitHub 下载
        if ! curl -fsSL "$SCRIPT_URL" -o "/tmp/$SCRIPT_NAME"; then
            echo -e "${RED}错误: 下载脚本失败${NC}"
            echo "请检查网络连接或手动下载安装"
            exit 1
        fi
        
        # 安装脚本
        sudo mv "/tmp/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    # 设置执行权限
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    echo -e "${GREEN}脚本安装成功: $INSTALL_DIR/$SCRIPT_NAME${NC}"
}

# 验证安装
verify_installation() {
    if command -v claude-proxy &> /dev/null; then
        echo -e "${GREEN}安装验证成功！${NC}"
        echo ""
        echo -e "${BLUE}使用方法:${NC}"
        echo "  claude-proxy help    # 查看帮助"
        echo "  claude-proxy add <name> <token> <url>  # 添加代理商"
        echo "  claude-proxy list    # 列出所有代理商"
        echo "  claude-proxy switch <name>  # 切换代理商"
        echo ""
        echo -e "${YELLOW}示例:${NC}"
        echo "  claude-proxy add official sk-ant-xxx https://api.anthropic.com"
        echo "  claude-proxy add proxy1 sk-ant-yyy https://proxy1.example.com"
        echo "  claude-proxy switch proxy1"
        return 0
    else
        echo -e "${RED}安装验证失败${NC}"
        return 1
    fi
}

# 主安装流程
main() {
    echo -e "${YELLOW}开始安装...${NC}"
    echo ""
    
    # 检查并安装依赖
    check_jq
    echo ""
    
    # 安装脚本
    install_script
    echo ""
    
    # 验证安装
    if verify_installation; then
        echo ""
        echo -e "${GREEN}🎉 Claude Code 代理商管理器安装完成！${NC}"
        echo ""
        echo -e "${BLUE}接下来您可以:${NC}"
        echo "1. 添加您的第一个代理商配置"
        echo "2. 使用 'claude-proxy help' 查看完整帮助"
        echo ""
        echo -e "${YELLOW}注意: 切换代理商后需要重启终端或运行 'source ~/.zshrc' 使配置生效${NC}"
    else
        echo -e "${RED}安装失败，请检查错误信息${NC}"
        exit 1
    fi
}

# 运行安装
main "$@"