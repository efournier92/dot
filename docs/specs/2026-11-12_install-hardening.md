# Spec: Lossless, Env-Scoped Dotfile Installer

## Status

Approved for implementation on 2026-11-12 after the redteam walkthrough. Source ledger: `docs/critique/2026-11-12_install-archive-scope.md`.

## Goal

Make `files/.zsh/scripts/environment/bootstrap` a dotfiles-only installer that never loses a file: every prune and overwrite moves a dated copy into `~/.dotfiles_archive/<YYYY-MM-DD>/<relpath>` before anything is removed. Scope installed scripts and env files to the machine's OS (and env via the env file plus the personal overlay). Keep the process minimal and fail-closed.

## Acceptance

`zsh -n files/.zsh/scripts/environment/bootstrap && bash tests/run.sh` passes, and the suite proves:

- A pruned managed file disappears from `$HOME` but its old bytes exist under `~/.dotfiles_archive/<date>/<relpath>`.
- An overwritten managed file keeps its new bytes live and its old bytes in the archive.
- Two same-day writes of one path yield two distinct archive files.
- Dry-run creates no archive directory and writes nothing.
- A `@linux` script is absent on macOS while untagged scripts install.
- `@personal` entries install only for `PERSONAL_ENV_PROFILES`.
- With no `~/.env_name` and no `--env-name`, apply exits 2.
- After apply the entrypoint is a symlink to the repo script and `doctor` is clean.

## Owner-Ratified Decisions

1. Archive root `~/.dotfiles_archive/<date>/<relpath>`; archive prune and overwrite; unique suffix on collision (`.1`, `.2`), never overwrite an archive copy.
2. Strip to dotfiles-only: delete the brew block, `--apps`, `--upgrade-all`, `run_phase`, the run array, and `--only`.
3. Script OS scoping by manifest annotation, no file renames.
4. Require `~/.env_name` or `--env-name`; delete the repo fallback.
5. Delete `verify_dotfiles` and the verify phase; keep `doctor`.
6. Replace the generated launcher with a symlink entrypoint.
7. Fold `personal.manifest` into the main manifest with a `@personal` tag.

## CLI After Change

```
bootstrap [--dry-run|--apply] [--yes] [--env-name NAME] [--repo PATH] [doctor] [--help]
```

Removed: `--apps`, `--upgrade-all`, `--only`, verify phase. `doctor` stays.

## Archive Design

- `ARCHIVE_ROOT="$HOME/.dotfiles_archive"`, `ARCHIVE_DIR="$ARCHIVE_ROOT/$(date +%F)"`.
- Add `ARCHIVE_ROOT` to `FORBIDDEN` so no manifest entry can target it.
- `_assert_archive PATH`: canonicalize; require under `$HOME` and under `ARCHIVE_ROOT`; refuse if `ARCHIVE_ROOT` is a symlink; refuse if under any `FORBIDDEN` root or a `MOUNTS` entry.
- Pre-write validation (before the first file write, apply only): if `ARCHIVE_ROOT` exists and is not a directory or is a symlink, abort; otherwise `mkdir -p "$ARCHIVE_ROOT" "$ARCHIVE_DIR"` and `chmod 700` both.
- `_archive_path REL`: return `$ARCHIVE_DIR/$REL`, appending `.$N` (N from 1) while the candidate exists. Case variants collide harmlessly by taking the next suffix.
- Prune: `_archive_move` the matched file to `_archive_path REL` (single `mv`, same filesystem, atomic), then drop its state line. Archive failure aborts before any removal.
- Overwrite: `_archive_copy` the old file (`cp -pP`) to `_archive_path REL`, leaving the live file in place, then `rsync -a --one-file-system "$src" "$abs.tmp.$$"` and `mv -f` the temp onto `$abs` on success; on failure remove the temp and abort with the live file untouched.
- Install and unchanged actions create no archive.
- Keep the existing "destination exists and is a directory" refusal; it is the guard that stops a directory tree being relocated into the archive.

## Manifest Format

- Line forms: `src`, `src -> dest`, each optionally followed by annotations: `src -> dest @linux @personal`.
- Annotations: `@macos`, `@linux`, `@wsl` (OS gate; explicit overrides filename inference), `@personal` (env gate; applies only when `ENV_NAME` is in `PERSONAL_ENV_PROFILES`).
- Without an OS annotation, infer from a `_mac`/`_macos`/`_linux`/`_wsl` filename token; untagged means every OS.
- Strip annotations before path validation. An unknown `@token` aborts with `log_err` in the pre-write validation loop (fail-closed).
- Fold `personal.manifest`'s 18 lines into the main manifest with `@personal`; delete `docs/installer/personal.manifest`.
- New `_entry_ok REL ANN_SET`: enforce the OS gate (annotation or inference) and the `@personal` gate. Replace `_env_ok`. Remove the `filter_env` parameter and the second `load_manifest` call.

Tag these Linux-only untagged scripts `@linux`: all five under `.zsh/scripts/sound/`, `.zsh/scripts/environment/boot`, `.zsh/scripts/environment/watch_for_change`, `.zsh/scripts/environment/bleachbit_clean`, `.zsh/scripts/environment/system_update`. Leave every other untagged script global.

## Env Selection

- Delete the `files/.env_name` fallback (`bootstrap:127-128`).
- If `~/.env_name` is absent and no `--env-name` is passed, `log_err "no env profile: create ~/.env_name or pass --env-name"` and exit 2.
- Keep `_validate_env` and the comment-only-file failure (exit 2).

## Entrypoint

- `EXPECTED[$ENTRYPOINT_REL]='@symlink'`. On apply, `mkdir -p` the parent, then `ln -sfn "$DOTFILES_SRC/.zsh/scripts/environment/bootstrap" "$HOME/.zsh/scripts/environment/bootstrap"`.
- If a regular file exists there (old launcher), archive-copy it first, then link. Unchanged target means no write.
- Delete `_launcher_content`, `_launcher_hash`, the `@launcher` branch, and `docs/installer/launcher`.
- `doctor` reports drift when the entrypoint is not a symlink or its target is not the current repo script.

## File Changes

- `files/.zsh/scripts/environment/bootstrap`: apply all of the above; delete dead functions and flags. Keep `_assert_dest`, `_hash_file`, `_load_prev`, `_load_plan`, `_doctor`, lock lifecycle, root refusal, and dry-run default.
- `docs/installer/manifest`: fold personal entries with `@personal`; add `@linux` to the nine scripts above.
- Delete `docs/installer/personal.manifest` and `docs/installer/launcher`.
- `README.md`: replace `.dotbak` and `--apps`/`--only`/launcher text with archive, symlink entrypoint, and dotfiles-only usage.
- `docs/discovery/DISCOVERY.md`: append a decision entry linking the ledger.

## Tests

- Rename `test_update_backup` to `test_archive_on_update`: assert old bytes at the dated archive path, new bytes live, no `.dotbak`.
- Rewrite `test_prune_safety`: pruned file gone from `$HOME`, old bytes present in the archive; edited file kept.
- Add `test_archive_same_day`: two same-day updates leave `<rel>` and `<rel>.1` both intact.
- Add `test_dry_run_no_archive`: dry-run leaves no `~/.dotfiles_archive`.
- Add `test_script_os_filter`: fixture manifest with a `@linux` script, an untagged script, and a `_macos` script; on macOS, assert the Linux one is absent and the others present.
- Add `test_personal_gate`: `primary_macos` installs `@personal` entries; a non-personal env does not.
- Add `test_env_required`: no `~/.env_name`, no `--env-name`, exit 2.
- Add `test_symlink_entrypoint`: entrypoint is a symlink to the repo script; `doctor` clean; retarget the link and assert drift.
- Update `test_real_repo` to a per-OS expected set instead of the bare 178 count, and snapshot `$HOME` including the archive tree.
- Extend `has_action_line` with `archived` and `would archive`; extend `snap_tree` to record symlinks and directory presence.

## Non-Goals

- No Homebrew install path. No verify phase. No phase framework.
- Keep the hash-gated state model and all `_assert_dest` guards.
- Keep same-user residuals already accepted in `2026-10-28_install-flow.md`.

## Risks

- The archive grows unbounded by design, holding copies of managed env files at mode 0700. That is the no-loss intent.
- Script scope is OS-only; env scope reaches scripts only through the env file and the `@personal` overlay.
- First apply on a machine with the old launcher archives that generated file before linking.

## Proving Command

```
cd /Users/e/mnt/bnk/cs/dot && zsh -n files/.zsh/scripts/environment/bootstrap && bash tests/run.sh
```
