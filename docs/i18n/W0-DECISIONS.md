# W0 决议汇总（vivo Multica i18n）

> W0 主窗对全局架构、流程、术语的**最终裁定记录**。
> STATUS.md §3 引用本文。各窗对决议有异议须到 STATUS.md §6 留言，W0 在 24h 内回应。
> **保留历史**：被推翻的决议标 `[SUPERSEDED]`，不删除。

---

## 0. 重大背景修订（Day 0 · 22:00）

W0 在 D-001~D-006 落笔后核查仓库现状，发现 v0.3.5 上游已自带：

1. **完整 i18n 框架**：`i18next + react-i18next`，已 wire 到 `packages/core/i18n/` 与 `packages/views/i18n/`
2. **完整 zh-Hans 翻译**：`packages/views/locales/zh-Hans/` 24 个 namespace，6558 行，质量极高
3. **权威术语规范**：`apps/docs/content/docs/developers/conventions.zh.mdx` 302 行，已实战 20+ 篇
4. **翻译完整性测试**：`packages/views/locales/parity.test.ts`

这意味着 **vivo 不需要做"中文化改造"，只需要做"产品级中文版交付"**——即默认开 zh-Hans + 漏网英文扫描 + 后端 i18n 补缺 + E2E 回归 + 翻译质量增量增强。

**D-001 ~ D-005 全部 SUPERSEDED**，由 D-007 ~ D-010 替代。

---

## D-001 [SUPERSEDED by D-007] i18n 框架选型 = next-intl

> 原裁定：vivo fork 用 next-intl。
> 撤销原因：与上游事实不符——上游已用 i18next。

## D-002 [SUPERSEDED by D-008] 默认 locale = zh-CN

> 原裁定：默认 zh-CN，不切换。
> 撤销原因：上游 locale code 是 `zh-Hans`，不是 `zh-CN`，应沿用上游。

## D-003 [SUPERSEDED by D-009] TERMS.md §8 七项裁定

> 原裁定：W0 拍 7 项术语。
> 撤销原因：与 `conventions.zh.mdx` 多处冲突（Skill/Issue/Task 不翻、引号用直引号、省略号用三点、Runtime=运行时）。
> conventions.zh.mdx 是上游唯一权威，vivo 应全盘对齐。

## D-004 STATUS.md 单一来源 = `docs/i18n/STATUS.md`（仍生效）

**生效日**：Day 0
**适用范围**：所有窗

- **唯一**协调面板路径：`docs/i18n/STATUS.md`
- **禁止**在仓库根目录写 `STATUS.md`
- 各窗每日 18:00 编辑自己的 §1.x 段落，不得修改其他窗的段落
- 文件冲突按文件认领协议（CLAIMS.md）走

## D-005 [PARTIALLY SUPERSEDED by D-011] 窗口编号统一映射

> 原裁定：W0 以"功能角色"统一编号。
> 编号映射本身仍生效，但分支命名约定改为 `feat/i18n-vivo-*`（D-011），原 `i18n/zh-CN-*` 命名作废。

## D-006 风险池准入（首发条目，仍生效）

见 STATUS.md §4。

---

## D-007 i18n 框架 = i18next + react-i18next（事实确认）

**生效日**：Day 0 22:00
**替代**：D-001

- vivo fork **沿用上游 i18next + react-i18next**，不引入新框架
- 不允许在新代码里用 next-intl / react-intl
- 涉及 i18n 的 hook/utility 入口：`packages/core/i18n/`（Provider、adapter、locale picker）和 `packages/views/i18n/use-t.ts`
- W2 整窗任务**取消**（框架已就位），W2 人员转为 W3 备援或退出

**理由**：上游事实即定论；保持上游一致性，rebase 成本最低。

---

## D-008 默认 locale = zh-Hans，提供切换器

**生效日**：Day 0 22:00
**替代**：D-002

- vivo fork 默认 `locale = "zh-Hans"`（沿用上游 locale code，**不**重命名为 zh-CN）
- **保留**上游 settings 页的语言切换器（vivo 不删除，给万一需要英文的同事）
- 上游 PR 不修改默认 locale，保持 `defaultLocale = "en"`
- 落地点：`packages/core/i18n/pick-locale.ts` 或上游已有的 cookie/header 解析逻辑（W3a 核实）

**理由**：locale code 与上游 docs/locale 目录绑定（`zh-Hans/`），改成 zh-CN 等于自找麻烦。

---

## D-009 术语 / 风格唯一权威 = `apps/docs/content/docs/developers/conventions.zh.mdx`

**生效日**：Day 0 22:00
**替代**：D-003

- vivo 翻译/走查/PR 全部对齐 `conventions.zh.mdx`
- W4 的 `docs/i18n/TERMS.md` **降级为 vivo 增量补充**（仅记录 conventions.zh.mdx 未覆盖、且 vivo 内部需要的词），目前为空
- 任何与 conventions 冲突的 vivo 主张作废，不向上游 PR 推
- 若 vivo 需要修改 conventions.zh.mdx 本身（例如增词），必须走上游 PR，不能在 vivo fork 私改

**关键规则速查**（详见 conventions.zh.mdx §2、§3）：

- **保留英文不翻**：`issue` / `skill` / `task`、所有品牌名、API/CLI/URL 等缩写
- **必译概念词**：Workspace=工作区、Agent=智能体、Project=项目、Autopilot=自动化、Daemon=守护进程、Runtime=运行时、Inbox=收件箱、Member=成员、Label=标签、Settings=设置
- **状态/角色不翻**：`owner`/`admin`/`member`、`backlog`/`todo`/`in_progress`/`in_review`/`done`/`blocked`/`cancelled`
- **标点**：直引号 `"..."`（**不用**全角弯引号）；省略号 `...`（**不用** `…`）；中英之间加单空格
- **复数**：中文只填 `_other`
- **风格**：避免翻译腔、错误信息温和明确、按钮 2-4 字、placeholder 示例性

---

## D-010 vivo 真正的工作面（重新定义交付）

**生效日**：Day 0 22:00
**取代原 9 窗作战核心假设**

vivo 在 v0.3.5 之上**真正要交付**：

| 编号 | 工作面 | 责任窗 | 交付物 |
|---|---|---|---|
| WP-1 | 单机自部署跑通 | W1 | docker compose 起 v0.3.5 + .env 模板 + 验证清单 |
| WP-2 | 默认 locale 切 zh-Hans + 必要时关切换器 | W3a | 1-2 处代码改动 + 验证 |
| WP-3 | zh-Hans 现状质量审计（按 conventions） | W4 | 24 namespace 抽审报告 + 修订 PR 列表 |
| WP-4 | 漏网英文扫描（前端） | W3a + W3b | 漏网清单 + 修复 PR |
| WP-5 | 后端 i18n 补缺（邮件、错误码、server 日志） | W5 | 现状盘点 + 补 i18n 提议 + 实现（若上游未做） |
| WP-6 | apps/docs 文档站 zh 完整度盘点 | W4 协助 / W7 主导 | 缺失 .zh.mdx 清单 |
| WP-7 | E2E 中文回归 | W6 | playwright 中文用例 + CI 接入 |
| WP-8 | 上游 PR：翻译质量增强 / 后端 i18n（非"引入框架"） | W7 | PR 1~N，按 cherry-pick checklist 走 |

**注**：原 W2「框架接入」整窗解散；W3a/W3b 范围大幅缩小为「漏网扫描 + 局部修复」。

---

## D-011 分支命名约定（修订）

**生效日**：Day 0 22:00
**替代**：D-005 中的分支命名部分

| 工作面 | 分支命名 |
|---|---|
| W0 主线 | `vivo-i18n-zh`（仅 W0 写） |
| W1 部署 | `feat/vivo-selfhost-zh-bootstrap` |
| W3a 默认 locale + 漏网扫描 | `feat/vivo-zh-default-locale`、`fix/vivo-zh-leftover-en-web` |
| W3b 漏网扫描 | `fix/vivo-zh-leftover-en-views` |
| W4 翻译质量审计/修复 | `fix/vivo-zh-translation-quality-<scope>` |
| W5 后端 i18n | `feat/vivo-server-i18n` |
| W6 E2E | `test/vivo-zh-e2e` |
| W7 上游 PR cherry-pick | `i18n/upstream-pr-<n>`（基于 upstream/main） |

---

## 修订历史

| 版本 | 日期 | 变更 | 作者 |
|---|---|---|---|
| v1 | Day 0 21:30 | 初版 D-001 ~ D-006 | W0 |
| v2 | Day 0 22:00 | 核查仓库现状，废 D-001~D-003，新增 D-007~D-011 | W0 |
