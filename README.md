# hermes-install

A generic installer skill for [Cline](https://github.com/cline/cline): clones an application
repository ("Hermes"), installs its dependencies, and applies configuration — idempotently,
on Windows (PowerShell).

## What's in this repo

| File | Purpose |
|---|---|
| `README.md` | This documentation |
| `install-hermes.ps1` | The installer script: clone → deps → configure |
| `.clinerules/workflows/hermes-install.md` | Cline workflow that drives the installer |

## Installing the skill

Copy the workflow into a Cline-enabled project so `/hermes-install` can be invoked there:

```
<target-project>\.clinerules\workflows\hermes-install.md
```

Or clone this repo and copy from here.

## Usage

Direct (PowerShell):

```powershell
.\install-hermes.ps1 -RepoUrl https://github.com/<org>/hermes.git `
                     -InstallPath C:\apps\hermes `
                     -ConfigPath .\hermes.config.json
```

In Cline: type `/hermes-install` and provide the repository URL (and optionally an
install path and config file) when asked.

## What the script does

1. **Clone** — clones `-RepoUrl` into `-InstallPath` (default: `.\hermes`). If the
   directory already contains a git repo, it pulls the latest changes instead of
   re-cloning (idempotent re-runs).
2. **Install dependencies** — detects the project manifest and runs the matching
   installer: `package.json` → `npm ci` (falls back to `npm install`),
   `requirements.txt` → `pip install -r`, `pyproject.toml` → `pip install .`,
   `*.csproj` → `dotnet restore`.
3. **Configure** — if `-ConfigPath` is given, copies the config file into the
   install directory as `hermes.config.json`; otherwise creates a commented
   placeholder template so the app has a config to start from.

The script stops on the first error (`$ErrorActionPreference = 'Stop'`) and prints
the step it is executing.

## Requirements

- Windows with PowerShell 5.1+ (built into Windows)
- `git` on `PATH`
- Node.js / Python / .NET SDK — only whichever the target Hermes app needs

## Parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `-RepoUrl` | yes | — | Git URL of the Hermes application repository |
| `-InstallPath` | no | `.\hermes` | Where to clone/install |
| `-ConfigPath` | no | *(none)* | Config file to copy into the install directory |
