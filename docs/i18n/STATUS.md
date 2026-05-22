# Multica i18n 多窗协作 · 主进度面板

> **维护人**：W0（主窗）
> **节奏**：W0 每 2 小时整合一次，各窗每天 18:00 自报
> **规则**：本文件由 W0 单写。各窗向自己的子段落追加；需要交流改动跨段，先抛 W0。
> **仓库**：v0.3.5 tag → 分支 `vivo-i18n-zh`
> **关键文件**：决议见 `W0-DECISIONS.md`、术语对齐 `apps/docs/content/docs/developers/conventions.zh.mdx`、抽样报告 `ZH-HANS-AUDIT.md`

---

## 0. 重大背景修订（Day 0 22:00）

**核查仓库现状后发现 v0.3.5 上游已自带：**

1. ✅ i18next + react-i18next 完整框架
2. ✅ `packages/views/locales/zh-Hans/` 24 个 namespace × 平均 273 行 = 6558 行翻译，质量极高
3. ✅ `apps/docs/content/docs/developers/conventions.zh.mdx` 302 行权威术语规范
4. ✅ `parity.test.ts` 翻译完整性测试

**结论**：vivo 不需要做"中文化改造"，只需做"产品级中文版交付"。

**已废止**：D-001（next-intl）/ D-002（zh-CN locale code）/ D-003（vivo 7 项术语）。
**已生效**：D-007（i18next 事实确认）/ D-008（默认 zh-Hans + 保留切换器）/ D-009（conventions.zh.mdx 唯一权威）/ D-010（重新定义 8 个工作面 WP-1~WP-8）/ D-011（分支命名 `feat/vivo-*`）。

---

## 1. 窗口编号与角色对照（修订后）

| W0 编号 | 自我标签 | 新角色 | 子分支 | 状态 |
|---|---|---|---|---|
| W0 | 主窗 | 协调 / 仲裁 / STATUS 主写 | `vivo-i18n-zh` | 🟢 在岗 |
| W1 | 部署 | WP-1 单机自部署跑通 | `feat/vivo-selfhost-zh-bootstrap` | ⏳ 待启动 |
| W2 | i18n 框架 | **解散**（D-007） | — | ⛔ 关闭 |
| W3a | UI 改造 A | WP-2 默认 locale 切 zh-Hans + WP-4 漏网英文扫描（apps/web） | `feat/vivo-zh-default-locale` / `fix/vivo-zh-leftover-en-web` | ⏳ 待启动（任务大幅缩小） |
| W3b | UI 改造 B | WP-4 漏网英文扫描（packages/views & 其他） | `fix/vivo-zh-leftover-en-views` | ⏳ 待启动（任务大幅缩小） |
| W4 | 翻译（自称 W6） | WP-3 zh-Hans 质量审计 + WP-6 docs 文档站盘点 | `fix/vivo-zh-translation-quality-*` | 🟢 等接收新任务书 |
| W5 | 后端 | WP-5 后端 i18n 现状盘点 + 补缺 | `feat/vivo-server-i18n` | ⏳ 待启动 |
| W6 | 测试 | WP-7 E2E 中文回归 | `test/vivo-zh-e2e` | ⏳ 待启动 |
| W7 | 走查/PR（自称 W-review） | WP-8 上游 PR：翻译质量增强 + 后端 i18n（**非框架引入**） | `i18n/upstream-pr-*` | 🟢 等接收新任务书 |

---

## 2. 各窗进度（每天 18:00 各窗在自己段落追加）

### W1 · 部署（任务不变）
> **W1 自报**：在此追加 Day N 进度。

_暂无_

---

### W2 · i18n 框架 ⛔ 已解散
> 上游已用 i18next，本窗任务全部作废。原 W2 操作员请改加入 W3a 或 W4。

---

### W3a · 默认 locale + 漏网扫描（apps/web）
> **W3a 自报**：原任务书的"字符串抽离"已废，新任务为 WP-2 + WP-4。

_暂无_

#### 新任务书摘要（替代旧 prompt）
1. **WP-2**：把默认 locale 切到 `zh-Hans`。先读 `packages/core/i18n/pick-locale.ts` 与 `apps/web/middleware.ts`（如有），定位上游怎么决定默认 locale。改动应是 1-2 行级别（修改 `defaultLocale` / cookie 兜底逻辑），**不要**删切换器
2. **WP-4**：在 `apps/web/` 扫漏网英文硬编码。命令样例：`rg -nP '"[A-Z][a-z]+( [A-Z]?[a-z]+){0,4}[\.\?\!]?"' apps/web/src --type tsx --type ts | grep -v "i18n\|test\|//\|^\s*\*"`，人工筛选漏网项
3. 输出：每个漏网点对应的修复 PR，引用 `conventions.zh.mdx` 规则

---

### W3b · 漏网扫描（packages/views & 其他）
> **W3b 自报**：原任务书已废，新任务为 WP-4 在 packages/views & 其他 packages。

_暂无_

#### 新任务书摘要
1. 范围：`packages/views/` `packages/ui/` `packages/core/`
2. 注意：`packages/views/locales/` 已是翻译源，**不要**碰；扫的是组件代码里残留的英文 string literal
3. 与 W3a 共享 grep 模板，分目录跑

---

### W4 · 翻译质量审计（重定位）
> **W4 自报**：你原 TERMS.md v1 大量与 conventions.zh.mdx 冲突，**降级为 vivo 增量补充**（目前为空）。新主战场是 WP-3 + WP-6。

#### Day 0 — 旧产出处理
- ⚠️ `docs/i18n/TERMS.md` v1 与 `conventions.zh.mdx` 多处冲突 → 不删，**改写为引用 conventions + 仅记 vivo 增量**（W4 在 Day 1 改）
- ⚠️ `docs/i18n/LLM_PROMPT.md` / `docs/i18n/TRANSLATION_NOTES.md` STATUS 中提及但未落盘 → **取消该次产出要求**（新任务不需要从零翻译，无需 LLM prompt）
- ⏸ 阻塞已解除：原 KEYS.json / 邮件源依赖在新任务下不再阻塞

#### Day 1 新任务书摘要（WP-3 + WP-6）
1. **WP-3**（zh-Hans 质量审计）：
   - 先跑 `pnpm test --filter views parity.test.ts` 确认 en/zh-Hans key 一致
   - 写 lint 脚本扫所有 `packages/views/locales/zh-Hans/*.json` 的违规：含 `…`、含弯引号、含"您"、中英无空格
   - 抽 10% 样本（约 600 行）人工对照 `conventions.zh.mdx` §2 概念词表
   - 产出 `docs/i18n/WP-3-AUDIT-REPORT.md`
   - 详见 `docs/i18n/ZH-HANS-AUDIT.md`（W0 已写抽样起手）
2. **WP-6**（apps/docs zh 文档盘点）：
   - 列 `apps/docs/content/docs/**/*.mdx` 哪些有 `.zh.mdx`、哪些没有
   - 输出 `docs/i18n/WP-6-DOCS-COVERAGE.md`
3. 改写 `TERMS.md`：删 §3-§7 与 conventions 冲突的内容，只留 vivo 内部增量词（如 vivo 内部品牌词、合规话术——目前可能为空）

---

### W5 · 后端 i18n（任务不变，更聚焦）
> **W5 自报**：在此追加 Day N 进度。

#### Day 0 · 22:30 — 盘点完成
- ✅ 创建分支 `feat/vivo-server-i18n`
- ✅ 交付 `docs/i18n/WP-5-SERVER-I18N-AUDIT.md`
- **关键结论**：上游 v0.3.5 **完全没有** server-side i18n
  - 邮件 2 模板（验证码 / 邀请）全英文硬编码于 `server/internal/service/email.go`
  - HTTP error message 共 **825 处** `writeError(w, status, "english")`，无 error code，无翻译机制
  - `user.Language` 字段仅供前端 i18next，**服务端从不读**
  - CLI / log 暂不在 i18n 范围（运维语义）
  - 无重置密码邮件（passwordless）
- **走分支 ②**（上游未做）：vivo fork 立刻落地 P0/P1，长期方案抽成 PR-B 给 W7
- 优先级：**P0** 邮件中文化 → **P1** error message 拦截层 + 50 条高频翻译表 → P3 CLI 不动
- 阻塞 / 依赖：邮件文案待 W4 走查；W7 PR-B 等本审计 + P1 拦截层落地

#### 待办（Day 1-5）
- Day 1：`email.go` 加 locale 分支 + zh-Hans 模板 + 单测
- Day 2：邮件 PR 草稿 + 翻译草案交 W4
- Day 3：error 拦截层 + 50 条翻译表
- Day 4：扩 ~150 条 + 等 W1 部署完联调真实邮件
- Day 5：抽象为上游 PR-B 提案文，交付 W7

#### 任务书摘要（WP-5）
1. **盘点**：上游有没有 server-side i18n？查 `server/` 目录的邮件模板、错误码、HTTP response message
   - 输出 `docs/i18n/WP-5-SERVER-I18N-AUDIT.md`
2. 若上游**无** server-side i18n：设计方案 + 实现 + 提案 PR 给上游
3. 若上游**有**：跑同样 zh-Hans 翻译质量审计 + 修复

---

### W6 · 测试（任务不变）
> **W6 自报**：在此追加 Day N 进度。

_暂无_

#### 任务书摘要（WP-7）
1. 写 playwright 用例覆盖：登录页 / issues / agents / settings 在 `locale=zh-Hans` 下渲染
2. 关键检查：无英文残留、无 lint 违规字符（`…` / 弯引号）
3. 接 CI

---

### W7 · 走查 / 上游 PR（重定位）
> **W7 自报**：原"i18n 框架引入"PR 主线作废，新主线是 WP-8。

#### Day 0 — 已交付（保留）
- ✅ `docs/i18n/REVIEW_CHECKLIST.md`（需按 D-009 重写"框架与库"章节）
- ✅ `docs/i18n/UPSTREAM_PR.md`（PR 战略需重写为"翻译质量增强 + 后端 i18n"，**非**"引入框架"）
- ✅ `docs/i18n/REVIEW_LOG.md`（结构保留）
- ✅ `docs/ops/UPSTREAM_REBASE.md`（仍生效）
- ✅ `scripts/i18n/rebase-upstream.sh`（仍生效）

#### W7 → W0 上抛已闭环
- ✅ D-001 next-intl 与现状冲突 → W0 已撤销 D-001，改 D-007 锁 i18next
- ✅ Apache 2.0 无 CLA → 确认无阻塞
- ✅ 上游 fork URL 已确认：`https://github.com/YanBing03/multica`（岩冰个人 GitHub）

#### Day 1 新任务书摘要（WP-8）
1. ✅ 改写 `REVIEW_CHECKLIST.md`：删"框架与库"段，§1/§2 改为对齐 conventions.zh.mdx §2/§3，新增 §7 上游兼容性 + reviewer 操作模板（176 行落盘）
2. ✅ 改写 `UPSTREAM_PR.md`：PR-A/B/C 战略重定位，三套独立描述模板，cherry-pick 6 步 checklist，git remote 已对齐 `origin = YanBing03/multica` / `upstream = multica-ai/multica`（241 行落盘）
3. ⏳ 等 WP-3 / WP-5 / WP-6 触发后再启动 cherry-pick；W7 起手扫 apps/docs 缺失 zh.mdx（与 W4 共担 WP-6）
4. ⏳ Day 2：阅读上游 `CONTRIBUTING.md` / PR 模板对齐规范，建 `docs/i18n/UPSTREAM_FINDINGS.md`

---

## 3. 跨窗依赖关系实时看板（修订）

| 依赖项 | 提供方 | 消费方 | 状态 | 阻塞? |
|---|---|---|---|---|
| 仓库 git 初始化 | W0（已代办） | 全员 | ✅ | 否 |
| 单机部署能跑 | W1 | 全员（视觉验证） | ⏳ Day 0-1 | 软阻塞产品形态共识 |
| zh-Hans parity test 通过 | W4 | 全员 | ⏳ Day 1 | 不阻塞 |
| WP-3 审计报告 | W4 | W7 上游 PR-A | ⏳ Day 1-3 | 阻塞 PR-A |
| WP-5 后端 i18n 现状 | W5 | W7 上游 PR-B | ⏳ Day 0-2 | 阻塞 PR-B |
| WP-6 docs 覆盖盘点 | W4 / W7 | W7 上游 PR-C | ⏳ Day 1-2 | 阻塞 PR-C |
| 漏网英文清单 | W3a + W3b | W4（参考） / W7（走查） | ⏳ Day 1-3 | 软阻塞 |
| 上游 fork URL 确认 | 岩冰 | W7 | ✅ `github.com/YanBing03/multica` | 不再阻塞 |

---

## 4. W0 决议汇总（持续追加）

> 详版见 `W0-DECISIONS.md`。

- **D-001 [SUPERSEDED]** next-intl
- **D-002 [SUPERSEDED]** 默认 zh-CN
- **D-003 [SUPERSEDED]** vivo 7 项术语
- **D-004** STATUS.md 唯一位置 = `docs/i18n/STATUS.md` ✅
- **D-005 [PARTIAL]** 窗口编号映射保留；分支命名被 D-011 替代
- **D-006** 风险池准入
- **D-007** i18n 框架 = i18next（事实确认） ✅
- **D-008** 默认 locale = zh-Hans，保留切换器 ✅
- **D-009** 术语风格唯一权威 = `conventions.zh.mdx` ✅
- **D-010** 8 个工作面 WP-1 ~ WP-8 ✅
- **D-011** 分支命名 `feat/vivo-*` / `fix/vivo-zh-*` ✅

---

## 5. 阻塞 / 风险池

| 时间 | 来自 | 内容 | 处理 |
|---|---|---|---|
| Day 0 | W4 | 7 项术语歧义 | ✅ 全部以 `conventions.zh.mdx` 为准（D-009） |
| Day 0 | W7 | i18n 库选型未拍 | ✅ D-007 锁 i18next |
| Day 0 | W7 | 上游 remote / CLA 未确认 | ✅ Apache 2.0 无 CLA；fork = `github.com/YanBing03/multica` |
| Day 0 | 全员 | 多窗自我编号不一致 | ✅ D-005 W0 统一记账 |
| Day 0 | 全员 | 根目录 STATUS.md 冲突 | ✅ D-004 收敛到 docs/i18n/STATUS.md |
| **Day 0 22:00** | W0 | **9 窗作战核心假设崩——上游已自带 i18n** | ✅ D-007~D-011 重定义工作面 |
| Day 0 | W0 | W4 LLM_PROMPT.md / TRANSLATION_NOTES.md 提及未落盘 | ✅ 新任务无需，取消产出要求 |

---

## 6. 跨窗讨论区（异议 / 上抛）

> 各窗对决议有异议、需要 W0 仲裁的事项，按时间倒序追加。

_暂无_

---

## 7. W0 巡查日志

- **Day 0 · 21:30** — 巡查发现：W1 未启动 / W4 已交付 TERMS（部分）/ W7 已交付 CHECKLIST + REBASE 脚本；处理多窗根目录 STATUS.md 冲突；代办 git clone + 建分支；写 W0-DECISIONS v1（D-001~D-006）+ STATUS v1
- **Day 0 · 22:00** — 核查仓库现状，发现 v0.3.5 上游已完整接入 i18next + zh-Hans 24 ns 6558 行翻译 + conventions.zh.mdx 302 行权威术语 + parity.test.ts；废 D-001/D-002/D-003，新增 D-007~D-011；写 ZH-HANS-AUDIT.md 抽样报告（结论：质量极高，可作 baseline）；STATUS.md 全篇重写为新工作面 WP-1 ~ WP-8
- **Day 1 · 09:00（实际 11:30 补做）** — worktree 启用后首次跨窗巡查（按各 worktree git log 抽查）：
  | 窗 | 进度 | 备注 |
  |---|---|---|
  | W1 | ⏳ 未启动 | 分支建好但 0 commit；Day 1 必须起 docker compose |
  | W2 | ❌ 已解散（D-010） | 待 09:00 决断转岗去向 |
  | W3a | ✅ 5b713dcb 默认 zh-Hans 已交 | WP-2 完成，下步：等 W4 lint 出长度违规清单 |
  | W3b | ✅ 19072500 WP-4 扫描已交 | 134 处漏网 EN 已 triage；下步：实修 high+medium 部分 |
  | W4 | ✅ 74f9a11b WP-3+WP-6+TERMS v2+lint 脚本已交 | TERMS 改的还不彻底，已 W0 出 TERMS-CONFLICTS.md 指引下一轮 v2 |
  | W5 | ⏳ 未启动 | WP-5 audit 已在 trunk（3b8b1252）；Day 1 起邮件模板 zh-Hans + locale 分支 |
  | W6 | ⏳ 未启动（待解封） | feat/vivo-zh-tests 已建空分支；继续等 W1 部署 + W4 audit 落地后再发力 |
  | W7 | ✅ 3b8b1252 + 61dd2e0c REVIEW + UPSTREAM_PR v2 已交 | 等 W4 WP-3 报告稳定后启动 cherry-pick PR-A |
- **Day 1 · 11:35** — D-009 收口：W0 产出 `docs/i18n/TERMS-CONFLICTS.md` 90+ 条冲突清单（B 类需修 / C 类保留 / v2 目标结构 ~110 行），交付 W4 在 `multica-w4/` worktree 执行。预计 Day 2 中午 W4 交付 TERMS.md v2。
- **Day 1 · 11:40 W2 转岗决议（待岩冰拍板）** — W2（i18n 框架窗）已废，3 个候选去向：
  - **A. 并入 W4** — 协助 TERMS v2 改写 + parity test 跑通（最匹配 W2 原语言能力）
  - **B. 并入 W7** — 协助上游 PR-A/B/C 走查（reviewer 缺人）
  - **C. 接管 WP-6 文档侧** — 把 apps/docs 缺失的 .zh.mdx 补全（独立工作面，可平行）
  - W0 推荐 **A**：W4 任务最重（TERMS v2 + WP-3 audit + lint 三件套），分担最有价值。
- **Day 1 · 11:45 D-012 落地** — 岩冰拍板选 A：**W2 即日并入 W4**。已发第三轮联合任务书（HANDOFF-NOTICES.md），ETA Day 2 12:00 交付 TERMS.md v2 + parity test 通过；Day 2 18:00 WP-3 审计报告 v2 同步完成。提交规则：W4 自己 `[W4] xxx`、W2 协作 `[W4/W2] xxx`。
- **Day 1 · 11:15** — 多窗共享 working tree 引发 race（4 次被中途切分支 / 2 次 commit 落错分支），抢救 stash@{0..3} 全部产出落盘：
  - `3b8b1252` [W0 collation] W5 server i18n audit + W7 review/PR rewrite
  - `61dd2e0c` [W0 collation] W7 UPSTREAM_PR rewrite + STATUS Day1 self-report
  - W4 自交 `74f9a11b` WP-3+WP-6+TERMS v2；W3a 自交 `5b713dcb` 默认 zh-Hans；W3b 自交 `19072500` WP-4 扫描
  - 全部 stash 已 drop；vivo-i18n-zh 已 push origin
- **Day 1 · 11:20** — **⚡ 启用 git worktree**，终结共享根目录 race。各窗专属路径：
  - W0 `/Users/bing/Documents/opencode/Multica` （vivo-i18n-zh，trunk）
  - W1 `../multica-w1` （feat/vivo-selfhost-zh-bootstrap）
  - W3a `../multica-w3a` （feat/vivo-zh-default-locale）
  - W3b `../multica-w3b` （fix/vivo-zh-leftover-en-views）
  - W4 `../multica-w4` （fix/vivo-zh-translation-quality-audit）
  - W5 `../multica-w5` （feat/vivo-server-i18n）
  - W6 `../multica-w6` （feat/vivo-zh-tests，新建）
  - W7 `../multica-w7` （feat/vivo-zh-review，新建）
  - **强制规则**：从此各窗 `cd` 到自己专属 worktree 工作，禁止 `git checkout` 切分支，禁止在 `Multica/` 写代码（除 W0 协调文档）
