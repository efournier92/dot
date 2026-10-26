# Dot

## Contents

- [Overview](#overview)
- [Contribute](#contribute)
- [License](#license)
- [Notes](#notes)

## Overview

This repo tracks the dotfiles and configuration I use across machines. The [`files/`](./files) directory holds the live dotfiles (`.vimrc`, `.tmux.conf`, `.zshenv`, `.gitconfig`, etc.), and the [`history/`](./history) directory contains dated snapshots of how this config has evolved over time.

## Installer

The installer lives at [`files/.zsh/scripts/environment/bootstrap`](./files/.zsh/scripts/environment/bootstrap). It mirrors only the paths listed in its managed manifest, backs up replaced files, and verifies the result. It never writes unrelated files in your home directory.

### Usage

```sh
./files/.zsh/scripts/environment/bootstrap --help
```

| Flag | Behavior |
| --- | --- |
| `--dry-run` | Show pending changes and write nothing. |
| `--yes` | Skip confirmation prompts for non-interactive runs. |
| `--apps` | Install the configured Homebrew formulae and casks. |
| `--upgrade-all` | Run `brew upgrade` during the apps phase. |
| `--env-name NAME` | Select the zsh environment profile without the menu. |
| `--repo PATH` | Use `PATH` as the dotfiles repo root. |
| `--only PHASE` | Run only `brew`, `dotfiles`, or `verify`. |
| `--resume` | Skip phases already recorded as complete. |
| `--uninstall` | Restore managed paths from the newest backup. |

### Recovery

Every run archives replaced files under `~/.dotfiles.bak/dotfiles_<timestamp>/`, and `~/.dotfiles.bak/latest` contains the newest archive path. `--uninstall` restores the managed paths and the mapped `~/.config/git/config` from that archive without deleting anything else. `~/.env_name` is machine-local, is preserved across runs, and cannot be restored from a backup.

Phase progress is stored in `~/.dotfiles.bak/.bootstrap-state`. If a run stops partway, re-run with `--resume` to skip the phases that already completed; `verify` always runs again. Use `--dry-run` first when you want to inspect the pending changes before writing.

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
