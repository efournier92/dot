# Dot

## Contents

- [Overview](#overview)
- [Contribute](#contribute)
- [License](#license)
- [Notes](#notes)

## Overview

This repo tracks the dotfiles and configuration I use across machines. The [`files/`](./files) directory holds the live dotfiles (`.vimrc`, `.tmux.conf`, `.zshenv`, `.gitconfig`, etc.), and the [`history/`](./history) directory contains dated snapshots of how this config has evolved over time.

## Installer

The installer lives at [`files/.zsh/scripts/environment/bootstrap`](./files/.zsh/scripts/environment/bootstrap). It installs only the exact files named in [`docs/installer/manifest`](./docs/installer/manifest) and records each installed path and hash in `${XDG_STATE_HOME:-$HOME/.local/state}/dot/installed.manifest`. It never mirrors a directory, never uses `--delete`, and never writes `$HOME` or an ancestor as an rsync destination. Only dotfiles are installed. There is no apps or upgrade phase.

The deployed entrypoint at `~/.zsh/scripts/environment/bootstrap` is a symlink to the repo script, so the code that runs cannot drift from the checkout.

Before any managed file is removed or overwritten, its previous bytes move to `~/.dotfiles_archive/<YYYY-MM-DD>/<relpath>`. A prune moves the file there and a same-day repeat gets a `.1`, `.2` suffix, so no archived copy is ever overwritten. An overwrite copies the old file there, then writes the new file through a temp file and moves it into place, so a failed write never destroys the live file.

### Usage

Dry-run is the default. Nothing is written without `--apply`.

```sh
./files/.zsh/scripts/environment/bootstrap --dry-run
./files/.zsh/scripts/environment/bootstrap --apply --yes --env-name primary_macos
./files/.zsh/scripts/environment/bootstrap doctor
```

| Flag | Behavior |
| --- | --- |
| `--dry-run` | Show pending changes and write nothing (default). |
| `--apply` | Write changes. Requires `--yes` off a TTY. |
| `--yes` | Skip confirmation prompts for non-interactive runs. |
| `--env-name NAME` | Select the zsh environment profile without a menu. |
| `--repo PATH` | Use `PATH` as the dotfiles repo root. |
| `doctor` | Report entrypoint and manifest drift without writing. |

Run `tmux_agent_setup` once per machine after the dotfiles install. It fetches TPM, the pinned tmux plugins, and the agent sidebar binary.

### State And Pruning

The state manifest is the only prune authority. A file is moved to the archive, then removed, only when it is in the previous manifest, absent from the new manifest, and its current hash matches the recorded hash. A user-edited file is kept and dropped from state. Paths outside the previous manifest are never removed.

An update to an existing managed file first copies the current version to `~/.dotfiles_archive/<YYYY-MM-DD>/<relpath>`. A second same-day write of the same path takes the next `.N` suffix. Installs and unchanged applies create no archive copy.

Scripts are gated by OS through manifest annotations (`@macos`, `@linux`, `@wsl`) or a filename suffix. Entries tagged `@personal` install only when the selected profile is one of `PERSONAL_ENV_PROFILES`.

### Env Profile Selection

The env profile is the first non-comment, non-empty line of `~/.env_name`, or the `--env-name` flag. On first apply with `--env-name`, the installer writes that name to `~/.env_name` when absent and never overwrites it. With neither present the installer exits 2. There is no repo fallback. Selection fails closed with exit code 2 when `~/.env_name` exists but yields no value (comment-only or empty), or when a resolved or `--env-name`-passed profile is not a basename of `files/.zsh/env/*` (excluding `common` and `common_<os>`) or one of the personal profiles.

## Contribute

If you have feature suggestions, please contact me here or at efournier92@gmail.com. If you'd like to submit a pull request, please feel free to, and I'll review merge it at my earliest convenience!

## License

This project is provided under the [MIT](https://opensource.org/licenses/MIT) licence and I hereby grant rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software without limitation, provided the resulting software also carries the same open-source licensing statement.

## Notes

- [.vimrc](https://github.com/efournier92/dot/blob/main/files/.vimrc)
- [.tmux.conf](https://github.com/efournier92/dot/blob/main/files/.tmux.conf)
- [.zshenv](https://github.com/efournier92/dot/blob/main/files/.zshenv)
- [.gitconfig](https://github.com/efournier92/dot/blob/main/files/.gitconfig)
- [.env_name.example](https://github.com/efournier92/dot/blob/main/files/.env_name.example)
- [.vim/](https://github.com/efournier92/dot/tree/main/files/.vim)
- [.tmux/](https://github.com/efournier92/dot/tree/main/files/.tmux)
- [.zsh/](https://github.com/efournier92/dot/tree/main/files/.zsh)
