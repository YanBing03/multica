# 文件认领账本（CLAIMS.md）

> 9 窗并行作战的**单写公约**：共享文件先认领、再修改。
> 责任窗：W2（应起草），W0 垫底先建骨架。
> 修改本文须走 PR 或单 commit，**不在本文里写讨论**——讨论去 STATUS.md §6。

---

## 0. 认领规则

1. **认领**：在下方 §2 表里加一行，状态 = `claimed`
2. **持有时长**：默认 ≤ 4h；超时自动失效，他人可再认领
3. **释放**：完成或放弃时把状态改 `released` 并填释放原因
4. **冲突**：两窗同时改同一文件 → 后者必须先 rebase 前者；rebase 仍冲突 → 升级到 W0 仲裁
5. **单写文件**（任何时间只允许一个窗写）：
   - `docs/i18n/STATUS.md`（各窗只编辑自己 §1.x，例外见 D-004）
   - `docs/i18n/W0-DECISIONS.md`（仅 W0）
   - `docs/i18n/TERMS.md`（仅 W4）
   - `docs/i18n/REVIEW_LOG.md` `REVIEW_CHECKLIST.md` `UPSTREAM_PR.md` `docs/ops/UPSTREAM_REBASE.md` `scripts/i18n/rebase-upstream.sh`（仅 W7）
   - `apps/web/next.config.*` `apps/web/middleware.ts`（仅 W2 在框架接入期，之后释放给 W3a）
   - `apps/web/src/locales/en.json` `zh-CN.json`（W4 主写，W3a/W3b 追加 key 时认领）

---

## 1. 共享但可多写文件（无需认领，但要 rebase）

- `pnpm-lock.yaml` `package.json`（任何窗装包都改 → 当日合并由 W0 rebase）
- 各 feature 目录下 `*.tsx`（按目录归属 W3a / W3b，跨目录改要认领）

---

## 2. 当前认领（活跃）

| 文件 / 范围 | 窗 | 状态 | 开始 | 预计释放 | 备注 |
|---|---|---|---|---|---|
| `docs/i18n/W0-DECISIONS.md` | W0 | claimed | Day 0 | 持续 | 仅 W0 写 |
| `docs/i18n/STATUS.md` 总框架 | W0 | claimed | Day 0 | 持续 | 各窗只动自己 §1.x |
| `docs/i18n/TERMS.md` | W4 | claimed | Day 0 | 持续 | D-003 后 W4 须并入正文 |
| `docs/i18n/REVIEW_*` `UPSTREAM_*` | W7 | claimed | Day 0 | 持续 | 走查域 |
| `docs/ops/UPSTREAM_REBASE.md` | W7 | claimed | Day 0 | 持续 | rebase SOP |
| `scripts/i18n/rebase-upstream.sh` | W7 | claimed | Day 0 | 持续 | rebase 脚本 |

---

## 3. 历史释放

| 文件 | 窗 | 状态 | 释放时间 | 原因 |
|---|---|---|---|---|
| _无_ | — | — | — | — |

---

## 4. 模板（拷下来填）

```
| `path/to/file` | Wx | claimed | YYYY-MM-DD HH:mm | YYYY-MM-DD HH:mm | 用途说明 |
```
