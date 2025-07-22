#!/bin/bash

# Claude Code 代理商管理器
# 版本: 1.0.0
# 作者: Claude Proxy Manager

# 配置文件路径
CONFIG_DIR="$HOME/.claude-proxy-manager"
PROVIDERS_FILE="$CONFIG_DIR/providers.json"
CURRENT_FILE="$CONFIG_DIR/current"

# Shell 配置文件 - 根据操作系统和当前shell动态确定
get_shell_configs() {
    local configs=()
    
    # 根据当前shell添加相应的配置文件
    case "$SHELL" in
        */bash)
            configs+=("$HOME/.bashrc")
            # macOS 默认读取 .bash_profile
            [[ "$OSTYPE" == "darwin"* ]] && configs+=("$HOME/.bash_profile")
            ;;
        */zsh)
            configs+=("$HOME/.zshrc")
            ;;
        */fish)
            configs+=("$HOME/.config/fish/config.fish")
            ;;
        *)
            # 默认配置文件
            configs+=("$HOME/.profile")
            [[ -f "$HOME/.bashrc" ]] && configs+=("$HOME/.bashrc")
            [[ -f "$HOME/.zshrc" ]] && configs+=("$HOME/.zshrc")
            ;;
    esac
    
    # 确保至少有一个配置文件
    if [[ ${#configs[@]} -eq 0 ]]; then
        configs+=("$HOME/.profile")
    fi
    
    printf '%s\n' "${configs[@]}"
}

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
    echo "  add <name> <token> <base_url> [key_type]  添加新的代理商"
    echo "                                            key_type: AUTH_TOKEN(默认) 或 API_KEY"
    echo "  remove <name>                             删除代理商"
    echo "  list                                      列出所有代理商"
    echo "  switch <name>                             切换到指定代理商"
    echo "  current                                   显示当前使用的代理商"
    echo "  update <name> <token> <url> [key_type]    更新代理商信息"
    echo "  help                                      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  claude-proxy add official sk-ant-xxx https://api.anthropic.com API_KEY"
    echo "  claude-proxy add proxy1 sk-ant-yyy https://proxy1.example.com AUTH_TOKEN"
    echo "  claude-proxy switch proxy1"
    echo "  claude-proxy list"
}

# 检查 jq 是否安装
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}错误: 需要安装 jq 来处理 JSON 数据${NC}"
        
        # 根据操作系统提供相应的安装提示
        case "$OSTYPE" in
            darwin*)
                echo "请运行: brew install jq"
                ;;
            linux*)
                echo "请根据您的发行版运行以下命令之一:"
                echo "  Ubuntu/Debian: sudo apt-get install jq"
                echo "  CentOS/RHEL 7: sudo yum install epel-release && sudo yum install jq"
                echo "  CentOS/RHEL 8+/Fedora: sudo dnf install jq"
                echo "  Arch Linux: sudo pacman -S jq"
                echo "  openSUSE: sudo zypper install jq"
                ;;
            *)
                echo "请访问 https://jqlang.github.io/jq/download/ 下载安装"
                ;;
        esac
        exit 1
    fi
}

# 添加代理商
add_provider() {
    local name="$1"
    local token="$2"
    local base_url="$3"
    local key_type="${4:-AUTH_TOKEN}"  # 默认为 AUTH_TOKEN
    
    if [ -z "$name" ] || [ -z "$token" ] || [ -z "$base_url" ]; then
        echo -e "${RED}错误: 请提供完整的参数 (名称 令牌 基础URL)${NC}"
        return 1
    fi
    
    # 验证 key_type
    if [ "$key_type" != "AUTH_TOKEN" ] && [ "$key_type" != "API_KEY" ]; then
        echo -e "${RED}错误: key_type 必须是 AUTH_TOKEN 或 API_KEY${NC}"
        return 1
    fi
    
    # 检查是否已存在
    if jq -e ".[] | select(.name == \"$name\")" "$PROVIDERS_FILE" > /dev/null 2>&1; then
        echo -e "${YELLOW}警告: 代理商 '$name' 已存在，使用 update 命令来更新${NC}"
        return 1
    fi
    
    # 添加新代理商
    local new_provider=$(jq -n --arg name "$name" --arg token "$token" --arg url "$base_url" --arg key_type "$key_type" \
        '{name: $name, token: $token, base_url: $url, key_type: $key_type}')
    
    jq ". += [$new_provider]" "$PROVIDERS_FILE" > "${PROVIDERS_FILE}.tmp" && \
    mv "${PROVIDERS_FILE}.tmp" "$PROVIDERS_FILE"
    
    echo -e "${GREEN}代理商 '$name' 已添加 (密钥类型: $key_type)${NC}"
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
    
    jq -r '.[] | "\(.name)|\(.base_url)|\(.token[0:20])...|\(.key_type // "AUTH_TOKEN")"' "$PROVIDERS_FILE" | \
    while IFS='|' read -r name url token key_type; do
        if [ "$name" = "$current_provider" ]; then
            echo -e "${GREEN}* $name${NC} - $url - $token - [${key_type}]"
        else
            echo -e "  $name - $url - $token - [${key_type}]"
        fi
    done
}

# 更新代理商
update_provider() {
    local name="$1"
    local token="$2"
    local base_url="$3"
    local key_type="${4:-}"  # 可选参数
    
    if [ -z "$name" ] || [ -z "$token" ] || [ -z "$base_url" ]; then
        echo -e "${RED}错误: 请提供完整的参数 (名称 令牌 基础URL)${NC}"
        return 1
    fi
    
    # 验证 key_type（如果提供）
    if [ -n "$key_type" ] && [ "$key_type" != "AUTH_TOKEN" ] && [ "$key_type" != "API_KEY" ]; then
        echo -e "${RED}错误: key_type 必须是 AUTH_TOKEN 或 API_KEY${NC}"
        return 1
    fi
    
    # 检查是否存在
    if ! jq -e ".[] | select(.name == \"$name\")" "$PROVIDERS_FILE" > /dev/null 2>&1; then
        echo -e "${RED}错误: 代理商 '$name' 不存在${NC}"
        return 1
    fi
    
    # 更新代理商
    if [ -n "$key_type" ]; then
        # 如果提供了 key_type，同时更新它
        jq "map(if .name == \"$name\" then .token = \"$token\" | .base_url = \"$base_url\" | .key_type = \"$key_type\" else . end)" \
            "$PROVIDERS_FILE" > "${PROVIDERS_FILE}.tmp" && \
        mv "${PROVIDERS_FILE}.tmp" "$PROVIDERS_FILE"
    else
        # 否则只更新 token 和 base_url
        jq "map(if .name == \"$name\" then .token = \"$token\" | .base_url = \"$base_url\" else . end)" \
            "$PROVIDERS_FILE" > "${PROVIDERS_FILE}.tmp" && \
        mv "${PROVIDERS_FILE}.tmp" "$PROVIDERS_FILE"
    fi
    
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
    local key_type=$(echo "$provider_info" | jq -r '.key_type // "AUTH_TOKEN"')  # 默认为 AUTH_TOKEN
    
    # 更新环境变量
    update_env_vars "$token" "$base_url" "$key_type"
    
    # 记录当前代理商
    echo "$name" > "$CURRENT_FILE"
    
    echo -e "${GREEN}已切换到代理商: $name${NC}"
    echo -e "${BLUE}BASE_URL: $base_url${NC}"
    echo -e "${BLUE}密钥类型: $key_type${NC}"
    
    # 根据当前shell提供相应的重新加载提示
    case "$SHELL" in
        */bash)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo -e "${YELLOW}请重新启动终端或运行 'source ~/.bash_profile' 使配置生效${NC}"
            else
                echo -e "${YELLOW}请重新启动终端或运行 'source ~/.bashrc' 使配置生效${NC}"
            fi
            ;;
        */zsh)
            echo -e "${YELLOW}请重新启动终端或运行 'source ~/.zshrc' 使配置生效${NC}"
            ;;
        */fish)
            echo -e "${YELLOW}请重新启动终端或运行 'source ~/.config/fish/config.fish' 使配置生效${NC}"
            ;;
        *)
            echo -e "${YELLOW}请重新启动终端使配置生效${NC}"
            ;;
    esac
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
    local key_type="${3:-AUTH_TOKEN}"  # 默认为 AUTH_TOKEN
    
    # 获取shell配置文件列表
    local shell_configs
    readarray -t shell_configs < <(get_shell_configs)
    
    for config_file in "${shell_configs[@]}"; do
        # 创建目录结构如果不存在（用于fish等有层级的配置文件）
        local config_dir=$(dirname "$config_file")
        if [ ! -d "$config_dir" ]; then
            mkdir -p "$config_dir"
        fi
        
        # 创建文件如果不存在
        if [ ! -f "$config_file" ]; then
            touch "$config_file"
        fi
        
        # 处理 Fish shell 配置
        if [[ "$config_file" == *"fish"* ]]; then
            # Fish shell 使用不同的语法
            # 清除所有相关环境变量
            sed -i.bak '/^set -gx ANTHROPIC_AUTH_TOKEN/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^set -gx ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^set -gx ANTHROPIC_BASE_URL/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^set -e ANTHROPIC_AUTH_TOKEN/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^set -e ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null || true
            
            # 根据类型设置正确的环境变量
            if [ "$key_type" = "API_KEY" ]; then
                echo "set -gx ANTHROPIC_API_KEY \"$token\"" >> "$config_file"
                # 确保 AUTH_TOKEN 不存在
                echo "set -e ANTHROPIC_AUTH_TOKEN" >> "$config_file"
            else
                echo "set -gx ANTHROPIC_AUTH_TOKEN \"$token\"" >> "$config_file"
                # 确保 API_KEY 不存在
                echo "set -e ANTHROPIC_API_KEY" >> "$config_file"
            fi
            echo "set -gx ANTHROPIC_BASE_URL \"$base_url\"" >> "$config_file"
        else
            # Bash/Zsh 配置
            # 清除所有相关环境变量
            sed -i.bak '/^export ANTHROPIC_AUTH_TOKEN=/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^export ANTHROPIC_API_KEY=/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^export ANTHROPIC_BASE_URL=/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^unset ANTHROPIC_AUTH_TOKEN/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^unset ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null || true
            
            # 根据类型设置正确的环境变量
            if [ "$key_type" = "API_KEY" ]; then
                echo "export ANTHROPIC_API_KEY=\"$token\"" >> "$config_file"
                # 确保 AUTH_TOKEN 不存在
                echo "unset ANTHROPIC_AUTH_TOKEN" >> "$config_file"
            else
                echo "export ANTHROPIC_AUTH_TOKEN=\"$token\"" >> "$config_file"
                # 确保 API_KEY 不存在
                echo "unset ANTHROPIC_API_KEY" >> "$config_file"
            fi
            echo "export ANTHROPIC_BASE_URL=\"$base_url\"" >> "$config_file"
        fi
        
        # 删除备份文件
        rm -f "${config_file}.bak"
    done
}

# 清除环境变量
clear_env_vars() {
    # 获取shell配置文件列表
    local shell_configs
    readarray -t shell_configs < <(get_shell_configs)
    
    for config_file in "${shell_configs[@]}"; do
        if [ -f "$config_file" ]; then
            # 处理 Fish shell 配置
            if [[ "$config_file" == *"fish"* ]]; then
                sed -i.bak '/^set -gx ANTHROPIC_AUTH_TOKEN/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^set -gx ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^set -gx ANTHROPIC_BASE_URL/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^set -e ANTHROPIC_AUTH_TOKEN/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^set -e ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null || true
            else
                # Bash/Zsh 配置
                sed -i.bak '/^export ANTHROPIC_AUTH_TOKEN=/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^export ANTHROPIC_API_KEY=/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^export ANTHROPIC_BASE_URL=/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^unset ANTHROPIC_AUTH_TOKEN/d' "$config_file" 2>/dev/null || true
                sed -i.bak '/^unset ANTHROPIC_API_KEY/d' "$config_file" 2>/dev/null || true
            fi
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
            add_provider "$2" "$3" "$4" "$5"
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
            update_provider "$2" "$3" "$4" "$5"
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