#!/bin/bash

# 取得技能庫的絕對路徑
SKILLS_SRC_DIR="$(cd "$(dirname "$0")" && pwd)/skills"

# 預設值
TARGET_DIR="."
IS_GLOBAL=0
AUTO_OPTIONS=""

# 解析參數
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -g|--global) IS_GLOBAL=1; shift ;;
        --set) AUTO_OPTIONS="$2"; shift 2 ;;
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

selected_options=()

if [ -n "$AUTO_OPTIONS" ]; then
    # 若有帶入參數，過濾數字後轉為陣列
    val=$(echo "$AUTO_OPTIONS" | grep -o '[1-4]')
    eval "selected_options=($(echo "$val" | sort -u | tr '\n' ' '))"
else
    # 終端機 TUI 互動模式
    options=("Anthropic (Claude Code)" "Open-Code (Open-Code)" "Codex / Antigravity" "VS Code (GitHub Copilot)")
    target_dirs=(".claude/" ".opencode/" ".agents/" "copilot-instructions.md")
    selected=(0 0 0 0)
    current_idx=0

    # 隱藏游標並設定跳出時恢復
    tput civis
    trap 'tput cnorm; stty echo; exit 1' INT TERM EXIT
    stty -echo

    draw_menu() {
        if [ "$1" -eq 1 ]; then tput cuu 6; fi
        echo -e "請使用 [\033[1m↑/↓\033[0m] 切換，[\033[1m空白鍵\033[0m] 勾選/取消，[\033[1mEnter\033[0m] 確認：\033[K"
        echo -e "---------------------------------------------------------\033[K"
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$current_idx" ]; then printf "\033[7m"; fi
            local checkbox=" "
            if [ "${selected[$i]}" -eq 1 ]; then checkbox="x"; fi
            printf "[%s] %-25s -> %s \033[0m\033[K\n" "$checkbox" "${options[$i]}" "${target_dirs[$i]}"
        done
    }

    echo ""
    draw_menu 0

    while true; do
        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key2
            if [[ $key2 == '[A' ]]; then # Up
                ((current_idx--))
                if [ $current_idx -lt 0 ]; then current_idx=3; fi
            elif [[ $key2 == '[B' ]]; then # Down
                ((current_idx++))
                if [ $current_idx -gt 3 ]; then current_idx=0; fi
            fi
        elif [[ $key == " " ]]; then # Space toggle
            if [ "${selected[$current_idx]}" -eq 1 ]; then
                selected[$current_idx]=0
            else
                selected[$current_idx]=1
            fi
        elif [[ -z $key ]]; then # Enter key
            break
        fi
        draw_menu 1
    done

    # 恢復游標與終端機設定
    tput cnorm
    stty echo
    trap - INT TERM EXIT
    
    # 收集勾選結果
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            selected_options+=($((i+1)))
        fi
    done
fi

if [ ${#selected_options[@]} -eq 0 ]; then
    echo -e "\n⚠️  未選取任何項目，取消操作並退出。"
    exit 0
fi

# 安全建立軟連結的函數
check_and_link() {
    local target_dir="$1"
    local link_target="$target_dir/skills"
    local tool_name="$2"

    mkdir -p "$target_dir"

    # 如果已存在實體資料夾 (非軟連結)，目前策略為強制覆蓋
    if [ -d "$link_target" ] && [ ! -L "$link_target" ]; then
        echo -e "\n⚠️  警告: 發現 ${tool_name} 的舊有同名技能資料夾 ($link_target)。"
        echo "🗑️  正在強制覆蓋並刪除舊有資料夾..."
        rm -rf "$link_target"
        echo "✅ 已成功強制覆蓋同名 skill 目錄"
    fi

    # 建立或覆蓋軟連結
    ln -sfn "$SKILLS_SRC_DIR" "$link_target"
    echo "✅ 已成功派發 $tool_name 的共用軟連結 ($link_target)"
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
