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

Applied 2026-10-28:

- The hardening code and records are committed; only the 2026-10-28 apply-session edits to this handoff and `docs/discovery/DISCOVERY.md` remain uncommitted.
- Real apply completed against the live HOME: 17 installed, 33 updated, 0 pruned, 128 unchanged; an immediate second apply reported 0 installed, 0 updated, 0 pruned, proving idempotency.
- `doctor: clean (v2026-10-28.2)` on the live HOME. `~/.config/tmuxinator/.work/` now holds 6 projects; `TMUXINATOR_CONFIG=$HOME/.config/tmuxinator/.primary tmuxinator list` still shows `LM`.
- The pre-rename work-profile directory was retired after inventory, diff against the repo successors, and an out-of-HOME tar backup. Removal was manual and approval-gated because the installer never tracked that path.
- One stale June `.dotbak` that carried the retired name was copied to `/tmp/work-profile-legacy-20261028/` and then removed, so the live HOME carries zero matches.

Repo state:

- Repo: `/Users/e/mnt/bnk/cs/dot`, branch `main`, HEAD `7c56714`.
- Hardening code and tests landed in `2fd559e` (`README.md`, `docs/installer/`, `files/.zsh/scripts/environment/bootstrap`, `tests/run.sh`); records landed in `7c56714` (`docs/discovery/`, this handoff).
- Uncommitted after the 2026-10-28 apply session: `docs/discovery/DISCOVERY.md` (adds D-20261028-12) and this handoff.
- Ignored review artifacts: `docs/critique/*` (force-add the ledger only if it must be committed).

## Next Actions

1. Ship the hardening diff (`ship-changes`); the redteam gate and the overwrite-policy decision are settled. Still open.
2. Real-machine dry run and real apply: done 2026-10-28 (see Applied above).
3. Work-profile retirement: done 2026-10-28. Left untouched as a separate future decision: `.primary/` and the 7 root-level yml files under `~/.config/tmuxinator/`.

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
- `.dotbak` files are unmanaged side-cars; they are never pruned and accumulate one per managed path max. 17 remained in the live HOME on 2026-10-28; the one stale June copy carrying the retired name was stashed and removed, the rest were left alone.
- Live `agile_ticket_create` requires `TICKET_URL_BASE`, which is defined nowhere in `~/.zsh`, `~/.zshenv`, or the repo; the script aborts with `set TICKET_URL_BASE` when invoked. Not fixed, needs a separate decision.
- Known cosmetic: bootstrap lacks a trailing newline at EOF.

## Discovery Links

- `D-20261028-01..04`: HOME destination, stale copy, ignored-argv, prune invariant (prior session).
- `D-20261028-05`: installer hardening outcome; `D-20261028-06`: TMUXINATOR_CONFIG trap.
- `D-20261028-07`: zsh function-scope EXIT trap disabled the lock.
- `D-20261028-08`: backup-then-overwrite decision.
- `D-20261028-09`: env fail-closed decision.
- `D-20261028-10`: state-trust hardening decision.
- `D-20261028-11`: redteam convergence outcome.
- `D-20261028-12`: work-profile retirement decision.
