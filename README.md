# Genesis
This repo contains shell scripts for setting up my preferred development environment on a new system. 

Supports:
* Ubuntu-derivatives 

## Quickstart
To get started run `./genesis` and choose what you want to install.

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
