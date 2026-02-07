# Genesis
This repo contains shell scripts for setting up my preferred development environment on a new system. 

Supports:
* Ubuntu-derivatives 

## Quickstart
To get started run `./genesis` and choose what you want to install.

## Configuration
Certain settings can be customized via the `config.json` file such as which github repo to install dotfiles from (must be chezmoi-compliant) and default installation directories.

## App system
Installation scripts for apps and tool chains are organized in the following directory structre:
.
├── apps
│   ├── app1
│   │   ├── install.sh
│   │   └── manifest.json
│   ├── app2
│   │   ├── install.sh
│   │   └── manifest.json

Here, `manifest.json` contains a minimal set of metadata required for `genesis` to manage the installation process.
```json {
    "name": "app_name",
    "dependencies": ["dep1_app_name", "dep2_app_name"],
    "artifacts": ["binary1", "script2"],
    "platforms": ["linux", "wsl"]
}
```
Note that the dependencies are listed using their app name as defined in the manifest, not with binaries. 

### Where are apps installed?
Genesis sets up a local FHS system under a configurable directory `LOCAL_FHS` (by default `~/.local`) as well as a *flat* application directory `APPS` which defaults to `~/apps`. Applications that are built from source or downloaded as archives are then installed into `APPS` from where binaries and libraries etc are symlinked into `LOCAL_FHS` by the `symfarm` script. This has various benefits like making applications easy to uninstall (just run `symfarm -D path/to/app`).
