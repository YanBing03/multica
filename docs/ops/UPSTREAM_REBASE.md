# vivo fork ↔ Multica 上游同步 SOP

> 适用范围：vivo fork 主分支 `vivo-i18n-zh` 与上游 `multica-ai/multica:main` 的周度同步。
> 责任人：W-review（执行）+ W0（拍板）+ W6（CI 校验）。
> 节奏：**每周一上午 10:00** 执行；如上游有紧急安全更新临时加跑。

---

## 1. 角色与职责

| 角色      | 职责                                                          |
| --------- | ------------------------------------------------------------- |
| W-review  | 跑 rebase 脚本、解决冲突、提 vivo 内部 PR、写同步报告         |
| W6        | CI 全绿背书，必要时补 e2e 用例                                |
| W0        | 拍板是否合入、决策非平凡冲突的处理方向                        |
| 各 W2-W5  | 收到 @ 后协助解决自己模块产生的冲突                           |

---

## 2. 远端约定

| 名称      | URL                                              | 说明                       |
| --------- | ------------------------------------------------ | -------------------------- |
| `origin`  | `git@github.com:vivo-xxx/multica.git`（待确认）  | vivo fork                  |
| `upstream`| `https://github.com/multica-ai/multica.git`      | 上游只读                   |

首次配置：

```bash
git remote add upstream https://github.com/multica-ai/multica.git
git remote set-url --push upstream DISABLED   # 防止误推上游
```

---

## 3. 周度同步流程

### 3.1 触发

- 周一 09:30 自动 cron / 手动 kick：
  ```bash
  bash scripts/i18n/rebase-upstream.sh
  ```
- 脚本输入（环境变量可覆盖）：

  | 变量              | 默认                              |
  | ----------------- | --------------------------------- |
  | `UPSTREAM_REMOTE` | `upstream`                        |
  | `UPSTREAM_BRANCH` | `main`                            |
  | `ORIGIN_REMOTE`   | `origin`                          |
  | `VIVO_BRANCH`     | `vivo-i18n-zh`                    |
  | `REBASE_BRANCH`   | `rebase/upstream-YYYYMMDD`        |
  | `CREATE_PR`       | `1`（用 `gh` 创 draft PR）        |
  | `DRY_RUN`         | `0`                               |

### 3.2 脚本做什么

1. fetch `upstream` + `origin`
2. 若 `vivo-i18n-zh` 已包含上游全部 commit → 直接退出
3. 切临时分支 `rebase/upstream-YYYYMMDD`，基于 `origin/vivo-i18n-zh`
4. `git rebase upstream/main`
5. 跑本地门禁：`pnpm lint` / `pnpm typecheck` / `pnpm test`
6. 推 `origin`，用 `gh` 创建 vivo 内部 draft PR（`base=vivo-i18n-zh`）
7. 不直接合并

### 3.3 冲突处理

- 脚本退出码 2 = 有冲突。按以下顺序：
  1. `git status` 看冲突文件
  2. **i18n 文件冲突（locales/*.json）**：保留 vivo 文案，对齐上游新增 key
  3. **业务代码冲突**：@ 对应模块负责人（W2/W3a/W3b/W4/W5）协助
  4. **默认 locale 配置冲突**：vivo 必须保持 `zh-CN`，上游若改默认值，**保留 vivo 设定**
  5. 解决后 `git add . && git rebase --continue`
  6. 再次跑脚本（会跳过 fetch 之后的步骤继续）

### 3.4 review 与合入

- W-review 在 vivo 内部 draft PR 中：
  - [ ] 贴上游 changelog 摘要（`git log --oneline upstream/main ^vivo-i18n-zh~`）
  - [ ] 标注高风险 commit
  - [ ] 标注是否触发 vivo i18n key 增减
- W6 验证 CI 全绿后 mark ready
- W0 review 通过后，由 W-review 执行：
  ```bash
  git checkout vivo-i18n-zh
  git merge --ff-only rebase/upstream-YYYYMMDD
  git push origin vivo-i18n-zh
  ```
- merge 后删除临时分支：
  ```bash
  git push origin --delete rebase/upstream-YYYYMMDD
  ```

---

## 4. rebase vs merge 选型

**统一用 rebase**，理由：

- vivo 自有 commit 量级可控（<200），rebase 历史更干净
- 后续把 vivo 改动推上游时（见 `docs/i18n/UPSTREAM_PR.md`），线性历史更利于 cherry-pick
- 例外：若上游单次更新极大（>50 commit）且冲突密集 → 临时改用 `merge upstream/main`，并在同步报告中说明

> ⚠️ 一旦 `vivo-i18n-zh` 已被外部协作者拉走，rebase 会改写历史。
> 故 rebase **只发生在临时分支** `rebase/upstream-YYYYMMDD` 上；
> `vivo-i18n-zh` 自身只做 `--ff-only`，不会强推。

---

## 5. 紧急同步（安全更新）

触发条件：上游发了 CVE 或 P0 修复。

1. 立刻跑 `bash scripts/i18n/rebase-upstream.sh`，不等周一
2. PR 标题加前缀 `[security]`
3. W0 同步通知 vivo SRE
4. CI 通过即合并，事后补走查报告

---

## 6. 同步报告模板

每次合并完成后追加到 `docs/i18n/REVIEW_LOG.md` 的「周报」段：

```markdown
### 上游同步 YYYY-MM-DD

- 拉取范围：upstream/main `<old-sha>..<new-sha>`，共 N 个 commit
- 冲突：N 个文件，主要在 `<paths>`
- 高风险 commit：
  - `<sha>` — `<subject>` — 风险点：...
- vivo i18n 影响：新增 X key / 删除 Y key
- CI：✅ / ⚠️
- 合入时间：YYYY-MM-DD HH:MM
```

---

## 7. 故障与回滚

| 场景                              | 处理                                                                  |
| --------------------------------- | --------------------------------------------------------------------- |
| rebase 后 CI 红，定位到上游引入   | 在 vivo 侧打 patch commit 修复，PR 上游修复                           |
| rebase 后 CI 红，定位到 vivo 自身 | 临时分支 revert 相关 vivo commit，发独立修复 PR                       |
| 已合入后发现回归                  | `git revert` 该 merge commit；不要 reset `vivo-i18n-zh`               |
| 上游强推改写历史（罕见）          | W0 评估后决定是否跟随；通常做一次性 `merge -X theirs`                 |

---

_维护人：W-review。每次同步后追加经验到 §3.3 / §7。_
