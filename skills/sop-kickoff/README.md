# sop-kickoff

這份 README 說明新主題開始時的高層級流程。它只保留開案階段必須知道的目的、應作流程與禁止項目；細節交給 `SKILL.md` 與實際執行時處理。這個 skill 負責把 kickoff 落成流程，但 kickoff 的視角與責任邊界應由目前載入的 role 來決定。

## 1. 目的

- 把 role 在 kickoff 階段的觀察與責任，落成可執行的開案流程。
- 為後續 worktree、branch、commit 與 PR 建立清楚起點。

## 2. 應作流程

依據目前載入的 Role 視角，必須各司其職完成以下準備工作：

### 產品經理 PM (`role-pm`)
- **釐清需求**：負責釐清客戶模糊的初期需求，並將其轉換成清晰的 User Story。
- **可行性評估**：確保 User Story 具備開發的合理性與可行性。
- **發布 Issue**：將 kickoff 討論的結果發送到 Git Server 上建立 User Story 格式的 Issue。若無法推送（例如無權限或是沒有 Git CLI 工具），必須主動提醒使用者，並在對話視窗中完整印出下方的標題與內文格式供手動複製。

### 設計測試工程師 TE (`role-te`)
- **撰寫測試基準**：必須根據 PM 的 User Story 撰寫清楚的 `Spec. Test`、`Scenario Test` 與 `Edge Test` 作為開發依據。
- **同步變更**：把 User Story 與 Tests 視為活文件；開發途中若 User Story 有任何修訂，TE 必須同步更新與修訂對應的 Test，讓 RD 開發隨時有可靠依據。

### 開發工程師 RD (`role-developer`)
- **功能開發**：針對 User Story 以及 TE 所撰寫的測試，進行程式實作。
- **持續對齊**：若開發過程中發現需求無法實作、範圍過大或不明確，應主動反映並請 PM 更新 User Story，並參考最新的 Test 調整開發方向。
- **交接環境**：只有在 `User Story`、範圍與開發前提都沒有明顯問題後，才交給 `sop-workspace` 準備 worktree 與 branch 展開實作。

### 建立 Issue 的規範與格式 (由 PM 發起)
- **建議標題格式**：`<簡潔的需求摘要>`
  - **建議內文格式**：
    ```markdown
    ## 使用者故事 (User Story)
    身為 <目標使用者角色>，
    我想要 <執行什麼動作/功能>，
    這樣我就可以 <達到什麼效益或目的>。
    
    ## 驗收標準 (Acceptance Criteria)
    - [ ] 條件一
    - [ ] 條件二
    
    ## 補充說明 (Notes)
    (選填：開發技術前提、UX 限制或相關資料)
    ```
  - **必須打上的標籤 (Label / Tag)**：`type: user-story`
  - 若無法推送（例如無權限或是沒有 Git CLI 工具），必須主動提醒使用者，並在對話視窗中完整印出上述的標題與內文格式，供使用者手動複製貼上。

## 3. 禁止項目

- 在 kickoff 討論或需求收斂期間，絕對禁止寫入、修改或提交任何檔案到主要保護分支（如 `main`, `master`, `develop`）。
- 不要在主題還模糊時直接開始寫 code。
- 不要把多個不相干的需求硬塞成同一個開發主題。
- 不要跳過 Issue，讓後續開發失去追蹤依據。
- 不要把早期版本的 `User Story` 或 `Spec. Test` 當成固定不變，忽略後續增修。
- 不要只有 `Issue` 沒有對應的 `User Story` 或設計細節，也不要只有設計細節卻沒有可追蹤的需求來源。
- 不要在 `SRS` 尚未確認可行前，就直接展開設計細節或實作。
