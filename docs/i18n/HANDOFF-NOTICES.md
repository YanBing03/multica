# 转向通知模板（W0 → 各窗）

> Day 0 22:00 · W0 主窗发出
> 用法：从 7 个段落里复制对应一段，粘贴到每个子窗对话框首条。
> 各窗看完先回一句「收到 + 接单 / 异议」给 W0。

---

## 全局公共抬头（每段都已包含，不用重复粘贴）

```
[W0 转向通知 · Day 0 22:00]

⚠️ 重大背景修订：核查仓库现状后发现 v0.3.5 上游已自带：
  - i18next + react-i18next 完整框架
  - packages/views/locales/zh-Hans/ 24 个 namespace × 6558 行高质量翻译
  - apps/docs/content/docs/developers/conventions.zh.mdx 302 行权威术语规范
  - parity.test.ts 翻译完整性测试

原 9 窗作战核心假设崩，W0 已废 D-001~D-003，新发 D-007~D-011。

仓库：vivo fork = https://github.com/YanBing03/multica
分支：vivo-i18n-zh（W0 主写，含 Day 0 决议两个 commit）

请先把 vivo fork 拉到本地：
  git clone https://github.com/YanBing03/multica.git
  cd multica
  git checkout vivo-i18n-zh

然后看：
  docs/i18n/STATUS.md      ← 主面板，找到你的段落
  docs/i18n/W0-DECISIONS.md ← D-007~D-011 详版
  apps/docs/content/docs/developers/conventions.zh.mdx ← 术语唯一权威
```

---

## W1 · 部署窗（任务不变）

```
你的任务【未变】：WP-1 单机自部署跑通 v0.3.5。

继续按原 prompt 执行（部署 / .env / make selfhost / multica setup / 验证码看 docker logs）。

只需注意一点：
  本地工作目录如果用过别人的产出（race 期），先用 vivo fork 的 vivo-i18n-zh 分支
  做 baseline，不要在 main / detached HEAD 上跑。

新建分支 → feat/vivo-selfhost-zh-bootstrap

完成后在 docs/i18n/STATUS.md §2 「W1 · 部署」段落追加 Day N 进度。
不允许在仓库根目录写 STATUS.md（D-004）。
```

---

## W2 · i18n 框架窗 · 解散通知 ⛔

```
你的窗【已解散】。

原因：上游 v0.3.5 已用 i18next + react-i18next 全栈接入：
  - packages/core/i18n/{create-i18n.ts, provider.tsx, pick-locale.ts, ...}
  - packages/views/i18n/use-t.ts
  - packages/views/locales/{en,zh-Hans}/ 24 ns

D-007 锁定 i18next 为 vivo fork 的 i18n 框架，禁止引入 next-intl。
你不需要做任何「框架接入」工作。

下一步二选一：
  A. 加入 W3a 协助 WP-2（默认 locale 切 zh-Hans）+ WP-4（漏网英文扫描）
  B. 加入 W4 协助 WP-3（zh-Hans 质量审计）

请回 W0 选 A 或 B。
```

---

## W3a · 默认 locale + 漏网扫描（apps/web）

```
你的任务【大幅缩小且重定位】。原「字符串抽离 → t('key')」整批已废
（上游 80%+ 已抽离）。

新任务两件：

【WP-2】把默认 locale 切到 zh-Hans
  - 先读 packages/core/i18n/pick-locale.ts 看上游怎么决定默认 locale
  - 再看 apps/web/middleware.ts（若存在）
  - 改动应为 1-2 行级别（修改默认 fallback / cookie 兜底）
  - ⚠️ 不要删 settings 页的语言切换器（D-008）
  - 分支：feat/vivo-zh-default-locale

【WP-4】apps/web 漏网英文扫描
  - 命令样例：
      rg -nP '"[A-Z][a-z]+( [A-Z]?[a-z]+){0,4}[\.\?\!]?"' apps/web/src --type tsx --type ts \
        | grep -v 'i18n\|test\|//\|^\s*\*'
  - 人工筛漏网项 → 抽 key 加到 packages/views/locales/{en,zh-Hans}/<ns>.json
  - 翻译规则严格按 conventions.zh.mdx §2 §3
  - 分支：fix/vivo-zh-leftover-en-web

每天 18:00 在 STATUS.md §2「W3a」段落追加进度。
共享文件改动前先到 CLAIMS.md 认领。
```

---

## W3b · 漏网扫描（packages/views & 其他）

```
你的任务【大幅缩小且重定位】。原「UI 改造 B」整批已废。

新任务【WP-4】：在 packages/views/ packages/ui/ packages/core/ 扫漏网英文。

⚠️ 重要：packages/views/locales/ 已是翻译源文件，不要碰它。
  扫的是组件代码（.tsx / .ts）里残留的英文 string literal。

工具同 W3a。与 W3a 分目录跑：
  - W3a 跑 apps/web/
  - W3b 跑 packages/

翻译规则严格按 conventions.zh.mdx。
分支：fix/vivo-zh-leftover-en-views

每天 18:00 在 STATUS.md §2「W3b」段落追加进度。
```

---

## W4 · 翻译质量审计（重定位，自称 W6）

```
你的任务【全面重定位】。

原任务「从零写 zh-CN.json + LLM_PROMPT + TRANSLATION_NOTES」已废
（上游已有 zh-Hans 6558 行高质量翻译）。

新主战场两件：

【WP-3】zh-Hans 质量全量审计
  1. 跑 pnpm test --filter views parity.test.ts 确认 en/zh-Hans key 集合一致
  2. 写 lint 脚本扫 packages/views/locales/zh-Hans/*.json 的违规：
     - 含 `…`（应为 `...`）
     - 含全角弯引号 `""''`（应为直引号）
     - 含「您」（应为「你」，按 conventions §3 待 W0 确认）
     - 中英之间无空格
  3. 抽 10% 样本（约 600 行）人工对照 conventions.zh.mdx §2 概念词表
  4. 产出 docs/i18n/WP-3-AUDIT-REPORT.md
  5. 起手已有 W0 抽样：docs/i18n/ZH-HANS-AUDIT.md（结论：质量极高，可作 baseline）

【WP-6】apps/docs zh 文档站盘点
  - 列 apps/docs/content/docs/**/*.mdx 哪些已有 .zh.mdx、哪些没有
  - 输出 docs/i18n/WP-6-DOCS-COVERAGE.md

旧产出处理：
  - docs/i18n/TERMS.md v1：保留但降级。Day 1 必须改写：
      删除 §3-§7 与 conventions.zh.mdx 冲突的内容，
      只留 vivo 内部增量词（目前可能为空）
  - docs/i18n/LLM_PROMPT.md / TRANSLATION_NOTES.md：取消产出要求

分支：fix/vivo-zh-translation-quality-<scope>

⚠️ 编号说明：你自称 W6，W0 统一记账为 W4（D-005）。后续 commit / PR 标题用 [W4]。

每天 18:00 在 STATUS.md §2「W4」段落追加进度。
```

---

## W5 · 后端 i18n（任务保留，更聚焦）

```
你的任务【WP-5 后端 i18n 现状盘点 + 补缺】，方向不变。

第一步必做盘点：
  - 检查 server/ 目录下：
      a. 邮件模板是否 i18n？（找 *.tmpl / *.html / 邮件相关代码）
      b. 错误码是否 i18n？（HTTP error response、business error）
      c. server log / cli output 是否 i18n？
  - 输出 docs/i18n/WP-5-SERVER-I18N-AUDIT.md
    含：哪些已 i18n / 哪些没 / 没做的优先级

第二步分支处理：
  - 若上游【未做】 server-side i18n：
      - 设计方案（库选型 / 文案位置 / locale 解析）
      - 实现 + 提案 PR 给上游（W7 协助 cherry-pick）
      - 邮件模板用 zh-Hans（验证码邮件、邀请邮件、重置密码邮件）
  - 若上游【已做】：
      - 跑 zh-Hans 翻译质量审计（同 WP-3 标准）
      - 修复 PR

分支：feat/vivo-server-i18n
每天 18:00 在 STATUS.md §2「W5」段落追加进度。
```

---

## W6 · E2E 测试（任务不变，更聚焦）

```
你的任务【WP-7 E2E 中文回归】，方向不变。

新增聚焦点：
  - 用例覆盖在 locale=zh-Hans 下的核心路径：
      登录 / issues 列表 / agents / settings / runtime / inbox
  - 关键断言：
      a. 无英文残留（漏网英文检测）
      b. 无 conventions §3 违规字符（页面文本不含 `…` / 弯引号 / 「您」）
      c. 中英之间空格正确

工具：playwright（上游应已配置，先看 apps/web/playwright/）

可暂缓启动：等 W3a 的 WP-2 把默认 locale 切到 zh-Hans 后再开始
（否则你要手动切语言才能跑）。

分支：test/vivo-zh-e2e
每天 18:00 在 STATUS.md §2「W6」段落追加进度。
```

---

## W7 · 走查 / 上游 PR（重定位，自称 W-review）

```
你的任务【全面重定位】。

W7 上抛已闭环：
  ✅ D-001 next-intl 与现状冲突 → W0 已撤销，改 D-007 锁 i18next
  ✅ Apache 2.0 无 CLA → 无阻塞
  ✅ 上游 fork URL = https://github.com/YanBing03/multica（岩冰个人 GitHub）

git remote 已重配：
  origin    → github.com/YanBing03/multica.git   (vivo fork)
  upstream  → github.com/multica-ai/multica.git  (只读)

新任务【WP-8】上游 PR 战略重写：

旧已落盘文件 Day 1 必须改写：
  1. docs/i18n/REVIEW_CHECKLIST.md
     - 删「框架与库」段（i18next 已是事实，不需校验）
     - 加「对齐 conventions.zh.mdx §2 §3」段
     - 加「中英空格 / 标点 / 直引号 / 三点省略号」自动 lint 引用
  2. docs/i18n/UPSTREAM_PR.md
     - 3 个 PR 类型重定位：
         PR-A：vivo 发现的 zh-Hans 翻译错误修订（输入：W4 WP-3）
         PR-B：后端 i18n 框架（若上游没做，输入：W5 WP-5）
         PR-C：apps/docs 缺失的 .zh.mdx 补全（输入：W4/W7 WP-6）
     - 删除「引入 i18n 框架」相关 PR-1/2/3 旧战略
  3. docs/i18n/REVIEW_LOG.md：结构保留
  4. docs/ops/UPSTREAM_REBASE.md：保留（remote URL 已由 W0 补完）
  5. scripts/i18n/rebase-upstream.sh：保留

执行 cherry-pick 的触发条件：
  - WP-3 / WP-5 / WP-6 各自有第一批产出后才启动对应 PR

⚠️ 编号说明：你自称 W-review，W0 统一记账为 W7（D-005）。
   后续 commit / PR 标题用 [W7]。

分支：i18n/upstream-pr-<n>（基于 upstream/main，cherry-pick 来）
每天 18:00 在 STATUS.md §2「W7」段落追加进度。
```

---

## W0 自留备忘（不发出）

- Day 1 09:00 巡查清单：
  - [ ] W1 是否已起 docker compose
  - [ ] W2 是否已选 A/B 转岗
  - [ ] W3a/W3b 是否已开始扫漏网
  - [ ] W4 是否已改写 TERMS.md + 跑 parity test
  - [ ] W5 是否已盘点 server/ 邮件
  - [ ] W6 维持等待
  - [ ] W7 是否已改写 REVIEW_CHECKLIST.md
- Day 1 18:00 collect 各窗 STATUS.md 自报
- Day 2 09:00 视进度决定要不要 ping 岩冰汇报

---

# 第二轮转向通知（Day 1 · 11:25 · 强制 worktree 迁移）

> 全部 7 窗共用，1 段通发。原因：Day 1 09:00–11:15 多窗共享 `Multica/` 根目录引发 4 次 race（中途被切分支 / commit 落错分支 2 次），W0 已抢救。

## 全员公告

```
[W0 强制通告 · Day 1 11:25]

🚨 即日起禁止在 /Users/bing/Documents/opencode/Multica/ 下做任何代码改动
   （除 W0 协调文档外）。该目录已固化为 W0 主窗专属（vivo-i18n-zh trunk）。

✅ 已为各窗建好独立 git worktree，物理路径隔离，分支自动绑定，禁止 checkout：

  W1  → /Users/bing/Documents/opencode/multica-w1   (feat/vivo-selfhost-zh-bootstrap)
  W3a → /Users/bing/Documents/opencode/multica-w3a  (feat/vivo-zh-default-locale)
  W3b → /Users/bing/Documents/opencode/multica-w3b  (fix/vivo-zh-leftover-en-views)
  W4  → /Users/bing/Documents/opencode/multica-w4   (fix/vivo-zh-translation-quality-audit)
  W5  → /Users/bing/Documents/opencode/multica-w5   (feat/vivo-server-i18n)
  W6  → /Users/bing/Documents/opencode/multica-w6   (feat/vivo-zh-tests, 新建)
  W7  → /Users/bing/Documents/opencode/multica-w7   (feat/vivo-zh-review, 新建)

强制规则:
  1. 每窗只在自己 worktree 路径下工作, cd 进去后 git status 应直接看到自己分支
  2. 禁止 git checkout 切到别的分支（worktree 已绑定，会报错）
  3. 共享文档（STATUS.md / CLAIMS.md）按 §1 单写规则,只在 W0 主窗写;
     各窗在自己 worktree 改完 push 自己分支后,在群里 @W0 合
  4. pull 上游 trunk: 在 W0 主窗 fetch + merge upstream/main 到 vivo-i18n-zh,
     各窗 git fetch origin && git rebase origin/vivo-i18n-zh

抢救成果（trunk 已 push origin/vivo-i18n-zh @ 71a03abf）:
  - 3b8b1252 [W0 collation] W5 audit + W7 review 第一批
  - 61dd2e0c [W0 collation] W7 UPSTREAM_PR rewrite + STATUS Day1 自报
  - 71a03abf [W0] worktree 启用决议
  - 各窗自交分支: W4 74f9a11b / W3a 5b713dcb / W3b 19072500

请各窗:
  1. 在新 worktree 路径下 git status 自检, 确认绑定的分支正确
  2. 在群里 @W0 回「收到, 已迁移」
  3. 接续原 Day 1 任务书工作（W1 docker / W4 lint / W5 邮件 PR / 等）
```

## W0 自留补丁

- Day 1 11:25 worktree 迁移已完成, 巡查时改为依次 cd 进 7 个 worktree 看 git log/status
- W2（i18n 框架窗）已正式解散（D-010）, 人员去向待 Day 1 09:00 决断（候选: W4 翻译审计 / W7 上游 PR 走查 / W6 测试加固）
- 风险: vivo TERMS.md v1（226 行）与 conventions.zh.mdx 多处冲突, 待 Day 1 W4 改写为「引用 conventions + vivo 增量」
