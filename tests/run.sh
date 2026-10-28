#!/usr/bin/env bash
# Black-box tests for the dotfiles environment bootstrap. Every run uses a
# throwaway HOME and fixture repos under a private mktemp root; the real HOME
# and the real repo tree are never written to (the real-repo test only reads
# the repo and writes into a fake HOME).
set -u

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SCRIPT="$REPO_ROOT/files/.zsh/scripts/environment/bootstrap"
LAUNCHER_TEMPLATE="$REPO_ROOT/docs/installer/launcher"
ZSH_BIN=${ZSH_BIN:-zsh}

if [ ! -f "$SCRIPT" ]; then
  printf 'HARNESS-ERROR: installer not found: %s\n' "$SCRIPT" >&2
  exit 2
fi
if [ ! -f "$LAUNCHER_TEMPLATE" ]; then
  printf 'HARNESS-ERROR: launcher template not found: %s\n' "$LAUNCHER_TEMPLATE" >&2
  exit 2
fi
if ! grep -q '@@DOTFILES_DIR@@' "$LAUNCHER_TEMPLATE"; then
  printf 'HARNESS-ERROR: launcher template lacks @@DOTFILES_DIR@@: %s\n' "$LAUNCHER_TEMPLATE" >&2
  exit 2
fi

TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/dot-bootstrap-tests.XXXXXX") || {
  printf 'HARNESS-ERROR: could not create temp root\n' >&2
  exit 2
}
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT HUP INT TERM

total=0
failures=0
CASE_ROOT=""
TEST_PATH_PREFIX=""
BASE_MANIFEST='.zshenv
.zsh/.zshrc'

fail() {
  printf '  %s\n' "$*" >&2
  return 1
}

write_file() {
  _path=$1
  _content=$2
  mkdir -p "$(dirname "$_path")" || return 1
  printf '%s' "$_content" >"$_path"
}

new_home() {
  _name=$1
  _home="$CASE_ROOT/home.$_name"
  mkdir -p "$_home" || return 1
  printf '%s\n' "$_home"
}

# Whole-tree digest: paths plus contents, so mtime-preserving rewrites
# (rsync -a) and in-place rewrites are both caught. Directories and unreadable
# entries fall out of the digest via shasum's own skipping; only regular-file
# state matters for these tests.
snap_tree() {
  find "$1" -exec shasum -a 256 {} + 2>/dev/null | sort | shasum -a 256 | awk '{print $1}'
}

# new_repo <dir> <manifest-text>
# Fixture repos carry a copy of the real bootstrap so the deployed launcher
# has something real to exec (C-20261028-15).
new_repo() {
  _repo=$1
  _manifest=$2
  mkdir -p "$_repo/docs/installer" "$_repo/files/.zsh/scripts/environment" || return 1
  cp "$LAUNCHER_TEMPLATE" "$_repo/docs/installer/launcher" || return 1
  cp "$SCRIPT" "$_repo/files/.zsh/scripts/environment/bootstrap" || return 1
  write_file "$_repo/docs/installer/manifest" "$_manifest" || return 1

  printf '%s\n' "$_manifest" | while IFS= read -r _line; do
    _src=$(printf '%s' "$_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    case "$_src" in
      ''|\#*) continue ;;
    esac
    case "$_src" in
      *' -> '*) _src=${_src%% -> *} ;;
    esac
    _src=$(printf '%s' "$_src" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    # minimalist: escape-artist and directory-shaped srcs are deliberate
    # fixtures in the src-validation test; never auto-create them
    case "$_src" in
      *..*|*/) continue ;;
    esac
    if [ -n "$_src" ] && [ ! -e "$_repo/files/$_src" ]; then
      write_file "$_repo/files/$_src" "fixture:$_src" || return 1
    fi
  done
}

# invoke_install <home> <repo> [flags...]
# Sets RC, OUT, ERR. TEST_PATH_PREFIX is prepended to PATH when set.
# stdin is always /dev/null so TTY detection is deterministic.
invoke_install() {
  _home=$1
  _repo=$2
  shift 2
  _outfile="$CASE_ROOT/stdout.$$"
  _errfile="$CASE_ROOT/stderr.$$"
  _path=$PATH
  if [ -n "$TEST_PATH_PREFIX" ]; then
    _path="$TEST_PATH_PREFIX:$PATH"
  fi
  # State and lock metadata live under the fake HOME's default state path.
  PATH="$_path" HOME="$_home" XDG_STATE_HOME="$_home/.local/state" \
    "$ZSH_BIN" "$SCRIPT" --repo "$_repo" "$@" >"$_outfile" 2>"$_errfile" </dev/null
  RC=$?
  OUT=$(cat "$_outfile")
  ERR=$(cat "$_errfile")
  rm -f "$_outfile" "$_errfile"
}

# The installer decorates every line with a colored [x]/[!]/[+]/[*] marker;
# strip the ANSI escapes so assertions match the real text.
strip_ansi() {
  sed $'s/\x1b\\[[0-9;]*m//g'
}

combined_output() {
  printf '%s\n%s\n' "$OUT" "$ERR" | strip_ansi
}

has_action_line() {
  combined_output | grep -Eq '^\[[+*]\] (installed|updated|pruned|would install|would update|would prune) '
}

# Require the actual log_err [x] marker so bare usage output never passes.
has_error_line() {
  printf '%s\n' "$ERR" | strip_ansi | grep -Eq '^\[x\] '
}

test_sentinel_survival() {
  _home=$(new_home sentinel) || return 1
  _repo="$CASE_ROOT/repo.sentinel"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf
.zsh/bar.conf" || return 1
  write_file "$_repo/files/.zsh/foo.conf" 'foo-bytes' || return 1
  write_file "$_repo/files/.zsh/bar.conf" 'bar-bytes' || return 1

  _expected="$CASE_ROOT/expected.sentinel"
  _paths='mnt/bnk/sentinel
Desktop/sentinel
Library/sentinel
.dotfiles.bak/sentinel
.zsh/untracked
.config/opencode/untracked'
  while IFS= read -r _rel; do
    [ -n "$_rel" ] || continue
    write_file "$_home/$_rel" "sentinel-bytes-$_rel" || return 1
    write_file "$_expected/$(printf '%s' "$_rel" | tr '/' '_')" "sentinel-bytes-$_rel" || return 1
  done <<EOF
$_paths
EOF

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "install exited $RC: $ERR"
    return 1
  fi

  while IFS= read -r _rel; do
    [ -n "$_rel" ] || continue
    if [ ! -f "$_home/$_rel" ]; then
      fail "sentinel missing: $_home/$_rel"
      return 1
    fi
    if ! cmp -s "$_expected/$(printf '%s' "$_rel" | tr '/' '_')" "$_home/$_rel"; then
      fail "sentinel bytes changed: $_home/$_rel"
      return 1
    fi
  done <<EOF
$_paths
EOF
}

test_dry_run_writes_nothing() {
  _home=$(new_home dryrun) || return 1
  _repo="$CASE_ROOT/repo.dryrun"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1

  _before=$(snap_tree "$_home")
  invoke_install "$_home" "$_repo"
  _after=$(snap_tree "$_home")
  if [ "$_before" != "$_after" ]; then
    fail "default dry-run wrote under HOME"
    return 1
  fi
  if [ -e "$_home/.local/state" ]; then
    fail "default dry-run created installer state"
    return 1
  fi

  invoke_install "$_home" "$_repo" --dry-run
  if [ "$RC" -ne 0 ]; then
    fail "explicit --dry-run exited $RC: $ERR"
    return 1
  fi
  if [ "$_before" != "$(snap_tree "$_home")" ]; then
    fail "explicit --dry-run wrote under HOME"
    return 1
  fi
}

test_idempotency() {
  _home=$(new_home idem) || return 1
  _repo="$CASE_ROOT/repo.idem"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf
.zsh/bar.conf" || return 1

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "first install exited $RC: $ERR"
    return 1
  fi

  _before=$(snap_tree "$_home")
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "second install exited $RC: $ERR"
    return 1
  fi

  _after=$(snap_tree "$_home")
  if [ "$_before" != "$_after" ]; then
    fail "second install wrote under HOME"
    return 1
  fi
  if has_action_line; then
    fail "second install reported an install/update/prune action: $(combined_output | tr '\n' ' ')"
    return 1
  fi
}

test_prune_safety() {
  _home=$(new_home prune) || return 1
  _repo="$CASE_ROOT/repo.prune"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/old.conf
.zsh/edited.conf" || return 1
  write_file "$_repo/files/.zsh/old.conf" 'old-bytes' || return 1
  write_file "$_repo/files/.zsh/edited.conf" 'edited-bytes' || return 1

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "first install exited $RC: $ERR"
    return 1
  fi
  if [ ! -f "$_home/.zsh/old.conf" ] || [ ! -f "$_home/.zsh/edited.conf" ]; then
    fail "initial install did not deploy both files"
    return 1
  fi

  write_file "$_home/.zsh/edited.conf" 'user-edit-bytes' || return 1
  write_file "$_repo/docs/installer/manifest" "$BASE_MANIFEST" || return 1

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "prune install exited $RC: $ERR"
    return 1
  fi
  if [ -e "$_home/.zsh/old.conf" ]; then
    fail "unmodified pruned file still exists: $_home/.zsh/old.conf"
    return 1
  fi
  if [ ! -f "$_home/.zsh/edited.conf" ]; then
    fail "user-edited pruned file was deleted: $_home/.zsh/edited.conf"
    return 1
  fi
  _expected="$CASE_ROOT/expected.edited"
  write_file "$_expected" 'user-edit-bytes' || return 1
  if ! cmp -s "$_expected" "$_home/.zsh/edited.conf"; then
    fail "user-edited pruned file bytes changed"
    return 1
  fi
}

guard_case() {
  _dest=$1
  _tag=$(printf '%s' "$_dest" | tr '/.' '__')
  _home=$(new_home "guard.$_tag") || return 1
  _repo="$CASE_ROOT/repo.guard.$_tag"
  new_repo "$_repo" "$BASE_MANIFEST
guard.conf -> $_dest" || return 1
  write_file "$_repo/files/guard.conf" 'guard-bytes' || return 1

  _before=$(snap_tree "$_home")
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -eq 0 ]; then
    fail "unsafe destination accepted: $_dest"
    return 1
  fi
  if ! has_error_line; then
    fail "no [x] error line for unsafe destination: $_dest => $ERR"
    return 1
  fi
  if [ "$_before" != "$(snap_tree "$_home")" ]; then
    fail "unsafe destination run still wrote under HOME: $_dest"
    return 1
  fi
}

test_guards() {
  guard_case '/' || return 1
  guard_case '.' || return 1
  # $HOME/mnt is the proxy for a forbidden mount root.
  guard_case 'mnt/x' || return 1

  _home=$(new_home root) || return 1
  _repo="$CASE_ROOT/repo.root"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  _fakebin="$CASE_ROOT/fakebin"
  mkdir -p "$_fakebin" || return 1
  write_file "$_fakebin/id" '#!/bin/sh
case "$1" in
  -u|-ru|--user) echo 0; exit 0 ;;
esac
exec /usr/bin/id "$@"
' || return 1
  chmod +x "$_fakebin/id" || return 1
  TEST_PATH_PREFIX="$_fakebin"
  invoke_install "$_home" "$_repo" --apply --yes
  TEST_PATH_PREFIX=""
  if [ "$RC" -eq 0 ]; then
    fail "root user was not refused"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eqi 'root'; then
    fail "root refusal stderr unclear: $ERR"
    return 1
  fi

  _home=$(new_home stateoutside) || return 1
  _repo="$CASE_ROOT/repo.stateoutside"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  _outfile="$CASE_ROOT/stdout.stateoutside"
  _errfile="$CASE_ROOT/stderr.stateoutside"
  HOME="$_home" XDG_STATE_HOME="$CASE_ROOT/outside-state" \
    "$ZSH_BIN" "$SCRIPT" --repo "$_repo" --apply --yes \
    >"$_outfile" 2>"$_errfile" </dev/null
  RC=$?
  ERR=$(cat "$_errfile")
  if [ "$RC" -eq 0 ]; then
    fail "state dir outside HOME was accepted"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eqi 'state|outside|HOME|refus|forbidden'; then
    fail "state-outside-HOME refusal unclear: $ERR"
    return 1
  fi
  rm -f "$_outfile" "$_errfile"
  if [ -e "$CASE_ROOT/outside-state" ]; then
    fail "state dir created outside HOME"
    return 1
  fi
}

test_stale_entrypoint() {
  _home=$(new_home stale) || return 1
  _old="$CASE_ROOT/repo.stale.old"
  _new="$CASE_ROOT/repo.stale.new"
  new_repo "$_old" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  new_repo "$_new" "$BASE_MANIFEST
.zsh/foo.conf" || return 1

  invoke_install "$_home" "$_old" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "old-repo install exited $RC: $ERR"
    return 1
  fi
  if [ ! -f "$_home/.zsh/scripts/environment/bootstrap" ]; then
    fail "deployed entrypoint missing"
    return 1
  fi

  invoke_install "$_home" "$_new" doctor
  if [ "$RC" -eq 0 ]; then
    fail "doctor accepted entrypoint baked to an old repo"
    return 1
  fi
  if ! combined_output | grep -Eqi 'entrypoint|deployed|DOTFILES_DIR|repo|drift|stale|mismatch|outdated'; then
    fail "stale-entrypoint output unclear: $(combined_output | tr '\n' ' ')"
    return 1
  fi
}

# C-20261028-02, C-20261028-08: manifest src validation must refuse before any
# write — escape out of files/, missing src file, directory-shaped src.
src_refusal_case() {
  _label=$1
  _line=$2
  _home=$(new_home "src.$_label") || return 1
  _repo="$CASE_ROOT/repo.src.$_label"
  new_repo "$_repo" "$BASE_MANIFEST
$_line" || return 1
  rm -f "$_repo/files/missing.conf"
  _before=$(snap_tree "$_home")
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -eq 0 ]; then
    fail "invalid src accepted ($_label): $_line"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'manifest src'; then
    fail "no 'manifest src' error for $_label: $ERR"
    return 1
  fi
  if [ "$_before" != "$(snap_tree "$_home")" ]; then
    fail "src refusal wrote under HOME anyway ($_label)"
    return 1
  fi
}

test_src_validation() {
  src_refusal_case escape '../outside -> dest' || return 1
  src_refusal_case missing 'missing.conf -> dest' || return 1
  src_refusal_case dirsrc 'somedir/ -> dest' || return 1
}

# C-20261028-07, C-20261028-20: dest lint rejects dotdot and trailing-slash
# components at manifest load, before any write.
dest_lint_case() {
  _label=$1
  _dest=$2
  _home=$(new_home "dest.$_label") || return 1
  _repo="$CASE_ROOT/repo.dest.$_label"
  new_repo "$_repo" "$BASE_MANIFEST
guard.conf -> $_dest" || return 1
  _before=$(snap_tree "$_home")
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -eq 0 ]; then
    fail "lint-invalid dest accepted: $_dest"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'refusing manifest dest'; then
    fail "no dest-lint refusal for $_dest: $ERR"
    return 1
  fi
  if [ "$_before" != "$(snap_tree "$_home")" ]; then
    fail "dest-lint refusal wrote under HOME anyway: $_dest"
    return 1
  fi
}

test_dest_lint() {
  dest_lint_case dotdot 'd/../secret.conf' || return 1
  dest_lint_case trailslash 'trailing/' || return 1
}

# C-20261028-07: an existing directory at a managed dest refuses the run and
# leaves the directory contents untouched.
test_dest_dir_conflict() {
  _home=$(new_home destdir) || return 1
  _repo="$CASE_ROOT/repo.destdir"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/conflict" || return 1
  write_file "$_home/.zsh/conflict/inner" 'inner-bytes' || return 1
  _before=$(snap_tree "$_home")
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -eq 0 ]; then
    fail "existing directory at managed dest accepted"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'destination exists and is a directory'; then
    fail "no dir-conflict error: $ERR"
    return 1
  fi
  if [ "$_before" != "$(snap_tree "$_home")" ]; then
    fail "dir-conflict refusal mutated HOME"
    return 1
  fi
}

# C-20261028-03: a case-variant state key of a managed rel is treated as an
# alias — managed file survives, warning logged, canonical key in state after.
test_case_alias_prune() {
  _home=$(new_home alias) || return 1
  _repo="$CASE_ROOT/repo.alias"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  _state="$_home/.local/state/dot/installed.manifest"

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "first install exited $RC: $ERR"
    return 1
  fi

  sed 's/\.zsh\/foo\.conf$/.ZSH\/FOO.conf/' "$_state" >"$_state.new" || return 1
  mv -f "$_state.new" "$_state" || return 1

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "alias run exited $RC: $ERR"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'case alias'; then
    fail "no case-alias warning: $ERR"
    return 1
  fi
  if [ ! -f "$_home/.zsh/foo.conf" ]; then
    fail "managed file was pruned via its case-alias state key"
    return 1
  fi
  if grep -q '\.ZSH/FOO\.conf' "$_state"; then
    fail "case-alias key still present in state after apply"
    return 1
  fi
  if ! grep -q $'\t''\.zsh/foo\.conf$' "$_state"; then
    fail "canonical key missing from state after apply"
    return 1
  fi
}

# C-20261028-10, C-20261028-18: lock lifecycle — dead pid recovery, live
# foreign pid refusal, empty-dir recovery (deliverable 1), clean exit removes
# the lock, and one real SIGKILL mid-apply observed as stale recovery.
test_lock_lifecycle() {
  # (a) leaked lock with a dead pid
  _home=$(new_home lockdead) || return 1
  _repo="$CASE_ROOT/repo.lockdead"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  mkdir -p "$_home/.local/state/dot/lock" || return 1
  printf '999999\n' >"$_home/.local/state/dot/lock/pid"
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "dead-pid lock was not recovered: $ERR"
    return 1
  fi
  if ! combined_output | grep -Eq 'stale lock'; then
    fail "no stale-lock warning for dead pid: $(combined_output | tr '\n' ' ')"
    return 1
  fi
  # (d) clean apply leaves no lock dir
  if [ -e "$_home/.local/state/dot/lock" ]; then
    fail "lock dir survived a clean apply"
    return 1
  fi

  # (b) live foreign pid
  _home=$(new_home locklive) || return 1
  _repo="$CASE_ROOT/repo.locklive"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  sleep 60 &
  _sleeppid=$!
  mkdir -p "$_home/.local/state/dot/lock" || return 1
  printf '%s\n' "$_sleeppid" >"$_home/.local/state/dot/lock/pid"
  invoke_install "$_home" "$_repo" --apply --yes
  kill "$_sleeppid" 2>/dev/null
  wait "$_sleeppid" 2>/dev/null
  if [ "$RC" -eq 0 ]; then
    fail "live foreign pid lock was not refused"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'another run is active'; then
    fail "live-pid refusal message unclear: $ERR"
    return 1
  fi

  # (c) empty lock dir — SIGKILL in the mkdir-to-pid-write window (deliverable 1)
  _home=$(new_home lockempty) || return 1
  _repo="$CASE_ROOT/repo.lockempty"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  mkdir -p "$_home/.local/state/dot/lock" || return 1
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "empty lock dir was not recovered: $ERR"
    return 1
  fi
  if ! combined_output | grep -Eq 'stale lock .no pid.'; then
    fail "no stale-lock (no pid) warning: $(combined_output | tr '\n' ' ')"
    return 1
  fi

  # SIGKILL mid-apply: enough files that the run outlives our kill delay; a
  # leaked lock with a dead owner must be recovered on rerun.
  _home=$(new_home lockkill) || return 1
  _repo="$CASE_ROOT/repo.lockkill"
  _manifest=$BASE_MANIFEST
  _i=0
  while [ "$_i" -lt 400 ]; do
    _manifest="$_manifest
.zsh/kill/file$_i.conf"
    _i=$((_i + 1))
  done
  new_repo "$_repo" "$_manifest" || return 1
  _leaked=0
  _try=0
  while [ "$_try" -lt 6 ]; do
    HOME="$_home" XDG_STATE_HOME="$_home/.local/state" \
      "$ZSH_BIN" "$SCRIPT" --repo "$_repo" --apply --yes \
      >"$CASE_ROOT/kill.out" 2>"$CASE_ROOT/kill.err" </dev/null &
    _bpid=$!
    # minimalist: poll for the lock dir, then kill — a fixed sleep races the
    # mkdir-to-install window on fast machines
    _w=0
    while [ ! -e "$_home/.local/state/dot/lock" ] && kill -0 "$_bpid" 2>/dev/null && [ "$_w" -lt 200 ]; do
      sleep 0.02
      _w=$((_w + 1))
    done
    if kill -9 "$_bpid" 2>/dev/null && [ -e "$_home/.local/state/dot/lock" ]; then
      _leaked=1
      break
    fi
    wait "$_bpid" 2>/dev/null
    _try=$((_try + 1))
  done
  if [ "$_leaked" -ne 1 ]; then
    fail "could not leak a lock via SIGKILL in $_try tries"
    return 1
  fi
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "post-SIGKILL rerun failed: $ERR"
    return 1
  fi
  if ! combined_output | grep -Eq 'stale lock'; then
    fail "post-SIGKILL rerun showed no stale recovery: $(combined_output | tr '\n' ' ')"
    return 1
  fi
}

# C-20261028-18: --apply without --yes off a TTY exits 2.
test_nontty_apply() {
  _home=$(new_home nontty) || return 1
  _repo="$CASE_ROOT/repo.nontty"
  new_repo "$_repo" "$BASE_MANIFEST" || return 1
  invoke_install "$_home" "$_repo" --apply
  if [ "$RC" -ne 2 ]; then
    fail "non-TTY --apply exited $RC (want 2): $ERR"
    return 1
  fi
  if ! has_error_line; then
    fail "non-TTY --apply produced no [x] error: $ERR"
    return 1
  fi
}

# C-20261028-15: the deployed launcher is executable and honors DOTFILES_DIR.
test_launcher_exec() {
  _home=$(new_home launch) || return 1
  _repo_a="$CASE_ROOT/repo.launch.a"
  _repo_b="$CASE_ROOT/repo.launch.b"
  new_repo "$_repo_a" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  new_repo "$_repo_b" "$BASE_MANIFEST
.zsh/foo.conf" || return 1

  invoke_install "$_home" "$_repo_a" --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "apply exited $RC: $ERR"
    return 1
  fi
  _deployed="$_home/.zsh/scripts/environment/bootstrap"

  HOME="$_home" XDG_STATE_HOME="$_home/.local/state" \
    "$ZSH_BIN" "$_deployed" doctor >"$CASE_ROOT/launch.out" 2>"$CASE_ROOT/launch.err" </dev/null
  if [ "$?" -ne 0 ]; then
    fail "deployed launcher doctor failed: $(cat "$CASE_ROOT/launch.err")"
    return 1
  fi
  if ! grep -q 'doctor: clean' "$CASE_ROOT/launch.out"; then
    fail "deployed launcher doctor not clean: $(cat "$CASE_ROOT/launch.out")"
    return 1
  fi

  HOME="$_home" XDG_STATE_HOME="$_home/.local/state" DOTFILES_DIR="$_repo_b" \
    "$ZSH_BIN" "$_deployed" >"$CASE_ROOT/launch.out" 2>"$CASE_ROOT/launch.err" </dev/null
  # minimalist: match the repo basename, not the full path — the script
  # prints the :A-resolved (/private/...) form of the repo path
  if ! { cat "$CASE_ROOT/launch.out"; cat "$CASE_ROOT/launch.err"; } | strip_ansi \
    | grep -Eq "dotfiles: .*repo\.launch\.b "; then
    fail "deployed launcher did not exec the DOTFILES_DIR override repo: $(cat "$CASE_ROOT/launch.out")"
    return 1
  fi
}

# C-20261028-16: the real repo installs fully, idempotently, and the personal
# overlay is gated on --env-name. Reads the real repo; writes only fake HOMEs.
test_real_repo() {
  _home=$(new_home real) || return 1
  invoke_install "$_home" "$REPO_ROOT" --only dotfiles --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "real-repo install exited $RC: $ERR"
    return 1
  fi
  if ! combined_output | grep -Eq '178 installed'; then
    fail "real-repo install count wrong: $(combined_output | grep 'installed' | tr '\n' ' ')"
    return 1
  fi

  invoke_install "$_home" "$REPO_ROOT" doctor
  if [ "$RC" -ne 0 ]; then
    fail "real-repo doctor not clean after apply: $OUT"
    return 1
  fi

  invoke_install "$_home" "$REPO_ROOT" --only dotfiles --apply --yes
  if [ "$RC" -ne 0 ]; then
    fail "real-repo second apply exited $RC: $ERR"
    return 1
  fi
  if ! combined_output | grep -Eq '0 installed, 0 updated'; then
    fail "real-repo second apply not idempotent: $(combined_output | grep 'installed' | tr '\n' ' ')"
    return 1
  fi

  invoke_install "$_home" "$REPO_ROOT" --only dotfiles --apply --yes --env-name primary_macos
  if [ "$RC" -ne 0 ]; then
    fail "env-name apply exited $RC: $ERR"
    return 1
  fi
  if [ ! -f "$_home/.zsh/env/primary_macos" ]; then
    fail "personal overlay entry not installed for primary_macos"
    return 1
  fi

  _home2=$(new_home realnosuch) || return 1
  invoke_install "$_home2" "$REPO_ROOT" --only dotfiles --apply --yes --env-name nosuchenv
  # fail-closed (C-20261028-19): unknown profile aborts rc=2 before any install
  if [ "$RC" -ne 2 ]; then
    fail "nosuchenv apply exited $RC (want 2): $ERR"
    return 1
  fi
}

# C-20261028-17: escaped (\040), macOS-style, and plain spaced mount lines all
# parse; a dest under an escaped mount name inside HOME is refused.
test_mount_parsing() {
  _home=$(new_home mount) || return 1
  _repo="$CASE_ROOT/repo.mount"
  new_repo "$_repo" "$BASE_MANIFEST
mydisk.conf -> My Disk/x" || return 1
  _fakebin="$CASE_ROOT/fakebin.mount"
  mkdir -p "$_fakebin" || return 1
  # minimalist: unquoted heredoc, not write_file — the stub needs $_home
  # expanded and \040 kept as four literal bytes
  cat >"$_fakebin/mount" <<EOF
#!/bin/sh
printf '%s\n' \\
  "tmpfs on $_home/My\\040Disk type tmpfs (rw,relatime)" \\
  "/dev/disk1s1 on / (apfs, local)" \\
  "tmpfs on $_home/plain disk type tmpfs (rw,relatime)"
EOF
  chmod +x "$_fakebin/mount" || return 1

  _before=$(snap_tree "$_home")
  TEST_PATH_PREFIX="$_fakebin"
  invoke_install "$_home" "$_repo" --apply --yes
  TEST_PATH_PREFIX=""
  if [ "$RC" -eq 0 ]; then
    fail "dest under escaped mount point accepted"
    return 1
  fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eqi 'mount point|forbidden'; then
    fail "mount refusal message unclear: $ERR"
    return 1
  fi
  if [ "$_before" != "$(snap_tree "$_home")" ]; then
    fail "mount refusal wrote under HOME anyway"
    return 1
  fi
}

# Owner decision: update path backs up to a rolling .dotbak before overwrite;
# installs and idempotent applies create none.
test_update_backup() {
  _home=$(new_home bak) || return 1
  _repo="$CASE_ROOT/repo.bak"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then fail "first install exited $RC: $ERR"; return 1; fi
  if [ -e "$_home/.zsh/foo.conf.dotbak" ]; then fail "install created a .dotbak"; return 1; fi

  write_file "$_home/.zsh/foo.conf" 'user-edit-bytes' || return 1
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then fail "update apply exited $RC: $ERR"; return 1; fi
  if ! combined_output | grep -Eq 'updated \.zsh/foo\.conf'; then
    fail "no update line: $(combined_output | tr '\n' ' ')"; return 1
  fi
  _old="$CASE_ROOT/expected.bak.old"
  write_file "$_old" 'user-edit-bytes' || return 1
  if ! cmp -s "$_old" "$_home/.zsh/foo.conf.dotbak"; then
    fail ".dotbak does not hold the old content"; return 1
  fi
  _new="$CASE_ROOT/expected.bak.new"
  write_file "$_new" 'fixture:.zsh/foo.conf' || return 1
  if ! cmp -s "$_new" "$_home/.zsh/foo.conf"; then
    fail "managed file not updated to repo content"; return 1
  fi

  _bakhash=$(shasum -a 256 "$_home/.zsh/foo.conf.dotbak" | awk '{print $1}')
  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then fail "second apply exited $RC: $ERR"; return 1; fi
  if has_action_line; then
    fail "idempotent apply reported an action: $(combined_output | tr '\n' ' ')"; return 1
  fi
  if [ "$_bakhash" != "$(shasum -a 256 "$_home/.zsh/foo.conf.dotbak" | awk '{print $1}')" ]; then
    fail ".dotbak changed on idempotent apply"; return 1
  fi
}

# C-20261028-19: env selection fails closed — comment-only ~/.env_name and an
# unknown --env-name both abort rc=2 (the latter listing valid profiles).
test_env_fail_closed() {
  _home=$(new_home envcomment) || return 1
  _repo="$CASE_ROOT/repo.envcomment"
  new_repo "$_repo" "$BASE_MANIFEST" || return 1
  write_file "$_home/.env_name" '# only a comment' || return 1
  invoke_install "$_home" "$_repo" --only dotfiles --apply --yes
  if [ "$RC" -ne 2 ]; then fail "comment-only env exited $RC (want 2): $ERR"; return 1; fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'env name unreadable'; then
    fail "no unreadable-env error: $ERR"; return 1
  fi

  _home=$(new_home envbad) || return 1
  invoke_install "$_home" "$REPO_ROOT" --only dotfiles --apply --yes --env-name nosuchenv
  if [ "$RC" -ne 2 ]; then fail "nosuchenv exited $RC (want 2): $ERR"; return 1; fi
  if ! combined_output | grep -Eq 'unknown env profile: nosuchenv \(valid: '; then
    fail "no unknown-profile error with valid list: $(combined_output | tr '\n' ' ')"; return 1
  fi
  if ! combined_output | grep -q 'primary_macos'; then
    fail "valid list missing personal profile: $(combined_output | tr '\n' ' ')"; return 1
  fi
}

# C-20261028-01/05: forged state hash never prunes an unmanaged file; the
# state dir is created 0700.
test_state_trust() {
  _home=$(new_home trust) || return 1
  _repo="$CASE_ROOT/repo.trust"
  new_repo "$_repo" "$BASE_MANIFEST
.zsh/foo.conf" || return 1
  write_file "$_home/.zsh/unmanaged" 'precious-bytes' || return 1

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then fail "first install exited $RC: $ERR"; return 1; fi

  _state="$_home/.local/state/dot/installed.manifest"
  _wrong=$(printf 'not-the-real-content' | shasum -a 256 | awk '{print $1}')
  printf '%s\t%s\n' "$_wrong" '.zsh/unmanaged' >>"$_state"

  invoke_install "$_home" "$_repo" --apply --yes
  if [ "$RC" -ne 0 ]; then fail "forged-state apply exited $RC: $ERR"; return 1; fi
  if ! printf '%s\n' "$ERR" | strip_ansi | grep -Eq 'keeping modified file: \.zsh/unmanaged'; then
    fail "no keep warning for forged state: $ERR"; return 1
  fi
  _exp="$CASE_ROOT/expected.trust"
  write_file "$_exp" 'precious-bytes' || return 1
  if ! cmp -s "$_exp" "$_home/.zsh/unmanaged"; then
    fail "unmanaged file pruned or mutated via forged state"; return 1
  fi

  _mode=$(stat -f %Lp "$_home/.local/state/dot")
  if [ "$_mode" != "700" ]; then
    fail "state dir mode is $_mode (want 700)"; return 1
  fi
}

run_test() {
  _name=$1
  CASE_ROOT=$(mktemp -d "$TMP_ROOT/case.XXXXXX") || {
    printf 'FAIL: %s (could not create case temp dir)\n' "$_name"
    failures=$((failures + 1))
    total=$((total + 1))
    return
  }
  TEST_PATH_PREFIX=""
  total=$((total + 1))
  if "$_name"; then
    printf 'PASS: %s\n' "$_name"
  else
    printf 'FAIL: %s\n' "$_name"
    failures=$((failures + 1))
  fi
}

run_test test_sentinel_survival
run_test test_dry_run_writes_nothing
run_test test_idempotency
run_test test_prune_safety
run_test test_guards
run_test test_stale_entrypoint
run_test test_src_validation
run_test test_dest_lint
run_test test_dest_dir_conflict
run_test test_case_alias_prune
run_test test_lock_lifecycle
run_test test_nontty_apply
run_test test_launcher_exec
run_test test_real_repo
run_test test_mount_parsing
run_test test_update_backup
run_test test_env_fail_closed
run_test test_state_trust

if [ "$failures" -ne 0 ]; then
  printf 'RESULT: FAIL (%d/%d passed)\n' "$((total - failures))" "$total"
  exit 1
fi
printf 'RESULT: PASS (%d/%d passed)\n' "$total" "$total"
exit 0
