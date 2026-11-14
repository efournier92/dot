# Discovery

One line per finding, decision, assumption, trap, question, or outcome. Newest first. Evidence required.
Scope tokens: tmux/agents, zsh/bootstrap, zsh/prompt, macos/apps

## Entries

- D-20261113-02 | 2026-11-13 | [decision] | tmux/agents | Dropped Option+J/K/L session cycling. The sesh picker on Option+Space is the only session switch, freeing keys for the agent sidebar toggle | files/.tmux.conf:242
- D-20261113-01 | 2026-11-13 | [decision] | tmux/agents | Show/hide in all windows moved to Alt+pipe so both toggles sit on one physical key. Alt+backslash still focuses the sidebar | files/.tmux.conf:272
- D-20261112-16 | 2026-11-12 | [find] | zsh/bootstrap | `_archive_path` fixes the date dir once at startup, so a midnight-spanning apply archives into the start date | `files/.zsh/scripts/environment/bootstrap:168`
- D-20261112-15 | 2026-11-12 | [outcome] | zsh/bootstrap | Installer redteam converged: 37 resolved, 6 owner decisions, suite 27/27. Supersedes `.dotbak`, repo env fallback, and the 178-count oracle | `bash tests/run.sh` -> PASS 27/27
- D-20261112-14 | 2026-11-12 | [decision] | zsh/bootstrap | Installer lossless: prune and overwrite archive to ~/.dotfiles_archive, dotfiles-only, OS-gated scripts, symlink entrypoint | `docs/critique/2026-11-12_install-archive-scope.md`
- D-20261112-13 | 2026-11-12 | [decision] | macos/apps | Raycast joins CASKS. Its `.rayconfig` export is a dated restore artifact in `history/`, live settings self-sync | `files/.zsh/scripts/environment/bootstrap:17`
- D-20261112-12 | 2026-11-12 | [outcome] | tmux/agents | Redteam converged: 24 findings, 12 fixed, 12 rejected with evidence, suite 18 to 21 cases | `bash tests/run.sh` -> PASS 21/21
- D-20261112-01 | 2026-11-12 | [decision] | tmux/agents | Herdr parity via pure TPM stack: hiroppy sidebar, resurrect plus continuum, timvw resume, pinned by tag or SHA | `files/.tmux.conf:287`
- D-20261112-04 | 2026-11-12 | [decision] | tmux/agents | Sidebar is opt-in: @sidebar_auto_create off means no automatic panes, and the plugin's default prefix e and E are unbound after load | `files/.tmux.conf:264`
- D-20261112-05 | 2026-11-12 | [decision] | tmux/agents | Hide the Activity and Git bottom panel by default with `@sidebar_bottom_height 0`, verified by a rendered sidebar having no tabs | `files/.tmux.conf:265`
- D-20261112-11 | 2026-11-12 | [decision] | tmux/agents | Window and session entry hooks move focus off the sidebar so the active-row accent tracks the real pane instead of freezing | `files/.zsh/scripts/environment/tmux_sidebar_unfocus`
- D-20261112-10 | 2026-11-12 | [decision] | tmux/agents | Sidebar OS notifications disabled with @sidebar_notifications off, since the plugin shells out to osascript and notify-send | `files/.tmux.conf:266`
- D-20261112-09 | 2026-11-12 | [decision] | tmux/agents | Auto-restore disabled after a reboot replayed layout and typed opencode --session commands into panes, manual prefix C-r restore retained | `files/.tmux.conf:283`
- D-20261112-02 | 2026-11-12 | [trap] | tmux/agents | hiroppy's TPM entry opens an install-wizard when its binary is missing or mismatched, so setup pre-places the release binary | `files/.zsh/scripts/environment/tmux_agent_setup:47`
- D-20261112-03 | 2026-11-12 | [find] | tmux/agents | Install count was manifest plus launcher (178+1), so a manifest change bumped test_real_repo. Superseded by a per-OS expected set (D-20261112-15) | `tests/run.sh:703`

- D-20261028-12 | 2026-10-28 | [decision] | zsh/bootstrap | Pre-rename work-profile dir retired for repo `.work`. Manual backup-gated removal, installer never tracked it | `bash tests/run.sh` -> PASS 18/18
- D-20261028-11 | 2026-10-28 | [outcome] | zsh/bootstrap | Install-flow redteam converged: 30 findings, 25 fixed, 5 rejected (1 owner-ratified). Suite grew 6 to 18 cases | `bash tests/run.sh` -> PASS 18/18
- D-20261028-10 | 2026-10-28 | [decision] | zsh/bootstrap | Same-user state forgery stays accepted residual risk. Hardened with chmod 700 state dir plus wrong-hash prune regression test | `files/.zsh/scripts/environment/bootstrap:318`
- D-20261028-09 | 2026-10-28 | [decision] | zsh/bootstrap | Env fails closed: bad or unknown profile aborts rc=2. First apply with --env-name seeds an absent ~/.env_name without overwriting | `files/.zsh/scripts/environment/bootstrap:101`
- D-20261028-08 | 2026-10-28 | [decision] | zsh/bootstrap | Update path backs up prior managed file to <abs>.dotbak before rsync. Installs and sames write nothing | `files/.zsh/scripts/environment/bootstrap:272`
- D-20261028-07 | 2026-10-28 | [trap] | zsh/bootstrap | zsh fires function-scoped EXIT traps at function return. The lock was released instantly and guarded nothing | `files/.zsh/scripts/environment/bootstrap:456-460`
- D-20261028-05 | 2026-10-28 | [outcome] | zsh/bootstrap | Installer hardening landed: 177-entry manifest install, destination guard, hash-gated prune, launcher, doctor, six-case runner. | `tests/run.sh`
- D-20261028-06 | 2026-10-28 | [trap] | zsh/bootstrap | `TMUXINATOR_CONFIG` selects `~/.config/tmuxinator/.primary`. Root-level `LM.yml` ignored, live `.primary` was stale until installed from repo. | `files/.zsh/env/common:58`

- D-20261028-01 | 2026-10-28 | [trap] | zsh/bootstrap | `$HOME/` + `--delete` trims unrelated home data. A 2026-10-26 run lost 65,175 paths in `~/mnt/bnk`. Never dest under `$HOME`. | `docs/critique/2026-10-28_bootstrap-scope.md:38`
- D-20261028-02 | 2026-10-28 | [trap] | zsh/bootstrap | Deployed copy can drift from reviewed source (stale 713-line bootstrap ignored argv). The deploy launcher exec's the repo script. `doctor` compares. | `docs/installer/launcher:3`
- D-20261028-03 | 2026-10-28 | [trap] | zsh/bootstrap | Flags inert unless `main` parses argv before any phase. A stale copy ignored `--dry-run` and ran a real mirror. Default to dry-run. | `docs/critique/2026-10-28_bootstrap-scope.md:74`
- D-20261028-04 | 2026-10-28 | [decision] | zsh/bootstrap | Prune safe only when path is in previous manifest, absent from new one, and hash matches recorded. Never prune outside it. | `files/.zsh/scripts/environment/bootstrap:246`

- D-20261026-01 | 2026-10-26 | [decision] | zsh/prompt | Prompt renders in two lines: `$fill` pushes the signal rail right, `❯` always starts the input line. | `files/.config/starship.toml:6`
- D-20261026-02 | 2026-10-26 | [decision] | zsh/prompt | Path always shows the repo root: `truncation_length = 0` with `truncate_to_repo`, accepting long non-repo paths. | `files/.config/starship.toml:16`
- D-20261026-03 | 2026-10-26 | [decision] | zsh/prompt | Rail order: git branch, status, metrics, state, ruby, nodejs, python, duration, sudo, jobs, status. | `files/.config/starship.toml:7`
- D-20261026-04 | 2026-10-26 | [trap] | zsh/prompt | Listing modules in `format` disables the rest. `status`, `git_metrics`, and `sudo` ship disabled and need enabling | `starship print-config` shows them `disabled = true`
- D-20261026-05 | 2026-10-26 | [trap] | zsh/prompt | Starship 1.27 defaults inject words into segments: `username` and `hostname` append ` in `, `cmd_duration` adds `took `, `sudo` adds `as `. | `starship print-config`
- D-20261026-06 | 2026-10-26 | [trap] | zsh/prompt | Unreadable config falls back to stock defaults at exit 0, so the banned cloud segment can return | `STARSHIP_CONFIG=<chmod 000> starship prompt` renders `on ☁️ (us-east-1)`
- D-20261026-07 | 2026-10-26 | [find] | zsh/prompt | Per-prompt cost: `sudo` 8-16ms even when empty. `git_metrics` 12ms typical and 89ms on a 3000-file dirty tree. | `starship timings`
- D-20261026-08 | 2026-10-26 | [trap] | zsh/bootstrap | `bootstrap --only dotfiles --dry-run` hangs past 120s with no output, so dotfile sync is done by... | `~/.zsh/scripts/environment/bootstrap --only dotfiles --dry-run` timed out at 120s
- D-20261026-09 | 2026-10-26 | [decision] | zsh/prompt | Version segments limited to `ruby`, `nodejs`, and `python` with a bare version format. Java dropped, no Java in the workspace. | `files/.config/starship.toml:40`
