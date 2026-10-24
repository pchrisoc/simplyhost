#Requires -Version 5.1
[CmdletBinding()]
param([switch]$NoPrompt, [switch]$AddCommand, [switch]$Help)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($Help) {
    'Usage: nvim.ps1 [-NoPrompt] [-AddCommand]'
    'Installs native Windows Neovim, Git, and the SimplyHost LazyVim config. Existing config is backed up.'
    return
}
if ($env:OS -ne 'Windows_NT') { throw 'Use nvim.sh on macOS/Linux.' }
$installerSource = $PSCommandPath
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Save-Backup([string]$Path) {
    $backup = $Path + '.bak'
    $number = 1
    while (Test-Path -LiteralPath $backup) { $backup = $Path + '.bak.' + $number; $number++ }
    Move-Item -LiteralPath $Path -Destination $backup
    Write-Host "Backed up $Path to $backup"
}
function Find-Program([string]$Name, [string[]]$Candidates) {
    $command = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    foreach ($candidate in $Candidates) { if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate } }
}
function Ensure-Program([string]$Name, [string]$Package, [string[]]$Candidates) {
    $program = Find-Program $Name $Candidates
    if ($program) { return $program }
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw "Install $Package or App Installer (winget), then rerun." }
    & winget.exe install --id $Package --exact --source winget --accept-package-agreements --accept-source-agreements | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "$Package installation failed." }
    $env:PATH = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + $env:PATH
    $program = Find-Program $Name $Candidates
    if (-not $program) { throw "$Name is not available after installation. Reopen PowerShell and rerun." }
    return $program
}
$neovim = Ensure-Program 'nvim.exe' 'Neovim.Neovim' @(
    (Join-Path $env:ProgramFiles 'Neovim\bin\nvim.exe'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Neovim\bin\nvim.exe'))
$git = Ensure-Program 'git.exe' 'Git.Git' @((Join-Path $env:ProgramFiles 'Git\cmd\git.exe'))
$versionOutput = (& $neovim --version) -join "`n"
if ($LASTEXITCODE -ne 0) { throw 'Neovim cannot start.' }
if ($versionOutput -notmatch 'NVIM v(\d+\.\d+\.\d+)' -or [version]$Matches[1] -lt [version]'0.11.2') {
    throw 'LazyVim requires Neovim 0.11.2+. Run: winget upgrade --id Neovim.Neovim --exact, then rerun.'
}
Write-Host ($versionOutput.Split("`n")[0])
$gitVersion = (& $git --version) -join "`n"
if ($LASTEXITCODE -ne 0 -or $gitVersion -notmatch 'git version (\d+\.\d+\.\d+)' -or [version]$Matches[1] -lt [version]'2.19.0') {
    throw 'LazyVim requires Git 2.19+. Run: winget upgrade --id Git.Git --exact, then rerun.'
}
# Persist paths for existing installations not already on the user/machine PATH.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$permanentPath = $userPath + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
foreach ($program in @($neovim, $git)) {
    $directory = Split-Path -Parent $program
    if (-not (($permanentPath -split ';') | Where-Object { $_.TrimEnd('\') -eq $directory.TrimEnd('\') })) {
        $userPath = $directory + ';' + $userPath
        [Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
        $permanentPath = $directory + ';' + $permanentPath
    }
    $env:PATH = $directory + ';' + $env:PATH
}
$staging = Join-Path ([IO.Path]::GetTempPath()) ('simplyhost-nvim-' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($staging) | Out-Null
try {
    $configSource = Join-Path (Split-Path -Parent $installerSource) '..\config\nvim'
    if (-not (Test-Path -LiteralPath (Join-Path $configSource 'init.lua'))) {
        $zip = Join-Path $staging 'source.zip'
        Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/pchrisoc/simplyhost/archive/refs/heads/main.zip' -OutFile $zip
        Expand-Archive -LiteralPath $zip -DestinationPath $staging
        $configSource = Join-Path $staging 'simplyhost-main\config\nvim'
    }
    $plugins = @('colorscheme','completion','dashboard','simplyhost-options')
    foreach ($required in @('init.lua','lua\config\lazy.lua') + @($plugins | ForEach-Object { 'lua\plugins\' + $_ + '.lua' })) {
        if (-not (Test-Path -LiteralPath (Join-Path $configSource $required))) { throw "Config missing $required; existing config has not been changed." }
    }
    # Neovim honors XDG_CONFIG_HOME and NVIM_APPNAME on Windows too.
    $configHome = $env:LOCALAPPDATA
    if ($env:XDG_CONFIG_HOME) { $configHome = $env:XDG_CONFIG_HOME }
    $appName = 'nvim'
    if ($env:NVIM_APPNAME) { $appName = $env:NVIM_APPNAME }
    if ($appName -match '[/\\]' -or $appName -in @('.','..')) { throw 'NVIM_APPNAME must be a directory name.' }
    $target = Join-Path $configHome $appName
    $lazy = Join-Path $target 'lua\config\lazy.lua'
    if ((Test-Path -LiteralPath $lazy) -and [IO.File]::ReadAllText($lazy).Contains('LazyVim/LazyVim')) {
        [IO.Directory]::CreateDirectory((Join-Path $target 'lua\plugins')) | Out-Null
        foreach ($plugin in $plugins) {
            $relative = 'lua\plugins\' + $plugin + '.lua'
            $source = Join-Path $configSource $relative
            $destination = Join-Path $target $relative
            if ((Test-Path -LiteralPath $destination) -and (Get-FileHash -LiteralPath $destination).Hash -eq (Get-FileHash -LiteralPath $source).Hash) { continue }
            if (Test-Path -LiteralPath $destination) { Save-Backup $destination }
            Copy-Item -LiteralPath $source -Destination $destination
        }
    } else {
        if (Test-Path -LiteralPath $target) { Save-Backup $target }
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        Copy-Item -LiteralPath $configSource -Destination $target -Recurse
    }
    Write-Host "Installed SimplyHost LazyVim in $target. Run nvim; plugins install on first launch."
    Write-Host 'Tree-sitter needs tree-sitter-cli and a C compiler. Search features can use ripgrep and fd. Run :LazyHealth in Neovim to inspect plugin dependencies.'
} finally { Remove-Item -LiteralPath $staging -Recurse -Force }
if ($AddCommand -or (-not $NoPrompt -and -not [Console]::IsInputRedirected -and (Read-Host 'Add sh-nvim to your PowerShell profile for repeat use? [y/N]') -match '^(y|yes)$')) {
    $saved = Join-Path $env:LOCALAPPDATA 'SimplyHost\scripts\nvim.ps1'
    [IO.Directory]::CreateDirectory((Split-Path -Parent $saved)) | Out-Null
    if ([IO.Path]::GetFullPath($installerSource) -ne [IO.Path]::GetFullPath($saved)) { Copy-Item -LiteralPath $installerSource -Destination $saved -Force }
    $profilePath = $PROFILE.CurrentUserAllHosts
    [IO.Directory]::CreateDirectory((Split-Path -Parent $profilePath)) | Out-Null
    $content = ''
    if (Test-Path -LiteralPath $profilePath) { $content = [IO.File]::ReadAllText($profilePath) }
    $block = "# BEGIN SimplyHost nvim command`r`nfunction global:sh-nvim { & '" + $saved.Replace("'", "''") + "' @args }`r`n# END SimplyHost nvim command"
    $pattern = '(?ms)^# BEGIN SimplyHost nvim command\r?\n.*?^# END SimplyHost nvim command(?=\r?$)'
    if ([regex]::IsMatch($content, $pattern)) { $content = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block }) }
    else { $content += "`r`n" + $block + "`r`n" }
    if ((Test-Path -LiteralPath $profilePath) -and [IO.File]::ReadAllText($profilePath) -ne $content) { Copy-Item -LiteralPath $profilePath -Destination ($profilePath + '.simplyhost-' + [guid]::NewGuid().ToString('N') + '.bak') }
    [IO.File]::WriteAllText($profilePath, $content, (New-Object System.Text.UTF8Encoding($true)))
    Write-Host 'Saved sh-nvim. Open a new PowerShell session to use it.'
}
