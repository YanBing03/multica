# Multica i18n → 上游 PR 策略

> 目标：把 vivo i18n 工作中**通用价值高、无 vivo 特殊性**的部分回馈给上游 `multica-ai/multica`，
> vivo 自有部分（zh-CN 翻译、默认 locale=zh-CN、vivo 业务文案）留在 fork。
> 本文是 cherry-pick 与 PR 提交的操作手册，**未经 W0 拍板不得真实推送**。

---

## 1. 战略原则

| 内容                                         | 去向       | 理由                              |
| -------------------------------------------- | ---------- | --------------------------------- |
| i18n 框架接入（库选型、init、Provider、hook） | ✅ 上游    | 通用基础设施，所有 fork 都受益    |
| 字符串抽离 → `t('key')` 改造                 | ✅ 上游    | 通用，且降低后续 vivo rebase 成本 |
| `locales/en.json`（英文兜底）                | ✅ 上游    | 上游母语，必须随框架一起进        |
| i18n 工具脚本（提取 / unused / 校验）        | ✅ 上游    | 维护性收益给所有人                |
| 文档：i18n 贡献指南、key 规范                | ✅ 上游    | 让上游社区按统一规范贡献翻译      |
| `locales/zh-CN.json`                         | ❌ vivo    | 等上游 i18n 框架 merge 后再单独 PR 或留 vivo |
| 默认 locale 切换为 `zh-CN`                   | ❌ vivo    | vivo 产品诉求，上游应保持 `en`    |
| vivo 业务专属文案（品牌词、合规话术）        | ❌ vivo    | 上游无意义                        |
| W6 e2e 中 vivo 私有用例                      | ❌ vivo    | 上游不需要                        |

---

## 2. 分支模型

```
upstream/main ──────────────────────────────────────► (multica-ai/multica)
        │
        ├── vivo-i18n-zh   ◄── vivo fork 主分支（含 zh-CN + 默认中文）
        │       │
        │       └── 各 W2/W3a/W3b/W4/W5 feature 分支 PR 合入
        │
        └── i18n/upstream-pr  ◄── cherry-pick 出来的纯净上游 PR 分支
                              （只含 [upstream-ok] commit）
```

- `vivo-i18n-zh`：vivo 内部主线，所有人都往这合
- `i18n/upstream-pr`：从 `upstream/main` 切出，只 cherry-pick 上游可接受的 commit
- 提 PR 时基于 `upstream/main`，head 指 `i18n/upstream-pr`

---

## 3. PR 拆分策略

### 3.1 拆分粒度

按上游可接受的最小逻辑单元拆，建议 **3 个递进 PR**：

| PR 编号 | 标题                                              | 内容                                                   | 依赖    |
| ------- | ------------------------------------------------- | ------------------------------------------------------ | ------- |
| PR-1    | `feat(i18n): introduce i18n framework`            | 库引入、Provider、hook、空 `en.json`、文档             | 无      |
| PR-2    | `refactor(i18n): extract strings to en.json`      | 全量字符串 → `t('key')` 替换，填充 `en.json`           | PR-1    |
| PR-3    | `chore(i18n): add extraction & lint tooling`      | i18n-extract 脚本、unused-key check、CI 集成           | PR-1    |

> ⚠️ 实际是否拆 3 个看上游 maintainer 偏好。先发 PR-1 探口风，**确认上游接受方向后再补 PR-2/3**。

### 3.2 哪些 commit 该 PR / 哪些留 vivo

走查时（见 `REVIEW_CHECKLIST.md` §8）即给每个 commit 打标签：

- `[upstream-ok]`：直接 cherry-pick
- `[vivo-only]`：跳过
- `[mixed]`：要求作者拆 commit；reviewer 不私下改

cherry-pick 候选清单维护在 `docs/i18n/REVIEW_LOG.md` 的「上游候选」段落，每周一更新。

---

## 4. PR 标题 / 描述模板

### 4.1 标题

```
feat(i18n): introduce i18n framework with en locale baseline
```

遵循 conventional commits，scope 固定 `i18n`。

### 4.2 描述模板

````markdown
## Motivation

Multica currently hard-codes user-facing strings in English across the web app
and server-side templates. This blocks non-English deployments and complicates
contributions from non-English communities.

This PR introduces a minimal, opinionated i18n foundation so that future
locales can be added incrementally without touching component logic.

## Design

- Library: `<chosen-lib>` (待 W0 二次裁定 D-001 后填入；候选：`i18next + react-i18next` 现状 / `next-intl`)
- Default locale: `en` (unchanged user-visible behavior)
- Locale resolution order: URL param > cookie `multica.locale` > `Accept-Language` > `en`
- Bundle strategy: per-namespace lazy load, no extra weight on initial paint
- File layout:
  ```
  apps/web/src/i18n/
    index.ts          # init
    provider.tsx      # React provider
    use-t.ts          # hook
  apps/web/locales/
    en.json           # baseline (this PR)
  ```

## What's in / out

✅ In:
- i18n init + Provider + hook
- Baseline `en.json` (extracted from existing strings, no behavior change)
- Tooling: extract script, unused-key check, CI gate
- Docs: `docs/i18n/CONTRIBUTING.md`

❌ Out (intentional, separate concern):
- Additional locale files (zh-CN, ja, …) — to be contributed by community
- Server-side email templates (follow-up PR)
- Default locale switching — kept at `en`

## Migration / Backward compatibility

- **No user-visible change**: rendered strings are byte-identical to `main`.
- Verified by snapshot tests (added in this PR) for top-20 pages.
- No public API change. Component props unchanged.
- Bundle size delta: +X.Xkb gzipped (measured, see CI artifact).

## Testing

- [x] Unit: i18n init, fallback chain, plural rules
- [x] Snapshot: en locale matches pre-i18n output
- [x] e2e: full smoke pass on Chromium / WebKit
- [x] Manual: SSR + CSR no hydration mismatch

## Checklist

- [x] Conventional commit
- [x] CLA signed (link)
- [x] CONTRIBUTING.md followed
- [x] No breaking change
- [x] Docs updated

## Follow-ups (separate PRs)

1. `refactor(i18n): extract remaining server-side strings`
2. `chore(i18n): add extraction tooling`
3. Community-driven locale contributions

cc @<maintainer>
````

---

## 5. Cherry-pick Checklist

每次从 `vivo-i18n-zh` 拣 commit 到 `i18n/upstream-pr` 前，逐项过：

### 5.1 准备

- [ ] `git fetch upstream && git fetch origin`
- [ ] `git checkout -B i18n/upstream-pr upstream/main`
- [ ] 确认 `upstream/main` 是最新（HEAD sha 与 GitHub 网页一致）
- [ ] 已在 `REVIEW_LOG.md` 标记了 `[upstream-ok]` commit 列表

### 5.2 Cherry-pick

- [ ] 按时间顺序逐个 `git cherry-pick <sha>`
- [ ] 冲突仅解决"上下文位移"，**不引入新逻辑**
- [ ] 每次 pick 后 `git diff upstream/main -- '*zh-CN*'` 必须为空
- [ ] 每次 pick 后 grep 默认 locale 设置，确认仍是 `'en'`
- [ ] `rg -i "vivo|蓝厂"` 在 diff 中无命中
- [ ] commit message 保留原作者 `Co-authored-by` 标签

### 5.3 清理 vivo 残留

- [ ] 删除 `locales/zh-CN.json`（若被带入）
- [ ] 删除任何"默认 locale 切换"的 commit / 改动
- [ ] 删除 vivo 私有业务 key
- [ ] 删除 vivo 内部测试 fixture

### 5.4 质量门禁（W6 配合）

- [ ] `pnpm lint` / `pnpm typecheck` 全绿
- [ ] `pnpm test` 全绿
- [ ] `pnpm test:e2e` 全绿（至少 Chromium）
- [ ] 构建产物 size 对比：与 `upstream/main` 差值在预算内
- [ ] 本地手测：`en` 渲染与 `upstream/main` 视觉一致

### 5.5 PR 元信息

- [ ] 已签 CLA（若上游要求）
- [ ] 标题符合 conventional commits
- [ ] 描述按 §4.2 模板填全
- [ ] 关联到 upstream issue（若有）
- [ ] 标注 reviewer：根据 `CODEOWNERS` 或活跃 maintainer
- [ ] **未推送**：等 W0 拍板时机

### 5.6 推送（仅 W0 批准后）

- [ ] `git push origin i18n/upstream-pr`（vivo 远端，不是 upstream）
- [ ] GitHub UI 上从 vivo fork 向 `multica-ai/multica:main` 发起 PR
- [ ] 草稿态先发，CI 跑过后再 mark ready

---

## 6. 风险与回滚

| 风险                              | 缓解                                              |
| --------------------------------- | ------------------------------------------------- |
| 上游不接受 i18n 库选型            | 先发 issue 探口风，附 3 个候选与对比表            |
| 上游要求拆得更细                  | 准备好按 commit 重新拆的脚本（`git rebase -i`）   |
| 上游 review 周期长，vivo 已发版   | vivo 不阻塞，继续走 fork；上游 merge 后再 rebase  |
| cherry-pick 后 vivo 文案丢失      | `vivo-i18n-zh` 不动，`i18n/upstream-pr` 是只读副本|
| 上游接受后再次 rebase 冲突        | 见 `docs/ops/UPSTREAM_REBASE.md`                  |

---

_维护人：W-review。每次 cherry-pick 后追加经验到 §6。_
