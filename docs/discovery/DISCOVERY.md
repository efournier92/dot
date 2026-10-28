# Discovery

One line per finding, decision, assumption, trap, question, or outcome. Newest first. Evidence required.
Scope tokens: zsh/bootstrap, zsh/prompt

## Entries

- D-20261028-11 | 2026-10-28 | [outcome] | zsh/bootstrap | Install-flow redteam converged: 30 findings, 25 fixed, 5 rejected (1 owner-ratified); suite grew 6 to 18 cases | `bash tests/run.sh` -> PASS 18/18
- D-20261028-10 | 2026-10-28 | [decision] | zsh/bootstrap | Same-user state forgery stays accepted residual risk; hardened with chmod 700 state dir plus wrong-hash prune regression test | `files/.zsh/scripts/environment/bootstrap:318`
- D-20261028-09 | 2026-10-28 | [decision] | zsh/bootstrap | Env fails closed: comment-only or unknown profile aborts rc=2 with valid names; absent ~/.env_name falls back to repo default | `files/.zsh/scripts/environment/bootstrap:106-146`
- D-20261028-08 | 2026-10-28 | [decision] | zsh/bootstrap | Update path backs up prior managed file to <abs>.dotbak before rsync; installs and sames write nothing | `files/.zsh/scripts/environment/bootstrap:272`
- D-20261028-07 | 2026-10-28 | [trap] | zsh/bootstrap | zsh fires function-scoped EXIT traps at function return; the lock was released instantly and guarded nothing | `files/.zsh/scripts/environment/bootstrap:456-460`
- D-20261028-05 | 2026-10-28 | [outcome] | zsh/bootstrap | Installer hardening landed: 177-entry manifest install, destination guard, hash-gated prune, launcher, doctor, six-case runner. | `tests/run.sh`
- D-20261028-06 | 2026-10-28 | [trap] | zsh/bootstrap | `TMUXINATOR_CONFIG` selects `~/.config/tmuxinator/.primary`; root-level `LM.yml` ignored, live `.primary` was stale until installed from repo. | `files/.zsh/env/common:58`

- D-20261028-01 | 2026-10-28 | [trap] | zsh/bootstrap | rsync dest of `$HOME/` + `--delete` trims unrelated home data; 2026-10-26 lost 65,175 paths in `~/mnt/bnk`. Never dest under `$HOME`. | `docs/critique/2026-10-28_bootstrap-scope.md:38`
- D-20261028-02 | 2026-10-28 | [trap] | zsh/bootstrap | Deployed copy can drift from reviewed source (stale 713-line bootstrap ignored argv); deploy launcher exec'ing repo script; `doctor` compares. | `docs/installer/launcher:3`
- D-20261028-03 | 2026-10-28 | [trap] | zsh/bootstrap | Flags inert unless `main` parses argv before any phase; stale copy ignored `--dry-run` and ran a real mirror. Default to dry-run. | `docs/critique/2026-10-28_bootstrap-scope.md:74`
- D-20261028-04 | 2026-10-28 | [decision] | zsh/bootstrap | Prune safe only when path is in previous manifest, absent from new one, and hash matches recorded; never prune outside it. | `files/.zsh/scripts/environment/bootstrap:246`

- D-20261026-01 | 2026-10-26 | [decision] | zsh/prompt | Prompt renders in two lines: `$fill` pushes the signal rail right, `❯` always starts the input line. | `files/.config/starship.toml:6`
- D-20261026-02 | 2026-10-26 | [decision] | zsh/prompt | Path always shows the repo root: `truncation_length = 0` with `truncate_to_repo`, accepting long non-repo paths. | `files/.config/starship.toml:16`
- D-20261026-03 | 2026-10-26 | [decision] | zsh/prompt | Rail order: git branch, status, metrics, state, ruby, nodejs, python, duration, sudo, jobs, status. | `files/.config/starship.toml:7`
- D-20261026-04 | 2026-10-26 | [trap] | zsh/prompt | Listing modules in `format` disables the rest, but `status`, `git_metrics`, and `sudo` ship disabled and need `disable... | `starship print-config` reports `disabled = true` for all three
- D-20261026-05 | 2026-10-26 | [trap] | zsh/prompt | Starship 1.27 defaults inject words into segments: `username` and `hostname` append ` in `, `cmd_duration` adds `took `, `sudo` adds `as `. | `starship print-config`
- D-20261026-06 | 2026-10-26 | [trap] | zsh/prompt | An unreadable config falls back to stock defaults silently with exit 0, so the banned cloud segment can retu... | `STARSHIP_CONFIG=<chmod 000> starship prompt` renders `on ☁️ (us-east-1)`
- D-20261026-07 | 2026-10-26 | [find] | zsh/prompt | Per-prompt cost: `sudo` 8-16ms even when empty; `git_metrics` 12ms typical and 89ms on a 3000-file dirty tree. | `starship timings`
- D-20261026-08 | 2026-10-26 | [trap] | zsh/bootstrap | `bootstrap --only dotfiles --dry-run` hangs past 120s with no output, so dotfile sync is done by... | `~/.zsh/scripts/environment/bootstrap --only dotfiles --dry-run` timed out at 120s
- D-20261026-09 | 2026-10-26 | [decision] | zsh/prompt | Version segments limited to `ruby`, `nodejs`, and `python` with a bare version format; java dropped, no Java in the workspace. | `files/.config/starship.toml:40`
