# Discovery

One line per finding, decision, assumption, trap, question, or outcome. Newest first. Evidence required.
Scope tokens: zsh/bootstrap, zsh/prompt

## Entries

- D-20261026-01 | 2026-10-26 | [decision] | zsh/prompt | Prompt renders in two lines: `$fill` pushes the signal rail right, `❯` always starts the input line. | `files/.config/starship.toml:6`
- D-20261026-02 | 2026-10-26 | [decision] | zsh/prompt | Path always shows the repo root: `truncation_length = 0` with `truncate_to_repo`, accepting long non-repo paths. | `files/.config/starship.toml:16`
- D-20261026-03 | 2026-10-26 | [decision] | zsh/prompt | Rail order: git branch, status, metrics, state, ruby, nodejs, python, duration, sudo, jobs, status. | `files/.config/starship.toml:7`
- D-20261026-04 | 2026-10-26 | [trap] | zsh/prompt | Listing modules in `format` disables the rest, but `status`, `git_metrics`, and `sudo` ship disabled and need `disable... | `starship print-config` reports `disabled = true` for all three
- D-20261026-05 | 2026-10-26 | [trap] | zsh/prompt | Starship 1.27 defaults inject words into segments: `username` and `hostname` append ` in `, `cmd_duration` adds `took `, `sudo` adds `as `. | `starship print-config`
- D-20261026-06 | 2026-10-26 | [trap] | zsh/prompt | An unreadable config falls back to stock defaults silently with exit 0, so the banned cloud segment can retu... | `STARSHIP_CONFIG=<chmod 000> starship prompt` renders `on ☁️ (us-east-1)`
- D-20261026-07 | 2026-10-26 | [find] | zsh/prompt | Per-prompt cost: `sudo` 8-16ms even when empty; `git_metrics` 12ms typical and 89ms on a 3000-file dirty tree. | `starship timings`
- D-20261026-08 | 2026-10-26 | [trap] | zsh/bootstrap | `bootstrap --only dotfiles --dry-run` hangs past 120s with no output, so dotfile sync is done by... | `~/.zsh/scripts/environment/bootstrap --only dotfiles --dry-run` timed out at 120s
- D-20261026-09 | 2026-10-26 | [decision] | zsh/prompt | Version segments limited to `ruby`, `nodejs`, and `python` with a bare version format; java dropped, no Java in the workspace. | `files/.config/starship.toml:40`
