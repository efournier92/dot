# 2026-10-28 Bootstrap Hardening Handoff

## Current State

Done:

- Redteam install-flow run complete and CONVERGED: ledger `docs/critique/2026-10-28_install-flow.md`, 31 findings (C-20261028-01..30 plus the overwrite-policy decision), 25 addressed by fix, 5 rejected with evidence, 1 owner-vetoed into hardening. Referee verdict: CONVERGED.
- Code fixes in `files/.zsh/scripts/environment/bootstrap` (v2026-10-28.2, ~470 lines): manifest src validation (regular file, canonical containment), dest lint, dest-exists-as-directory refusal, case-alias prune skip (EXPECTED_LC), pid-file lock with stale recovery, atomic tmp+mv writes for launcher and state, doctor flags symlinked entrypoint, type-aware mount parsing with backslash-040 decode, unearned machinery removed (--resume/phase state, xcode CLT bootstrap, git/gh brew baseline, verify/doctor duplication).
- zsh trap fixed: the function-scoped EXIT trap released the lock at function return; now `zshexit_functions+=(_release_lock)` plus top-level signal trap (D-20261028-07).
- Owner decisions implemented: backup-then-overwrite (`.dotbak` on update path), env fail-closed (rc=2 on comment-only `~/.env_name` or unknown profile), state dir chmod 700 + wrong-hash prune regression test; brew curl-pipe-bash rejection upheld.
- `tests/run.sh` rewritten (ANSI strip, whole-tree sha snapshots, `[x]`-marker error matching) and grown 6 to 18 cases: `bash tests/run.sh` = PASS 18/18.
- README installer section updated (brew requires --apps, env profile selection, .dotbak note).
- Discovery entries D-20261028-07..11 appended.

In progress:

- All hardening work is uncommitted.
- The installer has NOT been applied to the real HOME; only dry runs and fake-HOME runs. Real `doctor` still reports drift until first real apply.

Repo state:

- Repo: `/Users/e/mnt/bnk/cs/dot`, branch `main`, HEAD `8f7a2e2`.
- Modified: `README.md`, `docs/discovery/DISCOVERY.md`, `files/.zsh/scripts/environment/bootstrap`.
- Untracked: `docs/installer/`, `tests/`, `docs/handoffs/`.
- Ignored review artifacts: `docs/critique/*` (force-add the ledger only if it must be committed).

## Next Actions

1. Ship the hardening diff (`ship-changes`); the redteam gate and the overwrite-policy decision are settled.
2. Real-machine dry run, inspect the plan:
   `zsh files/.zsh/scripts/environment/bootstrap --only dotfiles --dry-run`
3. Real apply, then verify:
   - `zsh files/.zsh/scripts/environment/bootstrap --only dotfiles --apply --yes`
   - `doctor` must print `doctor: clean (v2026-10-28.2)`.
   - `TMUXINATOR_CONFIG=$HOME/.config/tmuxinator/.primary tmuxinator list` must still show `LM`.
4. Decide whether to retire the stale live `.work_savvy` directory (repo ships `.work`).

## Verify Commands

```sh
cd /Users/e/mnt/bnk/cs/dot
git status --short
zsh -n files/.zsh/scripts/environment/bootstrap
bash tests/run.sh
```

Expected: `RESULT: PASS (18/18 passed)`.

Fake-HOME proof:

```sh
T=$(mktemp -d /tmp/handoff-check.XXXXXX); H="$T/home"; mkdir -p "$H"
HOME="$H" XDG_STATE_HOME="$H/.local/state" zsh files/.zsh/scripts/environment/bootstrap --repo /Users/e/mnt/bnk/cs/dot --only dotfiles --apply --yes
HOME="$H" XDG_STATE_HOME="$H/.local/state" zsh files/.zsh/scripts/environment/bootstrap --repo /Users/e/mnt/bnk/cs/dot --only dotfiles doctor
rm -rf "$T"
```

Expected: apply exits 0 (178 installed), doctor prints `doctor: clean (v2026-10-28.2)`.

## Open Risks and Blockers

- Accepted residuals, owner-ratified: same-user state forgery with matching hash (C-01), unpinned brew installer behind --apps (C-12), same-user TOCTOU (C-11), PATH-spoofed id (C-21), repo-path metacharacters in launcher (C-22).
- Plugin scripts referenced by skills are missing from the install (`check_critique.py`, `check_discovery.py`, `lint-markdown.py`); ledger and discovery were validated manually. System-level fix pending.
- `.dotbak` files are unmanaged side-cars; they are never pruned and accumulate one per managed path max.
- Known cosmetic: bootstrap lacks a trailing newline at EOF.

## Discovery Links

- `D-20261028-01..04`: HOME destination, stale copy, ignored-argv, prune invariant (prior session).
- `D-20261028-05`: installer hardening outcome; `D-20261028-06`: TMUXINATOR_CONFIG trap.
- `D-20261028-07`: zsh function-scope EXIT trap disabled the lock.
- `D-20261028-08`: backup-then-overwrite decision.
- `D-20261028-09`: env fail-closed decision.
- `D-20261028-10`: state-trust hardening decision.
- `D-20261028-11`: redteam convergence outcome.
