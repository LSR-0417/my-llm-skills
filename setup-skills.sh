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
    echo "🌍 開始派發 Agent Skills 到全域環境 (Global)..."
    
    # 處理支援 Agent Skills 標準的工具 (建立軟連結)
    for dir in "$HOME/.claude" "$HOME/.opencode" "$HOME/.agents"; do
        mkdir -p "$dir"
        ln -sfn "$SKILLS_SRC_DIR" "$dir/skills"
    done
    
    echo "✅ 已完成 Anthropic, Open-Code, Codex, Antigravity 的全域軟連結佈署"
    echo "⚠️  注意: GitHub Copilot 目前不支援全域指令檔，VS Code 仍需在各專案執行專案層級派發。"

else
    # 轉換為絕對路徑，方便提示
    TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")
    echo "🚀 開始派發 Agent Skills 到目標專案: $TARGET_DIR"

    # 1. 處理支援 Agent Skills 標準的工具 (建立軟連結)
    for dir in "$TARGET_DIR/.claude" "$TARGET_DIR/.opencode" "$TARGET_DIR/.agents"; do
        mkdir -p "$dir"
        ln -sfn "$SKILLS_SRC_DIR" "$dir/skills"
    done

    echo "✅ 已完成 Anthropic, Open-Code, Codex, Antigravity 的軟連結佈署"

    # 2. 處理 VS Code (自動合併成單一檔案)
    VSCODE_DIR="$TARGET_DIR/.github"
    VSCODE_FILE="$VSCODE_DIR/copilot-instructions.md"

    mkdir -p "$VSCODE_DIR"
    echo "<!-- 自動生成的 VS Code Copilot 指令檔，請勿直接修改 -->" > "$VSCODE_FILE"

    for skill_md in "$SKILLS_SRC_DIR"/*/SKILL.md; do
      if [ -f "$skill_md" ]; then
        skill_name=$(basename "$(dirname "$skill_md")")
        echo -e "\n\n# Skill: $skill_name\n" >> "$VSCODE_FILE"
        
        # 判斷是否有 YAML Frontmatter
        if head -n 1 "$skill_md" | grep -q "^---$"; then
            # 使用 awk 拔除 YAML Frontmatter (兩個 --- 之間區塊)，只保留純 Markdown 內文
            awk '/^---$/ { if(c++ > 0) p=1; next } p' "$skill_md" >> "$VSCODE_FILE"
        else
            # 沒有 Frontmatter，直接複製內容
            cat "$skill_md" >> "$VSCODE_FILE"
        fi
      fi
    done

    echo "✅ 已為 VS Code 編譯並生成單一 copilot-instructions.md 檔案"
fi

echo "🎉 技能派發完成！"
