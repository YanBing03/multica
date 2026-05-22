# Multica i18n → 上游 PR 策略

> 目标：把 vivo i18n 工作中**通用价值高、无 vivo 特殊性**的部分回馈给上游 `multica-ai/multica`。
> vivo 自有部分（默认 locale 切 `zh-Hans` 的环境变量、vivo 业务专属翻译）留 fork。
> 本文是 cherry-pick 与 PR 提交的操作手册，**未经 W0 拍板不得真实推送**。
>
> 适用前提（W0 决议）：
> - **D-007**：i18n 库锁 `i18next + react-i18next`，**不再**做框架切换 / 上游引入框架的 PR。
> - **License**：上游 Apache 2.0，**无 CLA**，可直接发 PR。
> - **远端**：`origin = https://github.com/YanBing03/multica.git`、`upstream = https://github.com/multica-ai/multica.git`（只读）。

---

## 1. 战略原则

vivo 这一轮 i18n 工作的输出，按"对上游有无通用价值"切分：

| 内容                                                  | 去向       | 触发输入                              |
| ----------------------------------------------------- | ---------- | ------------------------------------- |
| zh-Hans 翻译过程中发现的 **en.json 错误 / 不一致**    | ✅ 上游 PR-A | W4 WP-3                               |
| **后端 i18n 框架**（邮件 / 错误码 / 模板）若上游未做  | ✅ 上游 PR-B | W5 WP-5                               |
| `apps/docs` **缺失的 `.zh.mdx` 补全**                 | ✅ 上游 PR-C | W4 / W7 WP-6                          |
| 默认 locale 切 `zh-Hans` 的环境变量配置               | ❌ vivo    | vivo 产品诉求                         |
| vivo 业务专属翻译（品牌词、合规话术、内部术语）       | ❌ vivo    | 上游无意义                            |
| W6 e2e 中 vivo 私有用例                               | ❌ vivo    | 上游不需要                            |

> 注：i18next 框架本身、`packages/views/locales/{en,zh-Hans}/*.json` 拆分结构、`parity.test.ts`、`conventions.zh.mdx` 已在上游存在，**不再纳入上游 PR**。

---

## 2. 分支模型

```
upstream/main ──────────────────────────────────────► (multica-ai/multica)
        │
        ├── vivo-i18n-zh   ◄── vivo fork 主分支（含默认 locale 切换 + vivo 专属翻译）
        │       │
        │       └── 各 W2/W3a/W3b/W4/W5/W6 feature 分支 PR 合入
        │
        └── i18n/upstream-pr-A   ◄── PR-A：en.json 修订（基于 upstream/main）
        └── i18n/upstream-pr-B   ◄── PR-B：后端 i18n 框架
        └── i18n/upstream-pr-C   ◄── PR-C：docs 中文补全
```

- 三个 PR 分支彼此独立，均基于 `upstream/main` 切出
- 仅 cherry-pick 来自 `vivo-i18n-zh` 的对应窗 commit
- 提 PR 时 base = `multica-ai/multica:main`，head = `YanBing03/multica:i18n/upstream-pr-X`

---

## 3. PR 拆分清单（PR-A / PR-B / PR-C）

### 3.1 PR-A：zh-Hans 翻译过程中发现的 en.json 错误修订

**输入**：W4 WP-3（zh-Hans 翻译填充）。
**触发条件**：W4 第一批 zh-Hans namespace 翻译完成，并把发现的 en.json 问题汇总到 `docs/i18n/UPSTREAM_FINDINGS.md`（W7 维护）。

**典型内容**：
- en.json 拼写 / 语法错误（如 `recieve` → `receive`）
- 同义异形：同一个语义在不同 namespace 写法不一致（`Sign in` vs `Log in` vs `Login`）
- 占位符不一致（`{name}` vs `{{name}}` vs `%s`）
- 大小写不一致（按钮标题首字母大小写规则）
- 单复数缺失（漏 `_one` / `_other`）
- conventions.zh.mdx §2 反推出的英文不一致（中文要求翻译成同一个词，但英文 source 用了多个词）

**严禁混入**：
- 任何 zh-Hans 文件改动（PR-A 只改 en）
- 默认 locale 切换
- vivo 专属业务文案

**拆分粒度建议**：单个 PR 控制在 ≤ 30 个 key 改动；改动量大时按 namespace 拆多个 PR-A1 / PR-A2 …

### 3.2 PR-B：后端 i18n 框架（若上游缺位）

**输入**：W5 WP-5（后端 i18n 预研 + 实现）。
**触发条件**：
1. W5 调研明确**上游 server 端没有 i18n**（邮件 / 错误码 / Webhook 文案仍硬编码英文）
2. W5 在 vivo fork 上实现并验证通过 W6 e2e

**典型内容**：
- `server/internal/i18n/` 包：locale 解析（请求头 / 用户偏好）+ message catalog
- 邮件模板抽离到 `server/internal/templates/<locale>/*.tmpl`
- 错误码 → 文案映射文件（仅 en，不带 zh）
- 单元测试 + 集成测试
- `docs/i18n/CONTRIBUTING.md`（后端章节）

**严禁混入**：
- zh / zh-Hans 翻译文件（让上游社区贡献）
- 任何 vivo 自定义错误码 / 邮件模板
- 与 W4 翻译 PR 的耦合（PR-B 自包含，merge 后再补译）

**前置 issue**：发 PR 前先在上游开 issue「Server-side i18n proposal」，3 候选方案对比（`go-i18n` / `golang.org/x/text/message` / 自研），等 maintainer 表态再写。

### 3.3 PR-C：apps/docs 缺失的 .zh.mdx 补全

**输入**：W4 / W7 WP-6（doc 中文化）。
**触发条件**：
1. 扫描 `apps/docs/content/docs/` 找出有 `.mdx` 但无对应 `.zh.mdx` 的页面
2. W4 翻译完成 + W7 走查通过 conventions.zh.mdx 对齐
3. 已有的 `.zh.mdx` 与 `.mdx` 内容差异（zh 旧版）一并修订

**典型内容**：
- 新增 `.zh.mdx` 文件
- 同步 `meta.zh.json`
- 修订过期的 `.zh.mdx`（与 en 版对齐）
- 补全 `apps/docs/lib/translations.ts` 缺失条目

**严禁混入**：
- 任何 vivo 内部链接 / 截图
- vivo 专属功能描述（即便是 zh-only）
- en `.mdx` 改动（如发现英文 doc 错误，挂到 PR-A 类似流程，单独发 docs-en 修订 PR）

**拆分粒度建议**：按 doc 章节分组（getting-started / guides / developers / cli / …），每组一个 PR，便于 maintainer review。

---

## 4. 哪些 commit 该 PR / 哪些留 vivo

走查时（见 `REVIEW_CHECKLIST.md` §7）即给每个 commit 打标签：

- `[upstream-A]` / `[upstream-B]` / `[upstream-C]`：分别进对应 PR
- `[vivo-only]`：跳过
- `[mixed]`：要求作者拆 commit；reviewer 不私下改

候选清单维护在：

- 上游 en 错误 → `docs/i18n/UPSTREAM_FINDINGS.md`（W7 周一更新；尚未创建，等 W4 第一批输入）
- 上游候选 commit 列表 → `docs/i18n/REVIEW_LOG.md` 的「上游候选」段落

---

## 5. PR 标题 / 描述模板

### 5.1 标题（conventional commits）

```
fix(i18n): correct typos and inconsistencies in en locale          # PR-A
feat(server): introduce i18n framework for emails and error codes  # PR-B
docs(i18n): add Simplified Chinese translations for getting-started # PR-C
```

### 5.2 PR-A 描述模板

````markdown
## Motivation

While translating Multica into Simplified Chinese (`zh-Hans`) on a downstream fork,
we noticed several typos / inconsistencies / missing plural forms in `en` locale
files. This PR cherry-picks those English-side fixes back to upstream.

## Scope

- Files: `packages/views/locales/en/*.json`
- Keys touched: N (full list below)
- **No new locale files**, **no behavior change**

## Findings

| Namespace | Key | Before | After | Reason |
| --- | --- | --- | --- | --- |
| `auth.json` | `welcome.title` | `Wlecome to Multica` | `Welcome to Multica` | typo |
| `issues.json` | `count_one` | (missing) | `{{count}} issue` | missing plural |
| ... | ... | ... | ... | ... |

## Verification

- [x] `pnpm test` (parity.test.ts green)
- [x] `pnpm typecheck`
- [x] `pnpm lint`
- [x] Visual diff of affected screens unchanged (en only)

## Out of scope

- Translations to other locales (community-driven)
- Backend i18n (separate PR)
- Doc translations (separate PR)

cc @<maintainer>
````

### 5.3 PR-B 描述模板

````markdown
## Motivation

Multica's server-side surfaces (email notifications, error responses, webhook
payloads) currently render English-only strings hard-coded in Go source. This
blocks non-English deployments and is the natural follow-up to the existing
frontend i18n (`packages/views/locales/`).

This PR introduces a minimal, opinionated server-side i18n foundation.

## Design

- Library: `<chosen-go-i18n>` (rationale; see issue #NNN)
- Locale resolution: `Accept-Language` header > user preference > `en`
- Message catalog: `server/internal/i18n/messages/<locale>.toml`
- Email templates: `server/internal/templates/email/<locale>/*.tmpl`, fallback to `en`
- No DB schema change

## What's in / out

✅ In: framework, `en` baseline, tests, contributor docs.
❌ Out: non-English locale files (community-driven follow-ups), default locale switching.

## Migration / Backward compatibility

- No user-visible change for existing English deployments
- All endpoints accept and ignore `Accept-Language` if locale not implemented
- API contract unchanged

## Testing

- [x] Unit: locale resolution, fallback chain
- [x] Integration: email rendering, error response
- [x] e2e: full smoke pass

## Follow-ups (separate PRs)

1. Community-driven locale contributions (zh-Hans, ja, …)
2. Webhook payload locale parameter

cc @<maintainer>
````

### 5.4 PR-C 描述模板

````markdown
## Motivation

`apps/docs` currently has English `.mdx` pages without Simplified Chinese
counterparts in `<group>`. This PR adds `<N>` `.zh.mdx` files plus updated
`meta.zh.json` to bring the Chinese docs surface to parity for this section.

Translations follow `apps/docs/content/docs/developers/conventions.zh.mdx`
(terminology + style guide already merged upstream).

## Files added / changed

- `apps/docs/content/docs/<group>/page-1.zh.mdx` (new)
- `apps/docs/content/docs/<group>/page-2.zh.mdx` (new)
- `apps/docs/content/docs/<group>/meta.zh.json` (updated)
- `apps/docs/lib/translations.ts` (entries appended)

## Verification

- [x] `pnpm --filter @multica/docs build`
- [x] Locale switcher renders new pages
- [x] All internal links resolve
- [x] Snapshot of nav structure unchanged for `en`
- [x] Conventions §2 §3 self-check (no banned terms / punctuation)

## Out of scope

- English page changes (none)
- Other doc sections (separate PR)

cc @<maintainer>
````

---

## 6. Cherry-pick Checklist（每个 PR 启动前）

### 6.1 准备

- [ ] `git fetch upstream && git fetch origin`
- [ ] 确认 `UPSTREAM_FINDINGS.md` / `REVIEW_LOG.md` 已列出本 PR 的目标 commit
- [ ] `git checkout -B i18n/upstream-pr-X upstream/main`
- [ ] 确认 base 是最新 `upstream/main`（HEAD sha 与 GitHub 网页一致）

### 6.2 Cherry-pick

- [ ] 按时间顺序逐个 `git cherry-pick <sha>`
- [ ] 冲突仅解决"上下文位移"，**不引入新逻辑**
- [ ] 每次 pick 后 `git diff upstream/main -- '*zh-Hans*'`：
  - PR-A / PR-B：必须为空
  - PR-C：必须仅出现在 `apps/docs/`
- [ ] 每次 pick 后 grep 默认 locale，确认未被改动
- [ ] `rg -i "vivo|蓝厂|岩冰"` 在 diff 中无命中
- [ ] commit message 保留原作者 `Co-authored-by`

### 6.3 清理 vivo 残留

- [ ] 删除 `zh-Hans` 改动（仅 PR-A / PR-B 适用）
- [ ] 删除任何"默认 locale 切换"的 commit / 改动
- [ ] 删除 vivo 私有业务 key
- [ ] 删除 vivo 内部测试 fixture / 截图

### 6.4 质量门禁（W6 配合）

- [ ] `pnpm lint` / `pnpm typecheck` 全绿
- [ ] `pnpm test` 全绿（含 `parity.test.ts`）
- [ ] `pnpm test:e2e` 全绿（至少 Chromium）
- [ ] 构建产物 size 与 `upstream/main` 差值在预算内
- [ ] 本地手测：英文渲染与 `upstream/main` 视觉一致（PR-A / PR-B）

### 6.5 PR 元信息

- [ ] 标题符合 conventional commits（见 §5.1）
- [ ] 描述按 §5.2 / 5.3 / 5.4 模板填全
- [ ] 关联 upstream issue（PR-B 必须；PR-A / PR-C 可选）
- [ ] 标注 reviewer（CODEOWNERS / 活跃 maintainer）
- [ ] **未推送**：等 W0 拍板时机

### 6.6 推送（仅 W0 批准后）

- [ ] `git push origin i18n/upstream-pr-X`（vivo 远端，**不是** upstream）
- [ ] GitHub UI：从 `YanBing03/multica:i18n/upstream-pr-X` 向 `multica-ai/multica:main` 发起 PR
- [ ] 草稿态先发，CI 跑过再 mark ready

---

## 7. 风险与回滚

| 风险                                | 缓解                                                        |
| ----------------------------------- | ----------------------------------------------------------- |
| PR-A 数量太多让 maintainer 疲劳     | 按 namespace 分批，每批 ≤ 30 key                            |
| PR-B 上游不接受框架选型             | 先开 issue 探口风，附 3 候选对比                            |
| PR-C 翻译质量被打回                 | conventions.zh.mdx 自检 + 内部 W7 走查后再发                |
| 上游 review 周期长，vivo 已发版     | vivo 不阻塞，继续 fork；上游 merge 后 rebase                |
| cherry-pick 后 vivo 文案丢失        | `vivo-i18n-zh` 不动；`i18n/upstream-pr-X` 是只读副本        |
| 上游 merge 后 vivo rebase 冲突      | 见 `docs/ops/UPSTREAM_REBASE.md`                            |
| W4 / W5 / W6 输入未到位就启动 PR    | 触发条件硬卡（§3.1 / 3.2 / 3.3 各自的 trigger condition）   |

---

_维护人：W7。每次 cherry-pick 后追加经验到 §7。_
