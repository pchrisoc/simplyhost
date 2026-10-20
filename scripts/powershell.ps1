#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ExportPath,
    [switch]$InstallPrompt,
    [switch]$AddCommand,
    [switch]$NoPrompt,
    [switch]$Help
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($Help) {
    Write-Output 'Usage: .\powershell.ps1 [-ExportPath NEW_DIRECTORY] [-InstallPrompt] [-AddCommand] [-NoPrompt] [-WhatIf]'
    Write-Output 'Adds a Windows Terminal profile matching the captured iTerm2 appearance; optionally configures your PowerShell prompt and a repeat command.'
    return
}
$preset = @'
{
  "schema_version": 1,
  "iterm2": {
    "Profiles": [
      {
        "ASCII Anti Aliased": true,
        "ASCII Ligatures": true,
        "Ansi 0 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 0 Color (Dark)": {
          "Blue Component": 0.25882352941176473,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.027450980392156862
        },
        "Ansi 0 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 1 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 1 Color (Dark)": {
          "Blue Component": 0.1843137254901961,
          "Color Space": "sRGB",
          "Green Component": 0.19607843137254902,
          "Red Component": 0.8627450980392157
        },
        "Ansi 1 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 10 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 10 Color (Dark)": {
          "Blue Component": 0.4588235294117647,
          "Color Space": "sRGB",
          "Green Component": 0.43137254901960786,
          "Red Component": 0.34509803921568627
        },
        "Ansi 10 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 11 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 11 Color (Dark)": {
          "Blue Component": 0.5137254901960784,
          "Color Space": "sRGB",
          "Green Component": 0.4823529411764706,
          "Red Component": 0.396078431372549
        },
        "Ansi 11 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 12 Color": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 12 Color (Dark)": {
          "Blue Component": 0.5882352941176471,
          "Color Space": "sRGB",
          "Green Component": 0.5803921568627451,
          "Red Component": 0.5137254901960784
        },
        "Ansi 12 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 13 Color": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Ansi 13 Color (Dark)": {
          "Blue Component": 0.7686274509803922,
          "Color Space": "sRGB",
          "Green Component": 0.44313725490196076,
          "Red Component": 0.4235294117647059
        },
        "Ansi 13 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Ansi 14 Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 14 Color (Dark)": {
          "Blue Component": 0.6313725490196078,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.5764705882352941
        },
        "Ansi 14 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 15 Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 15 Color (Dark)": {
          "Blue Component": 0.8901960784313725,
          "Color Space": "sRGB",
          "Green Component": 0.9647058823529412,
          "Red Component": 0.9921568627450981
        },
        "Ansi 15 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 2 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 2 Color (Dark)": {
          "Blue Component": 0.0,
          "Color Space": "sRGB",
          "Green Component": 0.6,
          "Red Component": 0.5215686274509804
        },
        "Ansi 2 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 3 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 3 Color (Dark)": {
          "Blue Component": 0.0,
          "Color Space": "sRGB",
          "Green Component": 0.5372549019607843,
          "Red Component": 0.7098039215686275
        },
        "Ansi 3 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 4 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 4 Color (Dark)": {
          "Blue Component": 0.8235294117647058,
          "Color Space": "sRGB",
          "Green Component": 0.5450980392156862,
          "Red Component": 0.14901960784313725
        },
        "Ansi 4 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 5 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 5 Color (Dark)": {
          "Blue Component": 0.5098039215686274,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.8274509803921568
        },
        "Ansi 5 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 6 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 6 Color (Dark)": {
          "Blue Component": 0.596078431372549,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.16470588235294117
        },
        "Ansi 6 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 7 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 7 Color (Dark)": {
          "Blue Component": 0.8352941176470589,
          "Color Space": "sRGB",
          "Green Component": 0.9098039215686274,
          "Red Component": 0.9333333333333333
        },
        "Ansi 7 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 8 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 8 Color (Dark)": {
          "Blue Component": 0.21176470588235294,
          "Color Space": "sRGB",
          "Green Component": 0.16862745098039217,
          "Red Component": 0.0
        },
        "Ansi 8 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 9 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Ansi 9 Color (Dark)": {
          "Blue Component": 0.08627450980392157,
          "Color Space": "sRGB",
          "Green Component": 0.29411764705882354,
          "Red Component": 0.796078431372549
        },
        "Ansi 9 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Background Color": {
          "Alpha Component": 1.0,
          "Blue Component": 0.25177001953125,
          "Color Space": "sRGB",
          "Green Component": 0.0867764497518389,
          "Red Component": 0.0
        },
        "Background Color (Dark)": {
          "Blue Component": 0.21176470588235294,
          "Color Space": "sRGB",
          "Green Component": 0.16862745098039217,
          "Red Component": 0.0
        },
        "Background Color (Light)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.25177001953125,
          "Color Space": "sRGB",
          "Green Component": 0.0867764497518389,
          "Red Component": 0.0
        },
        "Blinking Cursor": false,
        "Blur": false,
        "Bold Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Bold Color (Dark)": {
          "Blue Component": 0.6313725490196078,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.5764705882352941
        },
        "Bold Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Brighten Bold Text (Dark)": true,
        "Brighten Bold Text (Light)": true,
        "Columns": 80,
        "Cursor Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Cursor Color (Dark)": {
          "Blue Component": 0.5882352941176471,
          "Color Space": "sRGB",
          "Green Component": 0.5803921568627451,
          "Red Component": 0.5137254901960784
        },
        "Cursor Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Cursor Text Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Cursor Text Color (Dark)": {
          "Blue Component": 0.25882352941176473,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.027450980392156862
        },
        "Cursor Text Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Faint Text Alpha (Dark)": 0.5,
        "Faint Text Alpha (Light)": 0.5,
        "Foreground Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Foreground Color (Dark)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.7235107421875,
          "Color Space": "P3",
          "Green Component": 0.7119658875832515,
          "Red Component": 0.6384523889862794
        },
        "Foreground Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Horizontal Spacing": 1.0,
        "Link Color (Dark)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.7093239426612854,
          "Color Space": "P3",
          "Green Component": 0.35333043336868286,
          "Red Component": 0.14513972401618958
        },
        "Link Color (Light)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.7093239426612854,
          "Color Space": "P3",
          "Green Component": 0.35333043336868286,
          "Red Component": 0.14513972401618958
        },
        "Load Shell Integration Automatically": true,
        "Non Ascii Font": "Monaco 15",
        "Non-ASCII Anti Aliased": true,
        "Normal Font": "JetBrainsMonoNFM-Regular 15",
        "Option Key Sends": 0,
        "Right Option Key Sends": 0,
        "Rows": 25,
        "Scrollback Lines": 1000,
        "Selected Text Color": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Selected Text Color (Dark)": {
          "Blue Component": 0.6313725490196078,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.5764705882352941
        },
        "Selected Text Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Selection Color": {
          "Blue Component": 1.0,
          "Green Component": 0.8353000283241272,
          "Red Component": 0.7098000049591064
        },
        "Selection Color (Dark)": {
          "Blue Component": 0.25882352941176473,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.027450980392156862
        },
        "Selection Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 0.8353000283241272,
          "Red Component": 0.7098000049591064
        },
        "Sync Title": false,
        "Transparency": 0.0,
        "Unlimited Scrollback": false,
        "Use Bold Font": true,
        "Use Bright Bold": true,
        "Use Non-ASCII Font": false,
        "Use Selected Text Color (Dark)": true,
        "Use Selected Text Color (Light)": true,
        "Use Separate Colors for Light and Dark Mode": true,
        "Vertical Spacing": 1.0,
        "Name": "SimplyHost iTerm2",
        "Guid": "a4692b4e-5b6a-5b9a-b0f0-6661e5147f71",
        "Command": "/bin/zsh",
        "Custom Command": "Yes",
        "Custom Directory": "No",
        "Working Directory": "",
        "Initial Text": "",
        "Send Text at Start": "",
        "Triggers": [],
        "Keyboard Map": {},
        "Tags": [
          "SimplyHost"
        ],
        "Dynamic Profile Parent Name": "Default"
      }
    ]
  },
  "iterm2_globals": {
    "DimBackgroundWindows": false,
    "DimOnlyText": false,
    "HideScrollbar": true,
    "SeparateStatusBarsPerPane": false,
    "ShowFullScreenTabBar": false,
    "ShowPaneTitles": true,
    "SplitPaneDimmingAmount": 0.39714711013349513,
    "StretchTabsToFillBar": true,
    "TabStyleWithAutomaticOption": 5,
    "TabViewType": 0,
    "TabsHaveCloseButton": true,
    "UseBorder": false
  },
  "windows_terminal": {
    "profiles": [
      {
        "guid": "{8cecb952-ffa0-50a6-a799-f858602245a2}",
        "name": "SimplyHost PowerShell",
        "commandline": "powershell.exe -NoLogo",
        "startingDirectory": "%USERPROFILE%",
        "font": {
          "face": "JetBrainsMono Nerd Font Mono",
          "size": 15,
          "features": {
            "liga": 1
          }
        },
        "colorScheme": {
          "light": "SimplyHost iTerm2 Light",
          "dark": "SimplyHost iTerm2 Dark"
        },
        "opacity": 100,
        "useAcrylic": false,
        "historySize": 1000,
        "scrollbarState": "hidden",
        "intenseTextStyle": "all"
      }
    ],
    "schemes": [
      {
        "name": "SimplyHost iTerm2 Light",
        "black": "#000000",
        "red": "#BB0000",
        "green": "#00BB00",
        "yellow": "#BBBB00",
        "blue": "#0000BB",
        "purple": "#BB00BB",
        "cyan": "#00BBBB",
        "white": "#BBBBBB",
        "brightBlack": "#555555",
        "brightRed": "#FF5555",
        "brightGreen": "#55FF55",
        "brightYellow": "#FFFF55",
        "brightBlue": "#5555FF",
        "brightPurple": "#FF55FF",
        "brightCyan": "#55FFFF",
        "brightWhite": "#FFFFFF",
        "background": "#001640",
        "foreground": "#BBBBBB",
        "cursorColor": "#BBBBBB",
        "selectionBackground": "#B5D5FF"
      },
      {
        "name": "SimplyHost iTerm2 Dark",
        "black": "#073642",
        "red": "#DC322F",
        "green": "#859900",
        "yellow": "#B58900",
        "blue": "#268BD2",
        "purple": "#D33682",
        "cyan": "#2AA198",
        "white": "#EEE8D5",
        "brightBlack": "#002B36",
        "brightRed": "#CB4B16",
        "brightGreen": "#586E75",
        "brightYellow": "#657B83",
        "brightBlue": "#839496",
        "brightPurple": "#6C71C4",
        "brightCyan": "#93A1A1",
        "brightWhite": "#FDF6E3",
        "background": "#002B36",
        "foreground": "#A3B6B8",
        "cursorColor": "#839496",
        "selectionBackground": "#073642"
      }
    ]
  },
  "notes": {
    "color_conversion": "Normalized RGB channels rounded to 8-bit; Display P3 colors are approximated.",
    "shell": "iTerm2 uses /bin/zsh. PowerShell prompt is a native approximation of directory, Git and status segments."
  }
}
'@ | ConvertFrom-Json
$utf8 = New-Object System.Text.UTF8Encoding($false)
$scriptSource = $PSCommandPath

function Write-SimplyHostFile {
    param([string]$Path, [string]$Content)
    if ((Test-Path -LiteralPath $Path) -and [IO.File]::ReadAllText($Path) -eq $Content) {
        Write-Host "Already current: $Path"
        return
    }
    $parent = Split-Path -Parent $Path
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    if (Test-Path -LiteralPath $Path) {
        # Store backups outside Fragments; Terminal reads all JSON files in that folder.
        $backupRoot = Join-Path $env:LOCALAPPDATA 'SimplyHost\terminal-backups'
        [IO.Directory]::CreateDirectory($backupRoot) | Out-Null
        $backupName = [IO.Path]::GetFileName($Path) + '.' + [guid]::NewGuid().ToString('N') + '.bak'
        [IO.File]::Copy($Path, (Join-Path $backupRoot $backupName))
    }
    $temporary = Join-Path $parent ('.simplyhost-' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($temporary, $Content, $utf8)
        if (Test-Path -LiteralPath $Path) {
            [IO.File]::Replace($temporary, $Path, $null)
        } else {
            [IO.File]::Move($temporary, $Path)
        }
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary }
    }
    Write-Host "Saved $Path"
}
function Set-SimplyHostProfileBlock {
    param([string]$Name, [string]$Body)
    $path = $PROFILE.CurrentUserAllHosts
    $start = "# >>> SimplyHost $Name >>>"
    $end = "# <<< SimplyHost $Name <<<"
    $block = $start + "`r`n" + $Body.Trim() + "`r`n" + $end
    $content = ''
    if (Test-Path -LiteralPath $path) { $content = [IO.File]::ReadAllText($path) }
    $pattern = '(?ms)^' + [regex]::Escape($start) + '\r?\n.*?^' + [regex]::Escape($end) + '\r?$'
    if ([regex]::IsMatch($content, $pattern)) {
        # A delegate preserves literal dollars and backslashes in PowerShell code.
        $replacement = $block
        $content = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement })
    } else {
        $content = $content.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
    }
    Write-SimplyHostFile -Path $path -Content $content
}
function Confirm-SimplyHostOption {
    param([string]$Question)
    if ($NoPrompt -or $WhatIfPreference -or [Console]::IsInputRedirected) { return $false }
    return (Read-Host "$Question [y/N]") -match '^(y|yes)$'
}

if ($ExportPath) {
    if (Test-Path -LiteralPath $ExportPath) { throw 'Export directory already exists; choose a new directory.' }
    if ($PSCmdlet.ShouldProcess($ExportPath, 'Export portable terminal presets')) {
        [IO.Directory]::CreateDirectory($ExportPath) | Out-Null
        foreach ($entry in @(
            @{ File = 'windows-terminal.json'; Value = $preset.windows_terminal },
            @{ File = 'iterm2-profile.json'; Value = $preset.iterm2 },
            @{ File = 'iterm2-globals.json'; Value = $preset.iterm2_globals }
        )) {
            $json = ConvertTo-Json -InputObject $entry.Value -Depth 30
            [IO.File]::WriteAllText((Join-Path $ExportPath $entry.File), $json + "`n", $utf8)
        }
    }
    return
}
if ($env:OS -ne 'Windows_NT') { throw 'Windows installation requires Windows. Use -ExportPath to inspect the preset elsewhere.' }
if (-not $env:LOCALAPPDATA) { throw 'LOCALAPPDATA is missing.' }
$terminalProfile = $preset.windows_terminal.profiles[0]
if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { $terminalProfile.commandline = 'pwsh.exe -NoLogo' }
$fragmentPath = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\SimplyHost\terminal.json'
if ($PSCmdlet.ShouldProcess($fragmentPath, 'Install SimplyHost PowerShell profile and color schemes')) {
    Write-SimplyHostFile -Path $fragmentPath -Content ((ConvertTo-Json -InputObject $preset.windows_terminal -Depth 30) + "`n")
}
Write-Host 'Open Windows Terminal and select SimplyHost PowerShell. Existing profiles and the default profile are preserved.'
Write-Host 'Font required: JetBrainsMono Nerd Font Mono (15 pt). Install it from https://www.nerdfonts.com/font-downloads if missing.'
Write-Host 'Windows Terminal controls appearance; PowerShell controls the command prompt. P3 colors and iTerm-only UI behavior are approximations.'

if ($InstallPrompt -or (Confirm-SimplyHostOption 'Add the directory/Git/status prompt to your PowerShell profile?')) {
    if ($PSCmdlet.ShouldProcess($PROFILE.CurrentUserAllHosts, 'Install SimplyHost prompt')) {
        Set-SimplyHostProfileBlock -Name 'prompt' -Body @'
function global:prompt {
    $lastSucceeded = $?
    $exitVariable = Get-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue
    $savedExitCode = 0
    if ($null -ne $exitVariable) { $savedExitCode = $exitVariable.Value }
    try {
        $ErrorActionPreference = 'Continue'
        $location = Get-Location
        $path = $location.Path
        $branch = ''
        if ($location.Provider.Name -eq 'FileSystem' -and (Get-Command git -ErrorAction SilentlyContinue)) {
            $branch = & git -C $path symbolic-ref --quiet --short HEAD 2>$null
            if (-not $branch) { $branch = & git -C $path rev-parse --short HEAD 2>$null }
        }
        Write-Host ' PS ' -ForegroundColor Cyan -NoNewline
        Write-Host $path -ForegroundColor Blue -NoNewline
        if ($branch) { Write-Host " [$branch]" -ForegroundColor Magenta -NoNewline }
        if (-not $lastSucceeded) { Write-Host ' [failed]' -ForegroundColor Red -NoNewline }
        $activeJobs = @(Get-Job -State Running -ErrorAction SilentlyContinue)
        if ($activeJobs.Count -gt 0) { Write-Host " [jobs:$($activeJobs.Count)]" -ForegroundColor Yellow -NoNewline }
        return "`n> "
    } finally { $global:LASTEXITCODE = $savedExitCode }
}
'@
    }
}
if ($AddCommand -or (Confirm-SimplyHostOption 'Add sh-terminal to your PowerShell profile for repeat use?')) {
    if (-not $scriptSource -or -not (Test-Path -LiteralPath $scriptSource)) {
        throw 'Save this script as powershell.ps1 before installing the repeat command.'
    }
    $savedScript = Join-Path $env:LOCALAPPDATA 'SimplyHost\scripts\powershell.ps1'
    if ($PSCmdlet.ShouldProcess($savedScript, 'Save terminal installer and add sh-terminal to PowerShell profile')) {
        Write-SimplyHostFile -Path $savedScript -Content ([IO.File]::ReadAllText($scriptSource))
        $quotedPath = $savedScript.Replace("'", "''")
        Set-SimplyHostProfileBlock -Name 'command' -Body ("function global:sh-terminal { & '" + $quotedPath + "' @args }")
    }
}
Write-Host 'Start a new PowerShell session to load profile changes, or run: . $PROFILE.CurrentUserAllHosts'
