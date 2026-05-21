# Multica 术语表 v1（zh-CN）

> 适用范围：apps/web、server、CLI、邮件、文档全栈中文化
> 维护人：W6（i18n/translations）
> 状态：**待 W0 确认**
> 最后更新：Day 0

---

## 0. 总原则

1. **一词一译**：同一英文术语在 UI、文档、邮件、错误码中必须统一中译，禁止同义切换。
2. **专业优先**：用户为 vivo AI 产品部技术 PM + 工程师（150 人内部），翻译偏工程语感，不做面向 C 端的"软化"。
3. **技术词保留英文**：API、JWT、WebSocket、PR、CLI、HTTP、HTTPS、URL、UUID、SDK、OAuth、SSO、CI/CD、Token、Webhook、SSH、TLS、JSON、YAML、Markdown、ID 等，**不译**。
4. **长度约束**：按钮 ≤ 6 字，表头 2–4 字，菜单项 ≤ 5 字，Tooltip ≤ 20 字。
5. **歧义上抛**：拿不准、有多种合理译法的，挂 `[W0-CONFIRM]` tag 抛 W0，不擅自决定。

---

## 1. 核心术语表

| EN | ZH | 词性 | 备注 |
|---|---|---|---|
| Agent | 智能体 | n. | 不译为"代理/Agent"。复数仍为"智能体"。 |
| Squad | 小队 | n. | 不译为"小组/团队/分队"，与 Team 区分。 |
| Runtime | 运行环境 | n. | 不简写为"运行时"（除非空间极紧，需上抛）。 |
| Skill | 技能 | n. | 不译为"能力/Skill"。 |
| Issue | 任务 | n. | 不译为"议题/问题/Issue"。在 issue tracker 上下文中固定为"任务"。 |
| Workspace | 工作区 | n. | 不译为"工作空间"。 |
| Board | 看板 | n. | 不译为"面板/Board"。 |
| Daemon | 守护进程 | n. | 不简写。 |
| Provider | 模型提供方 | n. | LLM 上下文专用译法；非 LLM 场景需上抛。 |
| Assignee | 处理人 | n. | 不译为"指派人/受让人/负责人"。 |
| Blocker | 阻塞项 | n. | 不译为"阻塞/障碍"。 |
| Comment | 评论 | n. | 动词形态译为"评论"或"添加评论"。 |
| Activity | 动态 | n. | 不译为"活动/Activity"。 |
| Workflow | 工作流 | n. | 不译为"流程/工作流程"。 |

---

## 2. 派生 / 关联术语（基于 v1 推导，待 W0 一并确认）

| EN | ZH | 备注 |
|---|---|---|
| Agent Squad | 智能体小队 | 复合词直译。 |
| Skill Library | 技能库 | |
| Runtime Logs | 运行日志 | "运行环境日志"过长，UI 简化。 |
| Issue Board | 任务看板 | |
| Sub-issue | 子任务 | |
| Parent issue | 父任务 | |
| Assign / Unassign | 指派 / 取消指派 | 动词。 |
| Blocked by | 受阻于 | 关系词。 |
| Blocks | 阻塞 | 关系词。 |
| Activity Feed | 动态流 | |
| Workflow Run | 工作流运行 | |
| Workflow Step | 工作流步骤 | |
| Provider Key | 模型密钥 | UI 紧凑语境。 |

---

## 3. 通用 UI 词汇（vivo 内部产品语感）

| EN | ZH | 长度 | 备注 |
|---|---|---|---|
| Sign in | 登录 | 2 | **不用"登陆"**。 |
| Sign out | 退出 | 2 | 不用"登出/注销"。 |
| Sign up | 注册 | 2 | |
| Account | 账号 | 2 | **不用"帐号"**（统一 GB/T 标准）。 |
| Profile | 个人资料 | 4 | |
| Settings | 设置 | 2 | |
| Save | 保存 | 2 | |
| Cancel | 取消 | 2 | |
| Confirm | 确认 | 2 | |
| Delete | 删除 | 2 | |
| Remove | 移除 | 2 | 与 Delete 区分：Delete=销毁，Remove=解除关联。 |
| Edit | 编辑 | 2 | |
| Create | 新建 | 2 | 不译为"创建"，UI 更短。 |
| Add | 添加 | 2 | |
| Search | 搜索 | 2 | |
| Filter | 筛选 | 2 | |
| Sort | 排序 | 2 | |
| Loading | 加载中 | 3 | |
| Submit | 提交 | 2 | |
| Reset | 重置 | 2 | |
| Refresh | 刷新 | 2 | |
| Copy | 复制 | 2 | |
| Paste | 粘贴 | 2 | |
| Upload | 上传 | 2 | |
| Download | 下载 | 2 | |
| Export | 导出 | 2 | |
| Import | 导入 | 2 | |
| Invite | 邀请 | 2 | |
| Member | 成员 | 2 | |
| Owner | 所有者 | 3 | |
| Admin | 管理员 | 3 | |
| Role | 角色 | 2 | |
| Permission | 权限 | 2 | |
| Notification | 通知 | 2 | |
| Dashboard | 仪表盘 | 3 | 不译为"看板"，避免与 Board 冲突。 |
| Overview | 概览 | 2 | |
| Details | 详情 | 2 | |
| Status | 状态 | 2 | |
| Created at | 创建时间 | 4 | |
| Updated at | 更新时间 | 4 | |
| Due date | 截止时间 | 4 | |
| Description | 描述 | 2 | |
| Title | 标题 | 2 | |
| Tag / Label | 标签 | 2 | 两词共用一中译。 |
| Priority | 优先级 | 3 | |
| Severity | 严重程度 | 4 | |

---

## 4. 状态词（任务/工作流通用）

| EN | ZH |
|---|---|
| Open | 待处理 |
| In Progress | 进行中 |
| Blocked | 已阻塞 |
| Done | 已完成 |
| Closed | 已关闭 |
| Cancelled | 已取消 |
| Pending | 等待中 |
| Failed | 失败 |
| Succeeded | 成功 |
| Running | 运行中 |
| Queued | 排队中 |
| Draft | 草稿 |
| Archived | 已归档 |

---

## 5. 正反例

### 5.1 Agent

✅ **正例**
- "新建智能体"
- "智能体小队"
- "该智能体暂未配置技能"

❌ **反例**
- "新建代理" / "新建 Agent" / "创建一个 agent"
- "Agent 小队"
- "这个智能体没有技能哦~"（语气过软，不符合内部工程产品语感）

### 5.2 Issue

✅ **正例**
- "在看板上创建任务"
- "该任务被 #123 阻塞"
- "子任务 3 / 5 已完成"

❌ **反例**
- "在 Board 上创建 Issue"
- "议题被阻塞"
- "工单 3/5 完成"

### 5.3 Sign in / Account

✅ 登录 / 账号
❌ 登陆 / 帐号 / 帐户

### 5.4 Runtime

✅ "运行环境启动失败" / "运行环境日志"
❌ "运行时启动失败" / "Runtime 日志"

### 5.5 长度违规

❌ 按钮："立即创建一个新的智能体"（11 字，违反 ≤ 6 字）
✅ 按钮："新建智能体"（5 字）

❌ 表头："任务的处理人"（6 字，违反 2–4 字）
✅ 表头："处理人"（3 字）

### 5.6 技术词不译

✅ "请妥善保管你的 API Key"
❌ "请妥善保管你的应用程序接口密钥"

✅ "WebSocket 连接已断开"
❌ "网络套接字连接已断开"

---

## 6. 标点与排版规则

1. 中英文之间加半角空格：`保存到 GitHub`，不写 `保存到GitHub`。
2. 中文使用全角标点：`，。？！；：""''（）`，**不**用半角。
3. 数字、单位与英文保持半角：`5 分钟`、`200 ms`、`1.2 GB`。
4. 引号统一中文弯引号 `""`，代码/路径用反引号包裹（Markdown 上下文）。
5. 省略号用 `……` 不用 `...`（UI 中除外，UI 用 `…` 单字符）。

---

## 7. 语气基调

- **平视、专业、不啰嗦**：用户是工程师/PM，不需要"哦~"、"啦"、"呢"等软化语气词。
- **错误信息**：客观陈述 + 给出动作，不卖萌、不道歉过度。
  - ✅ "鉴权失败，请检查 API Key 是否正确。"
  - ❌ "啊哦，好像出了点小问题，要不要再试一次呢？"
- **空状态**：陈述 + 一个明确的下一步。
  - ✅ "暂无任务。点击右上角"新建任务"开始。"
  - ❌ "这里空空如也~"

---

## 8. 待确认项（@W0）

- [ ] **Provider** = "模型提供方"：在非 LLM 上下文（如 Auth Provider）是否切换为"提供方"？
- [ ] **Runtime** UI 极窄场景是否允许简称"运行时"？
- [ ] **Squad** 与 **Team** 在产品中是否同时存在？若同时存在，Team 译什么？
- [ ] **Skill** 与 **Tool** 是否同时存在？若同时存在，Tool 译什么？（建议：工具）
- [ ] **Workspace** 与 **Project** 关系？是否同时存在？
- [ ] **Dashboard** 译"仪表盘"还是"控制台"？vivo 内部其他产品惯例如何？
- [ ] 是否需要敬语？（建议：统一"你"，不用"您"，与 Linear/Notion 风格一致）

---

## 9. 变更记录

| 版本 | 日期 | 变更 | 作者 |
|---|---|---|---|
| v1 | Day 0 | 初版，基于任务书核心 14 词 + 派生 + 通用 UI 词 | W6 |
