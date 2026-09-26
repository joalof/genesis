# Genesis
My dotfiles and the setup of my preferred development environment, declared for [mise](https://mise.jdx.dev) and applied with `mise bootstrap`.

Supports:
* Ubuntu-derivatives

## Quickstart
On a fresh machine:
```sh
curl https://mise.run | sh
~/.local/bin/mise bootstrap --from https://github.com/joalof/genesis.git --from-dir ~/code/genesis -E wayland
```
Pass `-E x11` instead on X11. On an existing checkout run `mise bootstrap -C ~/code/genesis -E wayland`, use `--dry-run` to preview, and `mise bootstrap status` to see what's out of sync.

## Layout
```
.
├── mise.toml            # machine setup: directories, apt packages, dotfiles, hooks, bootstrap task
├── mise.wayland.toml    # display-server specific packages, selected with -E
├── mise.x11.toml
├── home/                # dotfiles, mirrors ~
├── scripts/             # post-install scripts (docker, kanata), run as bootstrap hooks
└── mise-tasks/          # source builds (neovim, ghostty)
```

`mise bootstrap` runs, in order: apt packages, the docker script, directories, dotfiles, tools, the kanata (uinput) script, and finally the `bootstrap` task, which installs claude and builds any missing source-built apps. Every step can run again, so bootstrap is safe to re-run; hooks, `postinstall` scripts and the `bootstrap` task must stay idempotent to keep it that way.

## Dotfiles
Every file under `home/` is symlinked to the same path under `~`, so editing a dotfile edits the repo directly. To track a new file, move it into `home/` and run `mise bootstrap -C ~/code/genesis --only dotfiles`.

## Tools
Tools are declared in `home/.config/mise/config.toml`, which becomes the global mise config. Add a tool there and run `mise install`.

### Where are source-built apps installed?
Apps that are built from source (`mise run build-neovim`, `mise run build-ghostty`) are installed into a *flat* application directory `~/apps`, from where binaries and libraries etc are symlinked into `~/.local` by the `symfarm` script (in `home/.local/bin`). This makes them easy to uninstall (just run `symfarm -D path/to/app`).
