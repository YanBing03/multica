# TERMS.md v1 ↔ conventions.zh.mdx 冲突清单（D-009 收口）

> Day 1 · 11:30 · W0 主窗产出
> 用途：交付给 W4，作为 TERMS.md v2 改写的输入
> 权威：`apps/docs/content/docs/developers/conventions.zh.mdx`（上游 302 行）
> 旧版：`docs/i18n/TERMS.md` v1（226 行，vivo 早期自建）

## 0. 总策略

TERMS.md 不再做"独立术语表"，**降级为 conventions.zh.mdx 的 vivo 业务补丁**。
重叠词条以 conv 为准，TERMS v2 只补 conv 未覆盖的部分。

---

## 1. 类 A — 完全一致（前 5 例，不穷举）

| 英文 | 双方共同译法 |
|---|---|
| Agent | 智能体（conv L127 / TERMS L24） |
| Workspace | 工作区（conv L126 / TERMS L29） |
| Daemon | 守护进程（conv L131 / TERMS L31） |
| Comment | 评论（conv L133 / TERMS L35） |
| Member | 成员（conv L136 / TERMS L93） |

> 另有 Sign in / Sign up / Account / Save / Cancel / Delete / Edit / Add / Search / Invite / Profile / Settings / Notification / Status / Description / Title / Priority / Upload / Download / Failed / Archived 等约 20 余项一致，v2 直接引用 conv 即可。

---

## 2. 类 B — 冲突（必须按 conv 修订）

### B-1 核心实体：保留英文 vs 强译中文（最致命）

| 英文 | conventions（权威） | TERMS v1（vivo 旧） | v2 处置 |
|---|---|---|---|
| **Issue** | 保留小写英文 `issue`（L113，"没有公认中文译法"） | 任务（L28） | 改回保留英文。"任务"已被 task 占用，撞车 |
| **Skill** | 保留小写英文 `skill`（L114） | 技能（L27） | 改回保留英文 |
| **Task** | 执行任务（上下文清楚后简写"任务"，L112） | 间接被 Issue→任务抢占 | 明确 task=执行任务/任务，issue=英文 |
| **Runtime** | 运行时（L131） | 运行环境（L26，TERMS L213 自挂 [W0-CONFIRM]） | 改为运行时 |

### B-2 通用 UI 词

| 英文 | conventions | TERMS v1 | v2 处置 |
|---|---|---|---|
| Assignee | 负责人（L170） | 处理人（L33） | 改为负责人，与 Reporter（报告人）成对 |
| Sign out / Log out | 退出登录（L158） | 退出（L66） | 改为退出登录（避免与桌面端"退出应用"歧义） |
| Create | 创建（L161） | 新建（L77） | 拆分：Create→创建，New→新建 |
| New | 新建（L161） | 未单列 | 同上 |
| Loading | `加载中…`（L164） | `加载中`（L82） | 加回省略号（与英文 Loading… 对齐） |

### B-3 角色名 / Issue 状态名（系统性冲突）

conv L177–188 明文：**角色 + Issue 状态是 schema-level 标识符，中文环境也保持小写英文**。TERMS 第 4 节全部强译中文，需推翻。

| 英文 | conv | TERMS v1 | v2 处置 |
|---|---|---|---|
| Owner | `owner` | 所有者（L94） | 不翻 |
| Admin | `admin` | 管理员（L95） | 不翻 |
| In Progress | `in_progress` | 进行中（L119） | 不翻 |
| Blocked | `blocked` | 已阻塞（L120） | 不翻 |
| Done（状态） | `done` | 已完成（L121） | 状态保留英文；通用动作 Done→完成（conv L164） |
| Cancelled | `cancelled` | 已取消（L123） | 不翻 |
| Open | conv 无此状态 | 待处理（L118） | 删除（Multica schema 用 backlog/todo/in_review） |

### B-4 标点风格

| 维度 | conv | TERMS v1 | v2 处置 |
|---|---|---|---|
| 中文引号 | 直引号 `"..."`，明确禁「」和弯引号（L272） | 中文弯引号 `""`（L193） | 改为直引号 |
| 省略号 | `...` 三点，禁 `…`（L273） | `……`，UI 中 `…`（L194） | 统一 `...` |

---

## 3. 类 C — vivo 增量（conv 未覆盖，v2 保留）

### C-1 业务派生术语（保留进 v2 §1）
Squad / Board / Provider / Blocker / Activity / Workflow / Agent Squad / Skill Library / Runtime Logs / Issue Board / Sub-issue / Parent issue / Assign / Unassign / Blocked by / Blocks / Activity Feed / Workflow Run / Workflow Step / Provider Key
（约 20 词，TERMS L25–L57）

### C-2 通用 UI 词增量（保留进 v2 §2）
Filter / Sort / Submit / Reset / Refresh / Copy / Paste / Export / Import / Role / Permission / Dashboard / Overview / Details / Created at / Updated at / Due date / Severity
（约 18 词，TERMS L80–L110）

### C-3 状态词增量（v2 必须区分语境）
Closed / Pending / Succeeded / Running / Queued / Draft（TERMS L122–L129）

⚠️ **若是 schema 状态值** → 按 conv 规则保留小写英文
⚠️ **若是 UI 临时态描述**（如"加载中"语境）→ 中译
v2 §3 必须明确划分两种语境，避免再次踩 B-3 的坑。

### C-4 规则类增量（保留进 v2 §3–§5）
- 长度约束：按钮 ≤6、表头 2–4、菜单 ≤5、Tooltip ≤20（TERMS L15）— conv 仅说"按钮 2–4 字最佳"（L280）
- 数字单位半角空格：`5 分钟` / `200 ms` / `1.2 GB`（TERMS L192）— conv 未覆盖
- 一词一译原则（TERMS L12）— conv 隐含未明示
- "你" vs "您" 约定（TERMS L218，建议统一"你"）— conv 未提
- vivo 内部产品语感：禁"哦/啦/呢"（TERMS L146, L200）— conv 未提
- 错误信息 / 空状态正反例（TERMS L201–L206）— conv 只有原则

---

## 4. v2 目标结构

```
# Multica 术语表 v2（zh-CN，vivo 业务补丁）

> 本文件是 conventions.zh.mdx 的下游补丁，仅收录 conv 未覆盖的
> vivo 业务术语与 vivo 内部产品语感约束。
> 任何 conv 已规定的词条以 conv 为准，本文不重复。
> 上游权威：apps/docs/content/docs/developers/conventions.zh.mdx

## 0. 与上游的关系
## 1. 业务派生术语（conv 词根 × vivo 复合）  ← C-1
## 2. conv 未覆盖的通用 UI 词                  ← C-2
## 3. vivo 长度约束 + 状态语境划分              ← C-3 + C-4 一部分
## 4. 数字与单位排版                            ← C-4
## 5. vivo 内部语感（"你"/语气词/错误信息正反例）  ← C-4
## 6. 历史冲突归档（v1→v2 迁移说明）            ← 半年后可删
## 7. 变更记录
```

体量预估：v1 226 行 → v2 ~ 90–110 行。

---

## 5. 交接与执行

- 责任窗：**W4**（fix/vivo-zh-translation-quality-audit）
- 工作目录：`/Users/bing/Documents/opencode/multica-w4`
- 输入：本文件 + conventions.zh.mdx + TERMS.md v1
- 产出：TERMS.md v2 + WP-3 审计报告同步引用
- ETA：Day 2 中午（约 1 个工作单元）
- W0 验收：审计 v2 是否所有 B 类条目都已修订、所有 C 类都保留、整体 ≤ 110 行

## 6. 决议关联

- D-009（conventions.zh.mdx 唯一术语权威）正式收口于 v2 落地
- 半年后 v2 §6 历史归档段可删除（即 conv 与 v2 完全互不重叠）
