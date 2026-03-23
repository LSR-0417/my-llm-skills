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
echo "" | "$SETUP_SCRIPT" "$TEST_ENV" > /dev/null

assert "-L $TEST_ENV/.claude/skills" ".claude/skills 應建立軟連結"
assert "-L $TEST_ENV/.opencode/skills" ".opencode/skills 應建立軟連結"
assert "-L $TEST_ENV/.agents/skills" ".agents/skills 應建立軟連結"
assert "-f $TEST_ENV/.github/copilot-instructions.md" "VS Code 指令檔應正確編譯生成"


# ---------------------------------------------------------
# Test Case 2: 模擬遇到實體資料夾且選擇「備份並替換 (Y)」
# ---------------------------------------------------------
run_test "覆蓋實體資料夾防呆測試 (同意備份)"

# 手動移除軟連結，換成實體資料夾並塞入假檔案
rm "$TEST_ENV/.claude/skills"
mkdir "$TEST_ENV/.claude/skills"
touch "$TEST_ENV/.claude/skills/dummy.txt"

# 模擬使用者輸入:
# 1) 選單輸入: 1 (只測 Claude)
# 2) 警告提問: y (同意備份更改)
echo -e "1\ny" | "$SETUP_SCRIPT" "$TEST_ENV" > /dev/null

assert "-L $TEST_ENV/.claude/skills" "執行替換後，.claude/skills 應成為軟連結"
BACKUP_DIR=$(ls -d "$TEST_ENV"/.claude/skills_backup_* 2>/dev/null | head -n 1)
assert "-n \"$BACKUP_DIR\"" "應正確生成帶有時間戳記的備份資料夾"
assert "-f \"$BACKUP_DIR/dummy.txt\"" "原資料夾的內容物應在備份資料夾中存活"


# ---------------------------------------------------------
# Test Case 3: 模擬遇到實體資料夾且點選「不替換 (N)」
# ---------------------------------------------------------
run_test "覆蓋實體資料夾防呆測試 (拒絕備份)"

# 再手動把它搞壞，變成另一個實體資料夾
rm "$TEST_ENV/.claude/skills"
mkdir "$TEST_ENV/.claude/skills"

# 模擬使用者輸入:
# 1) 選單輸入: 1
# 2) 警告提問: n (拒絕更改)
echo -e "1\nn" | "$SETUP_SCRIPT" "$TEST_ENV" > /dev/null

assert "-d $TEST_ENV/.claude/skills" ".claude/skills 應維持實體資料夾"
assert "! -L $TEST_ENV/.claude/skills" ".claude/skills 不應被轉成軟連結"


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
echo -e "1,4\n" | "$SETUP_SCRIPT" -g > /dev/null

assert "-L $HOME/.claude/skills" "全域模式下 .claude/skills 應正確建立軟連結 (在 HOME 下)"
assert "! -f $HOME/.github/copilot-instructions.md" "全域模式應阻擋 VS Code 指令檔的生成"

export HOME=$OLD_HOME


# 清理環境
rm -rf "$TEST_ENV"
echo -e "\n🎉 所有自動化測試通過！"
