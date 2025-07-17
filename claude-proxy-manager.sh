#!/bin/bash

# Claude Code 代理商管理器
# 版本: 1.0.0
# 作者: Claude Proxy Manager

# 配置文件路径
CONFIG_DIR="$HOME/.claude-proxy-manager"
PROVIDERS_FILE="$CONFIG_DIR/providers.json"
CURRENT_FILE="$CONFIG_DIR/current"

# Shell 配置文件
SHELL_CONFIGS=("$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zshrc")

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 初始化配置目录
init_config() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        echo "[]" > "$PROVIDERS_FILE"
        echo -e "${GREEN}配置目录已创建: $CONFIG_DIR${NC}"
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Claude Code 代理商管理器${NC}"
    echo ""
    echo "用法: claude-proxy [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  add <name> <token> <base_url>  添加新的代理商"
    echo "  remove <name>                  删除代理商"
    echo "  list                          列出所有代理商"
    echo "  switch <name>                 切换到指定代理商"
    echo "  current                       显示当前使用的代理商"
    echo "  update <name> <token> <url>   更新代理商信息"
    echo "  help                          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  claude-proxy add official sk-ant-xxx https://api.anthropic.com"
    echo "  claude-proxy add proxy1 sk-ant-yyy https://proxy1.example.com"
    echo "  claude-proxy switch proxy1"
    echo "  claude-proxy list"
}

# 检查 jq 是否安装
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}错误: 需要安装 jq 来处理 JSON 数据${NC}"
        echo "请运行: brew install jq"
        exit 1
    fi
}

# 添加代理商
add_provider() {
    local name="$1"
    local token="$2"
    local base_url="$3"
    
    if [ -z "$name" ] || [ -z "$token" ] || [ -z "$base_url" ]; then
        echo -e "${RED}错误: 请提供完整的参数 (名称 令牌 基础URL)${NC}"
        return 1
    fi
    
    # 检查是否已存在
    if jq -e ".[] | select(.name == \"$name\")" "$PROVIDERS_FILE" > /dev/null 2>&1; then
        echo -e "${YELLOW}警告: 代理商 '$name' 已存在，使用 update 命令来更新${NC}"
        return 1
    fi
    
    # 添加新代理商
    local new_provider=$(jq -n --arg name "$name" --arg token "$token" --arg url "$base_url" \
        '{name: $name, token: $token, base_url: $url}')
    
    jq ". += [$new_provider]" "$PROVIDERS_FILE" > "${PROVIDERS_FILE}.tmp" && \
    mv "${PROVIDERS_FILE}.tmp" "$PROVIDERS_FILE"
    
    echo -e "${GREEN}代理商 '$name' 已添加${NC}"
}

# 删除代理商
remove_provider() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo -e "${RED}错误: 请提供代理商名称${NC}"
        return 1
    fi
    
    # 检查是否存在
    if ! jq -e ".[] | select(.name == \"$name\")" "$PROVIDERS_FILE" > /dev/null 2>&1; then
        echo -e "${RED}错误: 代理商 '$name' 不存在${NC}"
        return 1
    fi
    
    # 删除代理商
    jq "map(select(.name != \"$name\"))" "$PROVIDERS_FILE" > "${PROVIDERS_FILE}.tmp" && \
    mv "${PROVIDERS_FILE}.tmp" "$PROVIDERS_FILE"
    
    # 如果删除的是当前使用的代理商，清除当前设置
    if [ -f "$CURRENT_FILE" ] && [ "$(cat "$CURRENT_FILE")" = "$name" ]; then
        rm -f "$CURRENT_FILE"
        clear_env_vars
        echo -e "${YELLOW}已清除当前代理商设置${NC}"
    fi
    
    echo -e "${GREEN}代理商 '$name' 已删除${NC}"
}

# 列出所有代理商
list_providers() {
    local current_provider=""
    if [ -f "$CURRENT_FILE" ]; then
        current_provider=$(cat "$CURRENT_FILE")
    fi
    
    echo -e "${BLUE}已配置的代理商:${NC}"
    echo ""
    
    if [ "$(jq length "$PROVIDERS_FILE")" -eq 0 ]; then
        echo -e "${YELLOW}暂无配置的代理商${NC}"
        return
    fi
    
    jq -r '.[] | "\(.name)|\(.base_url)|\(.token[0:20])..."' "$PROVIDERS_FILE" | \
    while IFS='|' read -r name url token; do
        if [ "$name" = "$current_provider" ]; then
            echo -e "${GREEN}* $name${NC} - $url - $token"
        else
            echo -e "  $name - $url - $token"
        fi
    done
}

# 更新代理商
update_provider() {
    local name="$1"
    local token="$2"
    local base_url="$3"
    
    if [ -z "$name" ] || [ -z "$token" ] || [ -z "$base_url" ]; then
        echo -e "${RED}错误: 请提供完整的参数 (名称 令牌 基础URL)${NC}"
        return 1
    fi
    
    # 检查是否存在
    if ! jq -e ".[] | select(.name == \"$name\")" "$PROVIDERS_FILE" > /dev/null 2>&1; then
        echo -e "${RED}错误: 代理商 '$name' 不存在${NC}"
        return 1
    fi
    
    # 更新代理商
    jq "map(if .name == \"$name\" then .token = \"$token\" | .base_url = \"$base_url\" else . end)" \
        "$PROVIDERS_FILE" > "${PROVIDERS_FILE}.tmp" && \
    mv "${PROVIDERS_FILE}.tmp" "$PROVIDERS_FILE"
    
    echo -e "${GREEN}代理商 '$name' 已更新${NC}"
    
    # 如果更新的是当前使用的代理商，重新应用设置
    if [ -f "$CURRENT_FILE" ] && [ "$(cat "$CURRENT_FILE")" = "$name" ]; then
        switch_provider "$name"
    fi
}

# 切换代理商
switch_provider() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo -e "${RED}错误: 请提供代理商名称${NC}"
        return 1
    fi
    
    # 获取代理商信息
    local provider_info=$(jq -r ".[] | select(.name == \"$name\")" "$PROVIDERS_FILE")
    
    if [ -z "$provider_info" ]; then
        echo -e "${RED}错误: 代理商 '$name' 不存在${NC}"
        return 1
    fi
    
    local token=$(echo "$provider_info" | jq -r '.token')
    local base_url=$(echo "$provider_info" | jq -r '.base_url')
    
    # 更新环境变量
    update_env_vars "$token" "$base_url"
    
    # 记录当前代理商
    echo "$name" > "$CURRENT_FILE"
    
    echo -e "${GREEN}已切换到代理商: $name${NC}"
    echo -e "${BLUE}BASE_URL: $base_url${NC}"
    echo -e "${YELLOW}请重新启动终端或运行 'source ~/.zshrc' 使配置生效${NC}"
}

# 显示当前代理商
show_current() {
    if [ ! -f "$CURRENT_FILE" ]; then
        echo -e "${YELLOW}当前未设置任何代理商${NC}"
        return
    fi
    
    local current_name=$(cat "$CURRENT_FILE")
    local provider_info=$(jq -r ".[] | select(.name == \"$current_name\")" "$PROVIDERS_FILE")
    
    if [ -z "$provider_info" ]; then
        echo -e "${RED}错误: 当前代理商配置已损坏${NC}"
        rm -f "$CURRENT_FILE"
        return 1
    fi
    
    local base_url=$(echo "$provider_info" | jq -r '.base_url')
    
    echo -e "${GREEN}当前代理商: $current_name${NC}"
    echo -e "${BLUE}BASE_URL: $base_url${NC}"
}

# 更新环境变量到配置文件
update_env_vars() {
    local token="$1"
    local base_url="$2"
    
    for config_file in "${SHELL_CONFIGS[@]}"; do
        # 创建文件如果不存在
        if [ ! -f "$config_file" ]; then
            touch "$config_file"
        fi
        
        # 移除旧的配置
        sed -i.bak '/^export ANTHROPIC_AUTH_TOKEN=/d' "$config_file" 2>/dev/null || true
        sed -i.bak '/^export ANTHROPIC_BASE_URL=/d' "$config_file" 2>/dev/null || true
        
        # 添加新的配置
        echo "export ANTHROPIC_AUTH_TOKEN=\"$token\"" >> "$config_file"
        echo "export ANTHROPIC_BASE_URL=\"$base_url\"" >> "$config_file"
        
        # 删除备份文件
        rm -f "${config_file}.bak"
    done
}

# 清除环境变量
clear_env_vars() {
    for config_file in "${SHELL_CONFIGS[@]}"; do
        if [ -f "$config_file" ]; then
            sed -i.bak '/^export ANTHROPIC_AUTH_TOKEN=/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^export ANTHROPIC_BASE_URL=/d' "$config_file" 2>/dev/null || true
            rm -f "${config_file}.bak"
        fi
    done
}

# 主函数
main() {
    init_config
    check_jq
    
    case "$1" in
        "add")
            add_provider "$2" "$3" "$4"
            ;;
        "remove")
            remove_provider "$2"
            ;;
        "list")
            list_providers
            ;;
        "switch")
            switch_provider "$2"
            ;;
        "current")
            show_current
            ;;
        "update")
            update_provider "$2" "$3" "$4"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}错误: 未知命令 '$1'${NC}"
            echo "使用 'claude-proxy help' 查看帮助信息"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"