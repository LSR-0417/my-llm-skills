# 🤖 My LLM Skills

這個 Repository 是用來集中管理與維護各家 AI Agent / LLM 編輯器的通用「技能（Skills）」或自訂指令。

透過統一的目錄結構與派發腳本，您可以寫一次 Markdown 規範，就讓各大主流的 AI 開發工具（如 VS Code Copilot, Claude Code, Antigravity, Open-Code 等）都能順暢讀取！

## 📁 支援的 AI 工具 & 相容對應表

| 工具名稱 | 標準路徑 (專案層級/全域) | 說明與相容性 |
| :--- | :--- | :--- |
| **Anthropic (Claude Code)** | `.claude/skills/` | 原生支援 Agent Skills 標準目錄。 |
| **Open-Code** | `.opencode/skills/` | 原生支援。 |
| **Codex** | `.agents/skills/` | 原生支援。 |
| **Antigravity** | `.agents/skills/` | 完整擁抱 `.agents/` 開源代理標準目錄。 |
| **VS Code (GitHub Copilot)** | `.github/copilot-instructions.md` | 原生 Copilot 偏好單一檔案，腳本會自動將多個技能整合成此 Markdown 檔案。 |

## 🚀 如何使用

### 1. 撰寫您的技能 (SKILL)

在 `skills/` 目錄下建立您的各種技能資料夾，每個資料夾內放置一個含有 YAML Frontmatter 的 `SKILL.md`。

範例結構：
```text
my-llm-skills/
├── skills/
│   ├── vue-video-player/
│   │   └── SKILL.md
│   ├── api-tester/
│   │   └── SKILL.md
│   └── code-review/
│       └── SKILL.md
└── setup-skills.sh
```

### 2. 派發技能到專案 or 全域環境

我們提供了一個 `setup-skills.sh` 腳本，可以幫您自動建立軟連結（Symlink）或合併檔案。

#### 📌 選項 A：派發到單一專案 (Project Level)

當您要為特定專案引入 AI 技能時，執行腳本並指定目標專案路徑（預設為當前目錄 `.`）：

```bash
# 基本用法 (派發到當前目錄)
./setup-skills.sh

# 派發到指定目錄 (例如您的開發專案)
./setup-skills.sh /path/to/your/project
```

執行後，腳本會：
1. 為 Antigravity、Codex、Anthropic、Open-Code 在目標專案建立對應的隱藏資料夾與 `skills` 軟連結。
2. 自動拔除所有 `SKILL.md` 的 YAML 檔頭，並合併生成單一的 `.github/copilot-instructions.md` 供 VS Code 讀取。

#### 🌍 選項 B：派發到全域環境 (Global Level)

如果您希望在任何地方開啟終端機或 IDE 時，AI 工具都能預設讀取這些技能，請使用 `-g` 或 `--global` 標籤：

```bash
./setup-skills.sh --global
```

執行後，腳本會：
- 自動在 `~/.claude/`, `~/.opencode/`, `~/.agents/` 建立對應的 `skills` 軟連結。
- *(注意：VS Code 尚未支援全域的 GitHub Copilot 指令檔，若您使用 VS Code，仍需在個別專案中執行專案層級的派發。)*

## 💡 維護建議

- 只要在 Repo 中修改您的技能，所有使用軟連結（Symlink）的工具（Claude, Open-Code, Antigravity 等）都會**即時生效**。
- 若有修改或新增技能，要讓 VS Code Copilot 吃到最新設定，請務必在專案目錄**重新執行一次專案派發**，以重新編譯生成最新的 `.github/copilot-instructions.md`。
