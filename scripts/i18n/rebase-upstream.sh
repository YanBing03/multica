#!/usr/bin/env bash
# rebase-upstream.sh
#
# vivo fork 周度同步上游脚本。
# 流程：
#   1. fetch upstream/main + origin
#   2. 在 rebase/upstream-YYYYMMDD 分支上 rebase vivo-i18n-zh
#   3. 推送该分支并（可选）通过 gh 创建 PR 跑 CI
#
# 不会直接动 vivo-i18n-zh，所有操作在临时分支上。
# 真实合入由 W0 / 维护者通过 PR review 后手动操作。

set -euo pipefail

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/multica-ai/multica.git}"
ORIGIN_REMOTE="${ORIGIN_REMOTE:-origin}"
VIVO_BRANCH="${VIVO_BRANCH:-vivo-i18n-zh}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
DATE_TAG="$(date +%Y%m%d)"
REBASE_BRANCH="${REBASE_BRANCH:-rebase/upstream-${DATE_TAG}}"
CREATE_PR="${CREATE_PR:-1}"   # 0 = 不创建 PR，仅推分支
DRY_RUN="${DRY_RUN:-0}"

log() { printf "\033[1;34m[rebase-upstream]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[rebase-upstream]\033[0m %s\n" "$*" >&2; }
die() { printf "\033[1;31m[rebase-upstream]\033[0m %s\n" "$*" >&2; exit 1; }
run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "+ $*"
  else
    eval "$@"
  fi
}

# --- 0. 前置检查 ---
command -v git >/dev/null || die "git 未安装"
[[ -d .git ]] || die "请在仓库根目录执行（未发现 .git）"

if ! git diff --quiet || ! git diff --cached --quiet; then
  die "工作区有未提交改动，请先 commit / stash"
fi

# --- 1. 配置 upstream remote ---
if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  log "添加 upstream remote: $UPSTREAM_URL"
  run "git remote add $UPSTREAM_REMOTE $UPSTREAM_URL"
fi

# --- 2. fetch ---
log "fetch $UPSTREAM_REMOTE / $ORIGIN_REMOTE"
run "git fetch $UPSTREAM_REMOTE --prune"
run "git fetch $ORIGIN_REMOTE --prune"

UPSTREAM_HEAD="$(git rev-parse "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}")"
VIVO_HEAD="$(git rev-parse "${ORIGIN_REMOTE}/${VIVO_BRANCH}")"
log "upstream HEAD : $UPSTREAM_HEAD"
log "vivo    HEAD : $VIVO_HEAD"

# 已经包含上游所有 commit -> 无需 rebase
if git merge-base --is-ancestor "$UPSTREAM_HEAD" "$VIVO_HEAD"; then
  log "vivo-i18n-zh 已包含 upstream/$UPSTREAM_BRANCH 全部 commit，无需 rebase。"
  exit 0
fi

# --- 3. 切临时分支并 rebase ---
log "创建临时分支：$REBASE_BRANCH（基于 $ORIGIN_REMOTE/$VIVO_BRANCH）"
run "git checkout -B $REBASE_BRANCH ${ORIGIN_REMOTE}/${VIVO_BRANCH}"

log "rebase 到 ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
if ! run "git rebase ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"; then
  warn "rebase 出现冲突。"
  warn "请手动解决：解决后 git add . && git rebase --continue"
  warn "全部完成后再次跑本脚本（会跳过已完成步骤）。"
  exit 2
fi

# --- 4. 本地校验门禁（尽力而为，缺命令则跳过） ---
log "运行本地门禁（lint / typecheck / test）"
if [[ -f package.json ]]; then
  if command -v pnpm >/dev/null; then PM=pnpm
  elif command -v yarn >/dev/null; then PM=yarn
  else PM=npm; fi

  for script in lint typecheck test; do
    if grep -q "\"${script}\"" package.json; then
      log "→ $PM run $script"
      run "$PM run $script" || die "本地门禁失败：$script"
    else
      warn "package.json 无 $script 脚本，跳过"
    fi
  done
else
  warn "未发现 package.json，跳过 JS/TS 门禁"
fi

# --- 5. 推送临时分支 ---
log "推送 $REBASE_BRANCH 到 $ORIGIN_REMOTE"
run "git push -u $ORIGIN_REMOTE $REBASE_BRANCH"

# --- 6. （可选）创建 PR 触发 CI ---
if [[ "$CREATE_PR" == "1" ]] && command -v gh >/dev/null; then
  log "创建 vivo fork 内部 PR：$REBASE_BRANCH → $VIVO_BRANCH"
  PR_BODY=$(cat <<EOF
## 上游同步

- 自动生成于 $(date '+%Y-%m-%d %H:%M %Z')
- upstream HEAD: \`$UPSTREAM_HEAD\`
- 基础分支: \`$VIVO_BRANCH\`
- 用途：跑 CI，确认 rebase 后无回归。

## 走查

- [ ] CI 全绿
- [ ] 无业务逻辑误改
- [ ] 无 i18n key 丢失
- [ ] 无默认 locale 被改回 \`en\`

> 由 W0 review 通过后，再线下手动 fast-forward 到 \`$VIVO_BRANCH\`。
EOF
)
  run "gh pr create --base $VIVO_BRANCH --head $REBASE_BRANCH \
    --title 'chore: rebase onto upstream/$UPSTREAM_BRANCH ($DATE_TAG)' \
    --body \"\$PR_BODY\" --draft"
else
  warn "未创建 PR（CREATE_PR=$CREATE_PR 或 gh 不可用）。"
  warn "手动跑：gh pr create --base $VIVO_BRANCH --head $REBASE_BRANCH --draft"
fi

log "完成。临时分支：$REBASE_BRANCH"
log "下一步：等待 CI 与 W0 review，通过后由维护者合并到 $VIVO_BRANCH。"
