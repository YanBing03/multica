# Multica i18n Review Checklist

> 用于 W2 / W3a / W3b / W4 / W5 提交的 i18n 相关 PR / commit 走查。
> Reviewer 在 GitHub PR comment 中逐项核对，**不直接改他人代码**，只留 review comment。
> 每条均给出 ✅ / ⚠️ / ❌，未涉及标 N/A。

---

## 0. 前置检查（30 秒筛掉低质量 PR）

- [ ] PR 标题符合 conventional commits（`feat(i18n):` / `refactor(i18n):` / `chore(i18n):`）
- [ ] PR 描述说明了：动机、改动范围、是否影响上游、是否含默认 locale 切换
- [ ] 单 PR 聚焦单一目的（框架接入 / key 抽离 / 翻译填充 不混在一起）
- [ ] commit 历史清晰（无 `wip` / `fix typo` 散弹），必要时要求 squash
- [ ] 关联 issue / 任务 ID 已在描述中给出
- [ ] CI 全绿（lint / typecheck / unit / e2e），W6 已签字

---

## 1. i18n 框架与库使用

> ⚠️ 库选型（D-001）当前与代码现状冲突，已 W7 → W0 上抛（见 STATUS.md §1.W7）。
> 在 W0 二次裁定前，按**仓库现状 = `i18next + react-i18next`**走查，等决议落定后回写本节。

- [ ] 使用项目统一选定的 i18n 库（仓库现状：`i18next + react-i18next`；W0 决议待澄清），未引入第二个
- [ ] 初始化代码集中在统一入口（如 `apps/web/src/i18n/index.ts`），未在多处重复 init
- [ ] locale 来源优先级清晰：URL > cookie > Accept-Language > default
- [ ] **默认 locale 切换（zh-CN）只能出现在 vivo 分支**，上游 PR 必须保持 `en` 为默认
- [ ] SSR / CSR 双端 hydration 一致，未出现服务端英文 / 客户端中文的闪烁
- [ ] 懒加载策略合理（按 namespace / 按路由分包），未把全部 locale 一次性打入主包

---

## 2. Key 命名规范

- [ ] 命名风格统一：`namespace.module.action` 或 `namespace.module.field`，**全小写 + 点分隔**
- [ ] namespace 划分合理（`common` / `auth` / `dashboard` / `errors` …），无 `misc` / `temp` 兜底命名
- [ ] 不出现中文 key、不出现拼音 key（如 `denglu`）、不出现长句 key（如 `please.click.here.to.continue`）
- [ ] 不复用 UI 文案做 key（如 `Click Here`），key 只描述语义
- [ ] 错误消息走 `errors.*` namespace，不与业务 key 混在一起
- [ ] 同义文案已合并（reviewer 用 `rg -i "登录|sign in|login"` 抽查）

---

## 3. 单复数 / 占位符 / 富文本

- [ ] 计数文案使用 i18n 库的 plural 能力（`{count, plural, one {...} other {...}}`），未手写 `if count===1`
- [ ] 占位符使用命名变量（`{userName}`），不使用位置参数（`{0}`）
- [ ] 数字 / 日期 / 货币走 `Intl.NumberFormat` / `Intl.DateTimeFormat`，不硬编码格式
- [ ] 富文本（含 `<a>` / `<b>` / 换行）使用 `<Trans>` 或等价方案，**不拼接字符串**
- [ ] HTML 注入风险：所有插值默认转义，仅在白名单标签使用富文本组件
- [ ] RTL 兼容：未使用 `margin-left/right` 硬编码（如未来支持阿拉伯语）

---

## 4. en.json / zh-CN.json 文件质量

- [ ] JSON 结构两端**完全对齐**（key 集合一致），用 diff 工具或脚本核对
- [ ] 无重复 key、无未使用 key（CI 应有 `i18n-unused` 检查）
- [ ] 无空字符串值、无 `TODO` / `XXX` 占位翻译
- [ ] 中文使用全角标点（，。：；！？），英文使用半角
- [ ] 中文文案无机翻味（reviewer 抽样 5 条人工通读）
- [ ] 文件编码 UTF-8 无 BOM，行尾 LF，结尾换行

---

## 5. 业务逻辑误改检测（高优）

> 重点关注：i18n 改造常被用作"顺手重构"借口，必须严格区分。

- [ ] diff 中**仅**出现：字符串 → `t('key')` 替换、import i18n、新增 locale 文件
- [ ] 未修改组件 props / state / 副作用（useEffect 依赖未动）
- [ ] 未修改路由 / 接口 / store action
- [ ] 未"顺便"修复其他 bug（应单独 PR）
- [ ] 未修改 className / 样式（i18n PR 不该改 UI）
- [ ] 条件渲染逻辑未变（`{cond && 'foo'}` → `{cond && t('foo')}` 而非 `{t(cond ? 'a' : 'b')}` 隐式合并）
- [ ] 表单校验逻辑未变（仅替换错误提示文案）

---

## 6. 复用与一致性

- [ ] 同义文案合并（reviewer 用脚本扫 `t('...')` 调用，按 value 反查冲突）
- [ ] 通用按钮（确认 / 取消 / 删除）走 `common.action.*`，未在各模块重复定义
- [ ] 错误码映射集中（`errors.<code>`），不在调用方拼字符串
- [ ] 不使用动态 key（`` t(`errors.${code}`) ``）除非已加到 i18n-extract 白名单

---

## 7. 测试与可观测性

- [ ] 关键 UI 至少一个 locale 的快照测试（en 必测）
- [ ] 单复数 / 富文本组件有单元测试
- [ ] missing key 处理策略明确（dev 抛错 / prod fallback en），有日志上报
- [ ] e2e 切 locale 流程已覆盖（W6 负责确认）

---

## 8. 上游兼容性（cherry-pick 视角）

> 走查时即标注是否可进上游，方便后续拆 PR。

- [ ] 标签 `[upstream-ok]`：纯框架 / en.json / 工具脚本 → 可 cherry-pick 给上游
- [ ] 标签 `[vivo-only]`：zh-CN.json / 默认 locale=zh-CN / vivo 业务文案 → 留 vivo
- [ ] 标签 `[mixed]`：需要 reviewer 拆分，回退要求作者拆 commit
- [ ] 上游可接受的 commit 不依赖 vivo-only 改动（无隐式耦合）

---

## Reviewer 操作模板

```
## Review 结论
**状态**: ✅ Approve / ⚠️ Request changes / ❌ Reject
**上游标签**: [upstream-ok] / [vivo-only] / [mixed]

### 阻塞项
1. ...

### 建议项
1. ...

### 上游拆分备注
- 可 cherry-pick 的 commit: <sha1>, <sha2>
- 必须留 vivo 的 commit: <sha3>
```

---

_最后更新：见 git 历史。维护人：i18n reviewer（W-review）。_
