# Multica i18n Review Checklist

> 适用范围：W3a / W3b（UI 改造）、W4（翻译）、W5（后端 i18n）、W6（漏网检测）提交的 i18n 相关 PR / commit。
> Reviewer = W7。**不直接改他人代码**，所有问题以 GitHub PR comment 形式留痕。
> 每条给出 ✅ / ⚠️ / ❌，未涉及标 N/A。
>
> **唯一权威风格规范**：[`apps/docs/content/docs/developers/conventions.zh.mdx`](../../apps/docs/content/docs/developers/conventions.zh.mdx)。
> 本 checklist 不重复定义术语 / 标点 / 空格规则，**只引用 conventions 并补充走查动作**。
> 库选型已锁 `i18next + react-i18next`（W0 决议 D-007），本文不再校验框架。

---

## 0. 前置（30 秒筛掉低质量 PR）

- [ ] PR 标题符合 conventional commits，scope = `i18n` 或 `locales`，前缀 `[W7]`/`[W4]`/... 标注来源窗
- [ ] PR 描述写明：动机、改动范围、是否影响上游、是否触碰 `zh-Hans` / 默认 locale
- [ ] 单 PR 聚焦单一目的（key 抽离 / 翻译填充 / 框架增强 不混在一起）
- [ ] commit 历史无 `wip` / `fix typo` 散弹，必要时要求 squash
- [ ] CI 全绿（lint / typecheck / `parity.test.ts` / e2e），W6 已签字

---

## 1. 对齐 `conventions.zh.mdx` §2（i18n 翻译术语表）

> 完整规范见 conventions.zh.mdx §2。Reviewer 抽查时按以下动作核对，不重述规则。

### 1.1 实体 vs 概念词

- [ ] **实体词**（`issue` / `skill` / `task`）按混合规则使用：UI 短句 / 状态名小写英文；doc 标题首字母大写或对应中文术语；正文首次出现配括号；API/DB 字段永远小写英文
- [ ] **概念词**全译：`Workspace→工作区`、`Agent→智能体`、`Project→项目`、`Autopilot→自动化`、`Daemon→守护进程`、`Runtime→运行时`、`Inbox→收件箱`、`Member→成员`、`Label→标签`、`Settings→设置`、`Onboarding→上手引导` 等（完整表见 §2「完整翻译 — 概念词」）
- [ ] **品牌名 / 通用缩写**不翻：Multica、GitHub、API、CLI、URL、JWT、WebSocket … （完整表见 §2「不翻」）
- [ ] **角色名 / Issue 状态**保持小写英文：`owner` / `admin` / `member`、`backlog` / `todo` / `in_progress` / `in_review` / `done` / `blocked` / `cancelled`
- [ ] 通用 UI 词与 §2「完整翻译 — 通用 UI 词」表 1 比 1 一致（`登录` / `退出登录` / `创建` / `添加` / `已归档` …）

抽查命令（reviewer 用）：

```bash
# 任何中文 JSON 里出现 "议题" / "工单" / "代理" / "工作空间" / "运行环境" 即为违规
rg -n "议题|工单|代理|工作空间|运行环境|运行时间|自动驾驶|看板" packages/views/locales/zh-Hans

# 翻译过的实体词（Issue/Skill/Task 翻成中文）：UI 短句中应保持小写英文
rg -n '"[^"]*执行任务[^"]*"' packages/views/locales/zh-Hans  # 仅长文档允许，UI 短句拒绝
```

### 1.2 词组组合（中英空格）

- [ ] 英文词（实体 / 品牌 / 缩写）与中文之间**单空格**：`新建 issue`、`分配给智能体`、`停止守护进程`
- [ ] 不允许零空格（`新建issue`）或多空格（`新建  issue`）
- [ ] 标点（中文逗号 / 句号 / 冒号）与英文词紧贴，不再加空格：`配置 runtime，然后...`

### 1.3 复数 / 插值 / Key 命名

- [ ] 计数走 i18next `_one` / `_other`；中文只填 `_other`，**禁止**手写 `if count===1`
- [ ] 计数文案模板：`{{count}} 个 issue` / `{{count}} 位成员` / `{{count}} 条评论` / `{{count}} 个智能体`（完整对照见 §2「复数与计数」）
- [ ] 插值用 `{{var}}` 双括号；中文可调整位置以符合语序
- [ ] Key 命名 3 层嵌套：`feature.component.action`，全小写下划线，namespace = JSON 文件名
- [ ] Web-only / Desktop-only 文案分别放 `web.*` / `desktop.*` 段，不污染共享段（参考 `auth.json`）

### 1.4 词典覆盖兜底

- [ ] 术语表未覆盖的词，按 §3「拿不准的时候去哪查」顺序查：先 `*.zh.mdx`，再 `auth.json` / `editor.json`，再现有组件
- [ ] 仍拿不准 → PR 评论挂 `[W7-CONFIRM]` 抛 W4 / W0，不擅自定译

---

## 2. 对齐 `conventions.zh.mdx` §3（中文风格）

### 2.1 标点（强制 lint）

- [ ] 全角中文标点：`，。：；！？`（不允许半角夹杂）
- [ ] 引号：**直引号 `"..."`**，禁止 `「」` / `『』` / 弯引号 `“…”`
- [ ] 省略号：**三点 `...`**，禁止单字符 `…`
- [ ] 破折号：与英文 source 一致；不擅自从 `--` 改为 `——`

> Reviewer 自动扫描（建议落地为 CI）：
>
> ```bash
> # 直引号检查：在 zh-Hans/*.json 中命中弯引号或 「」 即报错
> rg -n '[「」『』“”]' packages/views/locales/zh-Hans
> # 三点检查：命中 … 即报错
> rg -nF '…' packages/views/locales/zh-Hans
> # 半角标点夹杂中文：粗筛
> rg -nP '[\u4e00-\u9fff],|[\u4e00-\u9fff]\.[^0-9a-zA-Z]|[\u4e00-\u9fff]:|[\u4e00-\u9fff];|[\u4e00-\u9fff]!|[\u4e00-\u9fff]\?' packages/views/locales/zh-Hans
> # 中英之间空格：中文字符直接跟 ASCII 字母（无空格）即可疑
> rg -nP '[\u4e00-\u9fff][A-Za-z]|[A-Za-z][\u4e00-\u9fff]' packages/views/locales/zh-Hans
> ```
>
> 上述命令应该零命中（少量例外如 `2FA`、品牌名拼接需 case-by-case 在 PR 描述说明）。

### 2.2 风格

- [ ] 简洁直白，不出现翻译腔（"对于 X 来说" / "作为 X" / "我们的 X"）
- [ ] 错误信息温和明确：`无法保存修改` 优于 `保存修改失败了！`
- [ ] 按钮动词开头，2-4 字：`取消` / `保存修改` / `立即同步`，禁止 `好的请保存这个修改谢谢`
- [ ] Tooltip 完整短句，不超 20 字
- [ ] Placeholder 示例性提示：`输入 issue 标题...`，不出现 `请输入...`

---

## 3. JSON 文件质量

- [ ] `en/<ns>.json` 与 `zh-Hans/<ns>.json` key 集合**完全对齐**（`packages/views/locales/parity.test.ts` 必须绿）
- [ ] 无重复 key、无未使用 key
- [ ] 无空字符串值，无 `TODO` / `XXX` / `[待译]` / 直接英文兜底
- [ ] 文件 UTF-8 无 BOM，行尾 LF，结尾换行
- [ ] JSON 缩进与既有文件一致（2 空格）

---

## 4. 业务逻辑误改检测（高优）

> i18n 改造常被当作"顺手重构"借口，必须严格区分。

- [ ] diff 中**仅**出现：字符串字面量 → `t('key')` / `<Trans>` 替换、import i18n、新增 / 修改 locale JSON
- [ ] 未改组件 props / state / 副作用（useEffect 依赖未动）
- [ ] 未改路由 / 接口 / store action / WS 事件 handler
- [ ] 未"顺便"修复其他 bug（应单独 PR）
- [ ] 未改 className / 样式 / Tailwind class
- [ ] 条件渲染逻辑保持：`{cond && t('foo')}`，**禁止**合并为 `t(cond ? 'a' : 'b')`
- [ ] 表单校验逻辑未变，仅替换错误提示文案
- [ ] 默认 locale 配置未被乱改（vivo 切 `zh-Hans` 通过环境变量，不在 PR 里硬编码）

---

## 5. 复用与一致性

- [ ] 同义文案合并：通用按钮（确认 / 取消 / 删除 / 保存）走 `common.action.*`，不在各 namespace 重复定义
- [ ] 错误码映射集中（`errors.<code>`），不在调用方拼字符串
- [ ] 不使用动态 key（`` t(`errors.${code}`) ``），除非已加 i18n-extract 白名单
- [ ] 富文本（含 `<a>` / `<b>` / 换行）使用 `<Trans>`，**不拼接字符串**

---

## 6. 测试与可观测性

- [ ] `parity.test.ts` 全绿（key 集合一致）
- [ ] 关键 UI 至少一个 locale 的快照 / e2e（W6 负责确认）
- [ ] missing key 处理策略：dev 抛错 / prod fallback `en`，有日志上报
- [ ] 复数 / 富文本组件有单元测试

---

## 7. 上游兼容性（cherry-pick 视角）

> 走查时即标注是否可进上游，方便 W7 后续拆 PR-A / PR-B / PR-C。详见 `UPSTREAM_PR.md`。

- [ ] `[upstream-A]`：vivo 在 zh-Hans 翻译过程中发现的 **en.json 错误 / 拼写 / 不一致** → 可回上游
- [ ] `[upstream-B]`：**后端 i18n 框架 / 邮件 i18n / 错误码 i18n**（来自 W5），上游若未做即可上
- [ ] `[upstream-C]`：`apps/docs` **缺失的 `.zh.mdx` 补全**（来自 W4 / W7）
- [ ] `[vivo-only]`：默认 locale 切 `zh-Hans` 的环境变量、vivo 业务专属翻译 → 留 vivo
- [ ] `[mixed]`：要求作者拆 commit；reviewer 不私下改

---

## Reviewer 操作模板

```
## Review 结论
**状态**: ✅ Approve / ⚠️ Request changes / ❌ Reject
**上游标签**: [upstream-A] / [upstream-B] / [upstream-C] / [vivo-only] / [mixed]
**conventions 锚点**: §2.x / §3.x（命中 violation 时引用具体小节）

### 阻塞项
1. ...

### 建议项
1. ...

### 上游拆分备注
- 可 cherry-pick: `<sha1>`, `<sha2>` → 计划进 PR-X
- 必须留 vivo: `<sha3>`
```

---

_维护人：W7。每次走查后回填经验。_
