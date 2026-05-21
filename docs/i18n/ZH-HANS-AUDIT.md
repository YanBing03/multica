# zh-Hans 现状质量抽样报告（W0 Day 0）

> **目的**：在 9 窗大规模动手前先证伪/证实假设——v0.3.5 上游 zh-Hans 已经能用。
> **结论先行**：✅ **质量极高，可直接作 baseline**。vivo 几乎不需要做翻译重做，只需做漏网/后端/E2E。
> **责任**：W0 抽样验证 → W4 接手做 24 namespace 全面审计（WP-3）。

---

## 1. 范围

- 抽样 6 个 namespace：`common` / `auth` / `issues` / `agents` / `settings` / `runtimes`
- 每个 ns 抽前 20-25 行翻译
- 对照 `apps/docs/content/docs/developers/conventions.zh.mdx`

## 2. 抽样发现

### ✅ 已遵守的规则（一致命中）

| 规则（conventions §x） | 抽样证据 |
|---|---|
| §2 实体词不翻 `issue` | `issues.json` "还没有 issue"、"创建一个 issue 开始使用。"、"无法加载 issue" 全部使用 |
| §2 实体词不翻 `task` | `agents.json` "能领取 issue、留下评论、推进状态的 AI 队友"（task 在长文段）✅ |
| §2 概念词必译 Workspace | `issues.json` "工作区" |
| §2 概念词必译 Agent | `agents.json` "智能体"、"新建智能体"、"搜索智能体" |
| §2 概念词必译 Runtime | `runtimes.json` "运行时"、"为智能体跑 CLI 会话的机器和云端 worker" |
| §2 状态名不翻（schema 标识） | `issues.json` 状态值的 i18n key 用英文（`backlog`/`todo`/...）但展示文案为中文 → 这是 UI 层 label，独立 key 翻成中文是允许的（schema-level 标识符指 API/DB，不是 UI label） |
| §2 缩写不翻 CLI / API / OAuth | `auth.json` "授权 CLI"、"允许 CLI 以..." |
| §2 复数中文只填 `_other` | `agents.json` "{{visible}} / {{total}}"、`issues.json` 各处计数 ✅ |
| §3 直引号 `"..."` 不用弯引号 | `runtimes.json` `"没有运行时匹配 \"{{query}}\""` ✅ |
| §3 省略号用 `...` 三点 | `agents.json` "搜索智能体..."、"加载中..." ✅ |
| §3 中英之间空格 | `auth.json` "登录 Multica"、"使用 Google 登录" ✅ |
| §3 风格简洁直白 | "已发送验证码至 {{email}}"（不是"我们已经把验证码发到了你的邮箱"）✅ |
| §3 按钮 2-4 字 | "保存"/"取消"/"删除"/"确认"/"重试"/"继续"/"授权" ✅ |
| §3 错误信息温和 | "无法加载智能体列表"（不是"加载智能体列表失败！"）✅ |

### ⚠️ 待 W4 全量审计后再判定的项

| 项 | 风险 | 处置 |
|---|---|---|
| `issues.json` `breadcrumb_title` = "issue"（小写英文） | conventions §2 表格里 doc 标题位允许"首字母大写英文 **或** 中文术语"——这里是面包屑标题，规则未明确 | W4 询问上游或保守改为 `Issue`/"issue 列表"； |
| 全角句号 vs 半角 | 抽样中均用全角 `。`，符合 §3 但需全量验证有无遗漏 | W4 全量 lint |
| 终止符 `…` vs `...` | conventions §3 强制 `...` 三点，抽样中确为 `...` ✅ | 维持 |
| `runtimes.json` "75 秒以内"（中英数字） | 数字与单位间空格规则——抽样为"75 秒"（无空格），与上游 docs.zh 文风一致；vivo TERMS v1 主张"5 分钟"（有空格），但**应弃 vivo TERMS** | 接受现状 |
| `agents.json` "AI 队友" | 拟人化措辞；vivo TERMS 风格段建议"平视专业"；但上游已选拟人化，统一接受 | 维持 |

### ❌ 暂未发现的违规

抽样 6 ns × 20 行未发现明显违规。

## 3. 数量基线

```
24 namespace × 平均 ~273 行 = 6558 行 zh-Hans
（en 同体量）
```

## 4. 给 W4 的全量审计建议

1. 用 `pnpm test --filter views parity.test.ts` 先跑 parity test，确认 24 ns 的 key 集合 en/zh-Hans 一致
2. 写一个简易 lint 脚本扫所有 `zh-Hans/*.json` 的 string 值：
   - 含 `…`（应为 `...`）
   - 含全角弯引号 `""''`（应为直引号）
   - 含 `您`（应为 `你`，需上游确认；conventions 未明确）
   - 中英之间无空格（regex `[\u4e00-\u9fa5][a-zA-Z]` 或反向）
3. 抽 10% 样本（约 600 行）人工对照 conventions §2 概念词表
4. 输出 `WP-3-AUDIT-REPORT.md`，列：
   - 总扫描行数 / 命中违规数 / 违规清单（含文件:行号 + 建议修订）
   - 按 conventions §x 编号归类
5. 与 W7 走查协调：每条修订 PR 走 `fix/vivo-zh-translation-quality-<scope>` 分支，W7 按 conventions 当 review checklist

## 5. 给 W0 的下一步建议

- ✅ 关闭 D-001/D-002/D-003（已在 W0-DECISIONS.md v2 完成）
- ✅ 解散 W2（D-007）
- ✅ 把"翻译质量"明确为 W4 主战场（D-010 WP-3）
- ⏳ 等 W1 单机部署起来，验证 zh-Hans 在产品里**视觉**层面是否真到位
- ⏳ 等 W5 盘点后端 i18n 现状

---

**报告生成**：W0 · Day 0 · 22:00
**抽样工具**：bash + 人工 diff
**置信度**：中（仅 6/24 ns × 20 行抽样；W4 全量审计后可升为高）
