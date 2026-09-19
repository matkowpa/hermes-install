#Requires -Version 5.1
<#
.SYNOPSIS
    Generic installer for the Hermes application: clone, install dependencies, configure.
.EXAMPLE
    .\install-hermes.ps1 -RepoUrl https://github.com/org/hermes.git
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl,

    [string]$InstallPath = (Join-Path (Get-Location) 'hermes'),

    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'

function Write-Step { param([string]$Message) Write-Host "==> $Message" }

# --- Step 1: Clone (or update) -------------------------------------------------
if (Test-Path (Join-Path $InstallPath '.git')) {
    Write-Step "Updating existing repository at $InstallPath"
    git -C $InstallPath pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw "git pull failed in $InstallPath" }
}
else {
    Write-Step "Cloning $RepoUrl into $InstallPath"
    git clone $RepoUrl $InstallPath
    if ($LASTEXITCODE -ne 0) { throw "git clone of $RepoUrl failed" }
}

# --- Step 2: Install dependencies ---------------------------------------------
Write-Step "Installing dependencies in $InstallPath"

$packageJson = Join-Path $InstallPath 'package.json'
$requirements = Join-Path $InstallPath 'requirements.txt'
$pyproject    = Join-Path $InstallPath 'pyproject.toml'
$csproj       = Get-ChildItem -Path $InstallPath -Filter '*.csproj' -File -ErrorAction SilentlyContinue |
                Select-Object -First 1

if (Test-Path $packageJson) {
    $lockFile = Join-Path $InstallPath 'package-lock.json'
    if (Test-Path $lockFile) {
        Write-Step 'Detected package.json + package-lock.json -> npm ci'
        npm ci --prefix $InstallPath
    }
    else {
        Write-Step 'Detected package.json -> npm install'
        npm install --prefix $InstallPath
    }
    if ($LASTEXITCODE -ne 0) { throw 'npm dependency install failed' }
}
elseif (Test-Path $requirements) {
    Write-Step 'Detected requirements.txt -> pip install -r'
    pip install -r $requirements
    if ($LASTEXITCODE -ne 0) { throw 'pip dependency install failed' }
}
elseif (Test-Path $pyproject) {
    Write-Step 'Detected pyproject.toml -> pip install .'
    pip install $InstallPath
    if ($LASTEXITCODE -ne 0) { throw 'pip install of pyproject failed' }
}
elseif ($csproj) {
    Write-Step "Detected $($csproj.Name) -> dotnet restore"
    dotnet restore $csproj.FullName
    if ($LASTEXITCODE -ne 0) { throw 'dotnet restore failed' }
}
else {
    Write-Warning 'No known dependency manifest found (package.json, requirements.txt, pyproject.toml, *.csproj) - skipping dependency install.'
}

# --- Step 3: Configure ----------------------------------------------------------
$configTarget = Join-Path $InstallPath 'hermes.config.json'
if ($ConfigPath) {
    if (-not (Test-Path $ConfigPath)) { throw "Config file not found: $ConfigPath" }
    Write-Step "Copying config $ConfigPath -> $configTarget"
    Copy-Item -Path $ConfigPath -Destination $configTarget -Force
}
elseif (-not (Test-Path $configTarget)) {
    Write-Step 'No config provided - creating placeholder hermes.config.json'
    @'
{
  "_comment": "Placeholder configuration for Hermes. Edit as needed.",
  "name": "hermes",
  "environment": "development"
}
'@ | Out-File -FilePath $configTarget -Encoding utf8
}

Write-Step "Done. Hermes installed at $InstallPath"
