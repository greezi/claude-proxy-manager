#!/bin/bash

# Claude Proxy Manager 测试脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT="./claude-proxy-manager.sh"
TEST_COUNT=0
PASS_COUNT=0

# 测试函数
test_function() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -e "${BLUE}测试 $TEST_COUNT: $test_name${NC}"
    
    if eval "$command" > /dev/null 2>&1; then
        actual_exit_code=0
    else
        actual_exit_code=1
    fi
    
    if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
        echo -e "${GREEN}✓ 通过${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}✗ 失败 (期望退出码: $expected_exit_code, 实际: $actual_exit_code)${NC}"
    fi
    echo ""
}

# 清理函数
cleanup() {
    echo -e "${YELLOW}清理测试环境...${NC}"
    rm -rf ~/.claude-proxy-manager
    
    # 清理测试添加的环境变量
    for config_file in ~/.bash_profile ~/.bashrc ~/.zshrc; do
        if [ -f "$config_file" ]; then
            sed -i.bak '/^export ANTHROPIC_AUTH_TOKEN=/d' "$config_file" 2>/dev/null || true
            sed -i.bak '/^export ANTHROPIC_BASE_URL=/d' "$config_file" 2>/dev/null || true
            rm -f "${config_file}.bak"
        fi
    done
}

# 开始测试
echo -e "${BLUE}Claude Proxy Manager 功能测试${NC}"
echo "=================================="
echo ""

# 清理之前的测试数据
cleanup

# 测试帮助命令
test_function "显示帮助信息" "$SCRIPT help"

# 测试添加代理商
test_function "添加第一个代理商" "$SCRIPT add proxy1 sk-ant-token1 https://proxy1.com"
test_function "添加第二个代理商" "$SCRIPT add proxy2 sk-ant-token2 https://proxy2.com"

# 测试重复添加（应该失败）
test_function "重复添加代理商（应该失败）" "$SCRIPT add proxy1 sk-ant-token1 https://proxy1.com" 1

# 测试列出代理商
test_function "列出所有代理商" "$SCRIPT list"

# 测试切换代理商
test_function "切换到 proxy1" "$SCRIPT switch proxy1"
test_function "查看当前代理商" "$SCRIPT current"

# 测试切换到不存在的代理商（应该失败）
test_function "切换到不存在的代理商（应该失败）" "$SCRIPT switch nonexistent" 1

# 测试更新代理商
test_function "更新代理商信息" "$SCRIPT update proxy1 sk-ant-new-token https://new-proxy1.com"

# 测试更新不存在的代理商（应该失败）
test_function "更新不存在的代理商（应该失败）" "$SCRIPT update nonexistent token url" 1

# 测试删除代理商
test_function "删除 proxy2" "$SCRIPT remove proxy2"

# 测试删除不存在的代理商（应该失败）
test_function "删除不存在的代理商（应该失败）" "$SCRIPT remove nonexistent" 1

# 测试参数不足的情况
test_function "添加代理商参数不足（应该失败）" "$SCRIPT add proxy3" 1
test_function "更新代理商参数不足（应该失败）" "$SCRIPT update proxy1" 1

# 测试无效命令
test_function "无效命令（应该失败）" "$SCRIPT invalid-command" 1

# 显示测试结果
echo "=================================="
echo -e "${BLUE}测试完成${NC}"
echo -e "总测试数: $TEST_COUNT"
echo -e "${GREEN}通过: $PASS_COUNT${NC}"
echo -e "${RED}失败: $((TEST_COUNT - PASS_COUNT))${NC}"

if [ "$PASS_COUNT" -eq "$TEST_COUNT" ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
    exit_code=0
else
    echo -e "${RED}❌ 部分测试失败${NC}"
    exit_code=1
fi

# 清理测试环境
cleanup

exit $exit_code