# WP-5 · Server-side i18n 现状盘点

> **作者**：W5（后端窗）
> **日期**：Day 0 22:30
> **分支**：`feat/vivo-server-i18n`
> **范围**：`server/` 全目录
> **目的**：判定上游是否已做 server-side i18n；若未做，输出补缺方案与优先级排序。

---

## 0. TL;DR

**上游 v0.3.5 完全没有做 server-side i18n。** 所有面向用户的服务端字符串（邮件正文 / HTTP 错误 message / CLI 输出）均为英文硬编码，且没有引入任何 i18n 框架（无 `go-i18n`、无 `Localizer`、无翻译表）。

唯一与 i18n 有关的服务端代码是 `auth.go:46` 的 `supportedLanguages` 白名单，但其作用仅限于：**校验前端传来的 `language` 字段并原样回写**，给前端 i18next 切语言用。**服务端从不读取该字段做响应分支**（`grep "u.Language" server/` 唯一命中点是回写 `UserResponse`，参见 §2.4）。

**结论**：vivo 走分支 ②（上游未做），需要：
1. 邮件中文化（最优先，用户直接可见）
2. HTTP 错误 message 中文化（次优先，前端目前直接展示）
3. 设计 server-side i18n 框架并向上游 PR（长期，由 W7 接手 PR-B）
4. CLI 输出 / log（最低优先，自托管运维场景，先不动）

---

## 1. 检查清单

| 项 | 上游是否 i18n | 文件 / 证据 | vivo 优先级 |
|---|---|---|---|
| a. 邮件主题 + 正文 | ❌ 否，2 模板全英文硬编码 | `server/internal/service/email.go:171-242` | **P0** |
| b. HTTP 错误 message | ❌ 否，825 处 `writeError(w, status, "english msg")` | `server/internal/handler/*.go` 全部 | **P1** |
| c. 业务错误（SignupError 等） | ❌ 否，message 直接英文 | `server/internal/handler/auth.go:37-38` | P1（并入 b） |
| d. CLI 输出 | ❌ 否，`fmt.Print*` × 85 处 + `cli.PrintTable` 表头英文 | `server/cmd/multica/`、`server/internal/cli/output.go` | P3（自托管运维） |
| e. server log（slog） | ❌ 否，结构化 key 英文（合理，不应翻译） | `server/internal/logger/logger.go` | **不翻译**（运维语义） |
| f. user.Language 字段是否驱动服务端响应 | ❌ 否，仅前端用 | `server/internal/handler/auth.go:42-49, 86` | — |
| g. 是否有 i18n 框架/翻译表 | ❌ 无 | `grep -rn 'go-i18n\|Localizer\|nicksnyder' server/` 0 命中 | — |
| h. 重置密码邮件 | — 不存在 | 登录走验证码（passwordless），无密码体系 | — |

---

## 2. 详细盘点

### 2.1 邮件模板（P0）

文件：`server/internal/service/email.go`

**模板 1：验证码邮件**（`SendVerificationCode`，line 171）
- Subject：`"Your Multica verification code"`
- Body（HTML，inline）：
  - `<h2>Your verification code</h2>`
  - `<p>This code expires in 10 minutes.</p>`
  - `<p>If you didn't request this code, you can safely ignore this email.</p>`
- DEV 兜底打印：`fmt.Printf("[DEV] Verification code for %s: %s\n", to, code)`

**模板 2：邀请邮件**（`SendInvitationEmail` / `buildInvitationParams`，line 199 / 222）
- Subject：`"%s invited you to %s on Multica"`（含品牌词 Multica，按术语保留）
- Body：
  - `<h2>You're invited to join %s</h2>`
  - `<p><strong>%s</strong> invited you to collaborate in the <strong>%s</strong> workspace on Multica.</p>`
  - `<a>Accept invitation</a>`
  - `<p>You'll need to log in to accept or decline the invitation.</p>`
- DEV 兜底：`fmt.Printf("[DEV] Invitation email to %s: ...")`

**模板 3：重置密码邮件 — 不存在**
- 上游登录链路是 verification-code passwordless（见 `auth.go` SendCode/VerifyCode），无密码、无找回流程，**无需 i18n**。

**EmailService 启动日志（运维向，可中可英）**
```go
fmt.Printf("EmailService: SMTP relay %s:%s from=%s\n", ...)        // L58
fmt.Printf("EmailService: Resend API from=%s\n", from)             // L60
fmt.Println("EmailService: DEV mode — codes printed to stdout ...") // L62
```
建议保留英文（运维 / startup log 受众非终端用户）。

### 2.2 HTTP 错误 message（P1）

**统一出口**：`server/internal/handler/handler.go:163`
```go
func writeError(w http.ResponseWriter, status int, msg string) {
    writeJSON(w, status, map[string]string{"error": msg})
}
```
- 响应 JSON 形如 `{"error":"<english>"}`，**没有 error code 字段**，前端无法按 code 映射，目前直接渲染 `error`。
- 共 **825 处** `writeError` 调用，分布：

| 文件 | 调用数 |
|---|---|
| `autopilot.go` | 62 |
| `issue.go` | 54 |
| `daemon.go` | 47 |
| `workspace.go` | 46 |
| `auth.go` | 43 |
| `onboarding.go` | 40 |
| `chat.go` | 39 |
| `agent.go` | 38 |
| `skill.go` | 37 |
| `invitation.go` | 35 |
| `squad.go` | 34 |
| `comment.go` | 31 |
| 其余 18 文件 | 319 |

**典型字符串样本**（`runtime_update.go`）：
- `"runtime not found"`
- `"invalid request body"`
- `"target_version is required"`
- `"failed to load update: " + err.Error()`
- `"insufficient permissions"`
- `"runtime is offline"`

**业务错误**（`auth.go:37-38`）：
```go
var ErrSignupProhibited = SignupError{Message: "user registration is disabled on this self-hosted instance"}
var ErrEmailNotAllowed   = SignupError{Message: "email address or domain not allowed on this instance"}
```

**Webhook 错误**（`autopilot_webhook.go:336-341`）：
- `404 {"error":"webhook not found"}`
- `413 {"error":"payload too large"}`
- `429 {"error":"rate limit exceeded"}`
- `500 {"error":"failed to dispatch autopilot"}`

### 2.3 CLI 输出（P3）

- `server/cmd/multica/*.go` 中 `fmt.Print*` 调用 ~85 处
- `server/internal/cli/output.go` 提供 `PrintTable(headers, rows)` / `PrintJSON`，表头由调用方传入英文（如 workspace list 的 `ID / NAME / SLUG / ROLE`）
- 受众：**自托管运维 + 高级用户**，按 conventions.zh.mdx 惯例可保留英文。**vivo 此阶段不动**。

### 2.4 user.Language 字段（不驱动服务端响应，仅供前端）

`server/internal/handler/auth.go`：
```go
// L42-49
var supportedLanguages = map[string]struct{}{
    "en":      {},
    "zh-Hans": {},
}
// L86
Language: textToPtr(u.Language),  // 唯一读点：原样回显给 GetMe
```
全仓库 `grep "u.Language\|user.Language\|Accept-Language"` 仅 1 命中，即上方回显。**没有任何 handler 根据用户语言切换响应内容**。

### 2.5 logger（slog）— 不翻译

`server/internal/logger/logger.go` 用 `tint` + `slog`，结构化日志的 message 与 key 都是 ASCII。属于运维 telemetry，**不在 i18n 范围**。

---

## 3. 优先级与方案

### P0：邮件中文化（Day 1-2，无依赖）

**分支处理**：上游未做 → 走「设计 + 实现 + 提案上游 PR-B」路线。

**vivo fork 立刻落地**（不等上游）：
- 改造 `email.go` 为「locale → 模板」映射结构（最小侵入版：函数内部按 locale 分支返回 subject/body）。
- locale 来源优先级：① 收件人 `user.language` → ② `MULTICA_DEFAULT_LOCALE` env（vivo 设 `zh-Hans`） → ③ `en` 兜底。
  - **注意**：邀请邮件收件人可能尚未注册（无 user 行），此时直接走 env / 兜底。
- 模板使用 `text/template` 抽出，便于上游 PR 时迁移到独立文件 + 多 locale 目录。
- 品牌词 `Multica` 不译；按 `conventions.zh.mdx` §3 用直引号、三点省略号（`…` 已存在于 `sanitizeSubjectField` 截断逻辑，OK）。

**预期改动**：
- `server/internal/service/email.go`：增 `locale` 形参与模板分支；测试增 zh-Hans 用例
- `server/internal/service/email_test.go`：扩展 `buildInvitationParams` 测试覆盖 zh-Hans
- 新增 env `MULTICA_DEFAULT_LOCALE`，在 `.env.example` 文档化

**翻译草稿（待 W4 走查）**：
| 字段 | en（上游） | zh-Hans（vivo 草稿） |
|---|---|---|
| 验证码 Subject | `Your Multica verification code` | `你的 Multica 验证码` |
| 验证码 H2 | `Your verification code` | `你的验证码` |
| 验证码 expires | `This code expires in 10 minutes.` | `验证码 10 分钟内有效。` |
| 验证码 ignore hint | `If you didn't request this code, you can safely ignore this email.` | `如果不是你本人申请，可忽略此邮件。` |
| 邀请 Subject | `%s invited you to %s on Multica` | `%s 邀请你加入 Multica 工作区 %s` |
| 邀请 H2 | `You're invited to join %s` | `邀请你加入 %s` |
| 邀请正文 | `%s invited you to collaborate in the %s workspace on Multica.` | `%s 邀请你加入 Multica 工作区 %s 协作。` |
| 邀请按钮 | `Accept invitation` | `接受邀请` |
| 邀请底注 | `You'll need to log in to accept or decline the invitation.` | `登录后可接受或拒绝该邀请。` |

> 术语对齐 conventions.zh.mdx：workspace = 工作区（已确认）。

### P1：HTTP 错误 message 中文化（Day 3-5，需框架）

**问题**：825 处 `writeError(w, status, "...")` 直接传英文 string，没有 error code，前端只能照搬展示。

**vivo fork 短期方案（妥协版，不动 825 个调用点）**：
- 在 `writeError` 内部加最小拦截：维护一个 `messageZH map[string]string`（en → zh），命中即替换；未命中保留英文。
- locale 取自请求 context（中间件从 `Authorization` 解出 user → load user.language；未登录请求看 `Accept-Language` header；兜底 env `MULTICA_DEFAULT_LOCALE`）。
- 翻译表分批补：先覆盖高频 50 条（`not found / invalid request body / insufficient permissions / unauthorized / forbidden / rate limit exceeded / internal server error / xxx is required` 等），覆盖率即可达 ~60%。

**长期方案（上游 PR-B 由 W7 推）**：
- 引入轻量框架（推荐 `golang.org/x/text/message` 或自研 `errcode` 包），把 `writeError` 升级为 `writeError(w, status, errcode.NotFound, args...)`，前端按 code 映射并自带 fallback。
- 改造 825 处调用点（机械替换 + 测试），属重构，不在 vivo D 0-7 窗口内。

**vivo 阶段交付**（PR-B 之前）：拦截层 + 50 条高频翻译表，足以让 zh-Hans 用户看到 ~60% 中文错误。

### P2：业务错误结构化（合并到 P1）

`SignupError` / `duplicateIssueMessage` 等少量自定义错误统一并入 P1 的翻译表。

### P3：CLI / 启动日志（不做）

按 conventions.zh.mdx 与 vivo 共识，运维向输出保留英文。仅在 W4 走查发现明显面向终端用户的 CLI 信息时再补翻译表。

---

## 4. 与其他窗口的依赖

| 依赖项 | 来源 | 阻塞我方 | 阻塞他方 |
|---|---|---|---|
| 翻译走查 | W4 | 邮件文案 / 错误 message 中文需 W4 过审 | — |
| 上游 PR-B 战略 | W7 | — | W7 PR-B 等本审计文 + P1 拦截层落地后才能基于事实写 PR |
| 邮件视觉走查 | W6（原 W6 测试） | — | 我方提供 zh-Hans 渲染示例邮件（截图或 .eml） |
| 单机部署联调 | W1 | 等 W1 部署完后联调真实邮件渲染 | — |

---

## 5. 落地里程碑

| Day | 交付 | 状态 |
|---|---|---|
| Day 0 | 本审计文档 + 分支 `feat/vivo-server-i18n` 创建 | ✅ |
| Day 1 | 邮件 i18n 改造（email.go locale 分支 + zh-Hans 模板） + 单测通过 | ⏳ |
| Day 2 | 邮件 PR 草稿（vivo fork 内部）+ 翻译草案给 W4 走查 | ⏳ |
| Day 3 | HTTP error 拦截层 + 50 条高频翻译表 + 单测 | ⏳ |
| Day 4 | error 翻译表扩到 ~150 条 + W1 联调真实邮件 | ⏳ |
| Day 5 | 把上述方案抽象为「向上游 PR-B」提案文档，交付 W7 | ⏳ |

---

## 6. 风险

1. **拦截层翻译靠字符串字面量匹配**，上游若改一个标点就会失配。缓解：用 `strings.TrimSuffix(msg, ":"+errDetail)` 切掉拼接 err.Error() 的尾巴；翻译表只维护「前缀」键。
2. **未登录请求拿不到 user.language**：必须支持 `Accept-Language` header（前端 fetch 时主动带），否则登录页 / 邀请落地页错误仍是英文。需要前端 W3a 配合（注入默认 header）。
3. **邀请邮件收件人未注册**：locale 取自 inviter 的 `user.language` 还是 env？决议：取 inviter 的 language，理由是邀请人和被邀人通常同语种同公司。
4. **825 处 writeError 中含 `err.Error()` 拼接**（如 `"failed to load update: "+err.Error()`），底层 err 来自 pgx / 第三方 SDK，无法翻译。决议：拦截层只翻译固定前缀，err 详情保留英文（运维可读）。
