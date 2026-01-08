# configs — quick reference

Manage dotfiles with GNU Stow. Packages are organized so their contents map to target paths.

Essential commands
- Preview: `stow --simulate home` (or `stow -n home`)
- Link user files: `stow home --adopt`
- Link system files (root): `sudo stow system -t / --adopt`
- Unlink/remove package: `stow -D home`
- Explicit dir/target: `stow -d ~/configs -t ~ home`

Notes
- `--adopt` moves existing files into the package—backup before using.
- Use `--simulate` to avoid surprises.
- Package layout: put files under `home/` to map into `~`, `system/` for /etc-style targets.
- Run `ya pkg install` for yazi to function

Short TODO
- Add per-package README templates.
- Add top-level install script (simulate/apply/rollback).
- Add CI to run `stow --simulate` and scan for accidental secrets.
- Add a small restore/troubleshoot helper for broken symlinks.
- Provide an easy helper to stow/un-stow a single package inside `home` (current `stow -D home` operates on all packages).
- Fix gsconnect clipboard sharing
- Enable gsconnect bluetooth connection
- Unify copy/paste shortcuts across zsh, alacritty, zed
