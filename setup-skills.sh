#!/bin/bash

# 取得技能庫的絕對路徑
SKILLS_SRC_DIR="$(cd "$(dirname "$0")" && pwd)/skills"

# 預設值
TARGET_DIR="."
IS_GLOBAL=0

# 解析參數
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -g|--global) IS_GLOBAL=1; shift ;;
        *) TARGET_DIR="$1"; shift ;;
    esac
done

if [ ! -d "$SKILLS_SRC_DIR" ]; then
    echo "❌ 找不到 skills/ 目錄，請確認您在正確的路徑執行腳本。"
    exit 1
fi

if [ "$IS_GLOBAL" -eq 1 ]; then
    TARGET_DIR="$HOME"
    echo "🌍 開始派發 Agent Skills 到全域環境 (Global)..."
else
    # 轉換為絕對路徑，方便提示
    TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")
    echo "🚀 開始派發 Agent Skills 到目標專案: $TARGET_DIR"
fi

echo ""
echo "========================================="
echo "請選擇您要派發哪些 AI 工具的設定（可多選，用逗號分隔，例如 1,3,4）"
echo "直接按 Enter 代表全選 (1,2,3,4)"
echo "-----------------------------------------"
echo "1) Anthropic (Claude Code) -> .claude/"
echo "2) Open-Code (Open-Code)   -> .opencode/"
echo "3) Codex / Antigravity     -> .agents/"
echo "4) VS Code (GitHub Copilot)-> copilot-instructions.md"
echo "========================================="
read -p "請輸入需要綁定的項目編號 [預設: 1,2,3,4]: " user_input

# 處理預設值
if [ -z "$user_input" ]; then
    user_input="1234"
fi

# 擷取所有 1~4 的數字並轉成陣列 (支援逗號、空白、無分隔符號等任意格式)
user_input=$(echo "$user_input" | grep -o '[1-4]')

# 去除陣列中重複的選項 (如果輸入 112 -> 1 2)
eval "selected_options=($(echo "$user_input" | sort -u | tr '\n' ' '))"

# 安全建立軟連結的函數
check_and_link() {
    local target_dir="$1"
    local link_target="$target_dir/skills"
    local tool_name="$2"

    mkdir -p "$target_dir"

    # 1. 檢查是否存在且為實體資料夾 (非軟連結)
    if [ -d "$link_target" ] && [ ! -L "$link_target" ]; then
        echo -e "\n⚠️  警告: 發現 ${tool_name} 的技能庫已是一個實體資料夾 ($link_target)。"
        # 由於可能有 CI 或無法互動的環境，建議加上判斷，但既然是要「互動式」，這裡強制問
        read -p "是否要自動更名備份並替換為統一的共用軟連結？[y/N]: " backup_ans
        case $backup_ans in
            [Yy]* )
                local timestamp=$(date +"%Y%m%d_%H%M%S")
                local backup_name="${link_target}_backup_${timestamp}"
                mv "$link_target" "$backup_name"
                echo "✅ 已備份至: $backup_name"
                ln -sfn "$SKILLS_SRC_DIR" "$link_target"
                echo "✅ 已成功建立 $tool_name 的共用軟連結 ($link_target)"
                ;;
            * )
                echo "⏭️  跳過 $tool_name 的派發，保留原樣 ($link_target)。"
                ;;
        esac
    else
        # 2. 如果不存在，或是已經是軟連結 (不論是否正確)，直接強制覆蓋重建
        ln -sfn "$SKILLS_SRC_DIR" "$link_target"
        echo "✅ 已成功派發 $tool_name 的共用軟連結 ($link_target)"
    fi
}

echo ""

# 根據選項執行
for opt in "${selected_options[@]}"; do
    # 移除前後空白
    opt=$(echo "$opt" | xargs)
    
    case $opt in
        1)
            check_and_link "$TARGET_DIR/.claude" "Anthropic"
            ;;
        2)
            check_and_link "$TARGET_DIR/.opencode" "Open-Code"
            ;;
        3)
            check_and_link "$TARGET_DIR/.agents" "Codex / Antigravity"
            ;;
        4)
            if [ "$IS_GLOBAL" -eq 1 ]; then
                echo -e "⚠️  注意: VS Code (GitHub Copilot) 目前不支援全域指令檔，請在各專案內執行單一專案層級派發。"
            else
                echo -e "⚙️  開始編譯 VS Code (GitHub Copilot) 單一指令檔..."
                VSCODE_DIR="$TARGET_DIR/.github"
                VSCODE_FILE="$VSCODE_DIR/copilot-instructions.md"

                mkdir -p "$VSCODE_DIR"
                echo "<!-- 自動生成的 VS Code Copilot 指令檔，請勿直接修改 -->" > "$VSCODE_FILE"

                for skill_md in "$SKILLS_SRC_DIR"/*/SKILL.md; do
                    if [ -f "$skill_md" ]; then
                        skill_name=$(basename "$(dirname "$skill_md")")
                        echo -e "\n\n# Skill: $skill_name\n" >> "$VSCODE_FILE"
                        
                        # 判斷是否有 YAML Frontmatter 並拔除
                        if head -n 1 "$skill_md" | grep -q "^---$"; then
                            awk '/^---$/ { if(c++ > 0) p=1; next } p' "$skill_md" >> "$VSCODE_FILE"
                        else
                            cat "$skill_md" >> "$VSCODE_FILE"
                        fi
                    fi
                done
                echo "✅ 已成功生成專為 VS Code 設計的單一檔案 ($VSCODE_FILE)"
            fi
            ;;
        *)
            echo "❌ 未知的選項: $opt，此項目略過。"
            ;;
    esac
done

echo -e "\n🎉 技能派發作業執行結束！"
