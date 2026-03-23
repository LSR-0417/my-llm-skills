#!/bin/bash

# 測試腳本：驗證 setup-skills.sh 的核心防呆與互動邏輯

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup-skills.sh"

# ANSI 色碼
GREEN='\03ff[0;32m'
RED='\033[0;31m'
NC='\033[0m'

run_test() {
    local test_name="$1"
    echo "======================================"
    echo "🧪 開始測試: $test_name"
    echo "======================================"
}

assert() {
    local condition="$1"
    local message="$2"
    if eval "[ $condition ]"; then
        echo -e "${GREEN}✅ 驗證成功: $message${NC}"
    else
        echo -e "${RED}❌ 驗證失敗: $message${NC}"
        exit 1
    fi
}

# 準備測試環境
TEST_ENV=$(mktemp -d)
echo "📂 建立隔離的測試資料夾: $TEST_ENV"

# ---------------------------------------------------------
# Test Case 1: 全新乾淨目錄派發 (預設全選 1,2,3,4)
# ---------------------------------------------------------
run_test "全新環境的預設選單派發"

# 模擬使用者輸入: 按下 Enter (預設選項 1,2,3,4)
"$SETUP_SCRIPT" "$TEST_ENV" --set "1,2,3,4" > /dev/null

assert "-L $TEST_ENV/.claude/skills" ".claude/skills 應建立軟連結"
assert "-L $TEST_ENV/.opencode/skills" ".opencode/skills 應建立軟連結"
assert "-L $TEST_ENV/.agents/skills" ".agents/skills 應建立軟連結"
assert "-f $TEST_ENV/.github/copilot-instructions.md" "VS Code 指令檔應正確編譯生成"


# ---------------------------------------------------------
# Test Case 2: 模擬遇到實體資料夾，驗證是否確實被「強制覆蓋」
# ---------------------------------------------------------
run_test "遇到實體資料夾時的強制覆蓋機制"

# 手動建立一個實體資料夾模擬舊檔案
rm -f "$TEST_ENV/.claude/skills"
mkdir -p "$TEST_ENV/.claude/skills"
touch "$TEST_ENV/.claude/skills/dummy.txt"

# 模擬使用者單純選 1
"$SETUP_SCRIPT" "$TEST_ENV" --set "1" > /dev/null

assert "-L $TEST_ENV/.claude/skills" "執行後，.claude/skills 應被強制清除並重建為軟連結"


# ---------------------------------------------------------
# Test Case 4: 全域模式選項防呆 (-g) 與 VSCode 警告
# ---------------------------------------------------------
run_test "全域標籤 (-g) 下的派發行為"

# 使用一個假的 HOME 目錄來保護使用者的真 HOME
OLD_HOME=$HOME
export HOME="$TEST_ENV/fake_home"
mkdir -p "$HOME"

# 模擬使用者輸入: 選擇選項 4 (VS Code) 測試是否會阻擋
# -g 模式下對選項 4 應只印出警告，不該建立檔案
# 選項 1 建立 claude
"$SETUP_SCRIPT" --set "1,4" -g > /dev/null

assert "-L $HOME/.claude/skills" "全域模式下 .claude/skills 應正確建立軟連結 (在 HOME 下)"
assert "! -f $HOME/.github/copilot-instructions.md" "全域模式應阻擋 VS Code 指令檔的生成"

export HOME=$OLD_HOME


# 清理環境
rm -rf "$TEST_ENV"
echo -e "\n🎉 所有自動化測試通過！"
