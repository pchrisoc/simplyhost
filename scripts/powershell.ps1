#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ExportPath,
    [switch]$InstallPrompt,
    [switch]$AddCommand,
    [switch]$NoPrompt,
    [switch]$SkipPrompt,
    [switch]$SkipFontInstall,
    [switch]$KeepDefaultProfile,
    [switch]$NoLaunch,
    [switch]$Help
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($Help) {
    Write-Output 'Usage: .\powershell.ps1 [-ExportPath NEW_DIRECTORY] [-InstallPrompt] [-AddCommand] [-NoPrompt] [-SkipPrompt] [-SkipFontInstall] [-KeepDefaultProfile] [-NoLaunch] [-WhatIf]'
    Write-Output 'Installs Solarized Dark for normal Windows PowerShell and Windows Terminal, a Powerlevel10k-style Oh My Posh prompt, and JetBrains Mono Nerd Font. Makes the themed profile the default unless -KeepDefaultProfile is set.'
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
          "face": "JetBrainsMono NFM",
          "size": 15,
          "features": {
            "liga": 1
          }
        },
        "colorScheme": "SimplyHost Solarized Dark",
        "opacity": 100,
        "useAcrylic": false,
        "historySize": 1000,
        "scrollbarState": "hidden",
        "intenseTextStyle": "all",
        "background": "#002B36",
        "foreground": "#839496",
        "cursorColor": "#93A1A1",
        "cursorShape": "filledBox"
      }
    ],
    "schemes": [
      {
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
        "name": "SimplyHost Solarized Dark",
        "background": "#002B36",
        "foreground": "#839496",
        "cursorColor": "#93A1A1",
        "selectionBackground": "#073642"
      }
    ]
  },
  "notes": {
    "color_conversion": "Windows uses the standard Solarized Dark 16-color RGB palette. The macOS snapshot preserves the original iTerm2 colors.",
    "shell": "PowerShell uses an Oh My Posh single-line powerline prompt with Solarized Dark colors."
  },
  "oh_my_posh": {
    "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
    "version": 4,
    "final_space": true,
    "console_title_template": "{{ .Shell }} | {{ .Folder }}",
    "blocks": [
      {
        "type": "prompt",
        "alignment": "left",
        "segments": [
          {
            "type": "os",
            "style": "diamond",
            "powerline_symbol": "\ue0b0",
            "foreground": "#FDF6E3",
            "background": "#073642",
            "template": " {{ .Icon }} ",
            "leading_diamond": "\ue0b2",
            "trailing_diamond": ""
          },
          {
            "type": "path",
            "style": "powerline",
            "powerline_symbol": "\ue0b0",
            "foreground": "#268BD2",
            "background": "#444444",
            "template": " \uf07c {{ .Path }} ",
            "options": {
              "style": "agnoster_short",
              "max_depth": 3,
              "folder_separator_icon": "/",
              "home_icon": "~"
            }
          },
          {
            "type": "git",
            "style": "powerline",
            "powerline_symbol": "\ue0b0",
            "foreground": "#859900",
            "background": "#073642",
            "template": " {{ .HEAD }}{{ if .Working.Changed }} *{{ end }}{{ if .Staging.Changed }} +{{ end }} ",
            "foreground_templates": [
              "{{ if or (.Working.Changed) (.Staging.Changed) }}#B58900{{ end }}"
            ]
          },
          {
            "type": "status",
            "style": "powerline",
            "powerline_symbol": "\ue0b0",
            "foreground": "#DC322F",
            "background": "#444444",
            "template": " {{ if eq .Code 0 }}\uf00c{{ else }}\uf00d {{ .Code }}{{ end }} ",
            "options": {
              "always_enabled": false
            },
            "foreground_templates": [
              "{{ if gt .Code 0 }}#DC322F{{ end }}"
            ]
          },
          {
            "type": "executiontime",
            "style": "powerline",
            "powerline_symbol": "\ue0b0",
            "foreground": "#B58900",
            "background": "#444444",
            "template": " {{ .FormattedMs }} ",
            "options": {
              "threshold": 3000,
              "style": "austin"
            }
          }
        ]
      }
    ],
    "secondary_prompt": {
      "foreground": "#586E75",
      "background": "transparent",
      "template": "... "
    },
    "terminal_background": "#002B36"
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
            # A bare $null can become an empty string when bound to this .NET string parameter.
            # Backups were saved above; explicitly pass a null string for the optional backup path.
            [IO.File]::Replace($temporary, $Path, [System.Management.Automation.Language.NullString]::Value)
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
    $pattern = '(?ms)^' + [regex]::Escape($start) + '\r?\n.*?^' + [regex]::Escape($end) + '(?=\r?$)'
    if ([regex]::IsMatch($content, $pattern)) {
        # A delegate preserves literal dollars and backslashes in PowerShell code.
        $replacement = $block
        $content = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement })
    } else {
        $content = $content.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
    }
    Write-SimplyHostFile -Path $path -Content $content
}
# JSONC token positions let us preserve comments and unrelated Terminal settings.
function Get-SimplyHostJsonTokens {
    param([string]$Content)
    $pattern = '(?s)"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*.*?\*/|[{}\[\]:,]|-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?|\b(?:true|false|null)\b'
    return @([regex]::Matches($Content, $pattern) | Where-Object { -not $_.Value.StartsWith('/') })
}
function Find-SimplyHostJsonProperty {
    param([object[]]$Tokens, [int]$ObjectStart, [string]$Name)
    $depth = 0
    $quotedName = ConvertTo-Json -InputObject $Name -Compress
    for ($index = 0; $index -lt $Tokens.Count; $index++) {
        $token = $Tokens[$index]
        if ($token.Index -lt $ObjectStart) { continue }
        if ($depth -eq 1 -and $token.Value -ceq $quotedName -and $index + 2 -lt $Tokens.Count -and $Tokens[$index + 1].Value -eq ':') {
            $start = $index + 2
            $end = $start
            if ($Tokens[$start].Value -eq '{' -or $Tokens[$start].Value -eq '[') {
                $valueDepth = 0
                for ($end = $start; $end -lt $Tokens.Count; $end++) {
                    if ($Tokens[$end].Value -eq '{' -or $Tokens[$end].Value -eq '[') { $valueDepth++ }
                    if ($Tokens[$end].Value -eq '}' -or $Tokens[$end].Value -eq ']') { $valueDepth-- }
                    if ($valueDepth -eq 0) { break }
                }
            }
            return [PSCustomObject]@{ Start = $Tokens[$start].Index; End = $Tokens[$end].Index + $Tokens[$end].Length; TokenIndex = $start; TokenEnd = $end }
        }
        if ($token.Value -eq '{' -or $token.Value -eq '[') { $depth++ }
        if ($token.Value -eq '}' -or $token.Value -eq ']') { $depth-- }
        if ($depth -eq 0) { break }
    }
    return $null
}
function Set-SimplyHostJsonProperty {
    param([string]$Content, [int]$ObjectStart, [string]$Name, [string]$ValueJson)
    $tokens = @(Get-SimplyHostJsonTokens -Content $Content)
    $property = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $ObjectStart -Name $Name
    if ($null -ne $property) { return $Content.Remove($property.Start, $property.End - $property.Start).Insert($property.Start, $ValueJson) }
    $following = @($tokens | Where-Object { $_.Index -gt $ObjectStart })
    $comma = ','
    if ($following[0].Value -eq '}') { $comma = '' }
    $quotedName = ConvertTo-Json -InputObject $Name -Compress
    return $Content.Insert($ObjectStart + 1, "`r`n$quotedName`: $ValueJson$comma`r`n")
}
function Set-SimplyHostActiveProfileAppearance {
    param([string]$Content, [object]$ManagedProfile)
    $activeId = [Environment]::GetEnvironmentVariable('WT_PROFILE_ID')
    $activeGuid = [guid]::Empty
    if (-not [guid]::TryParse($activeId, [ref]$activeGuid)) { return $Content }
    if ($activeGuid -eq [guid]$ManagedProfile.guid) { return $Content }
    $tokens = @(Get-SimplyHostJsonTokens -Content $Content)
    $profiles = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $tokens[0].Index -Name 'profiles'
    $list = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $profiles.Start -Name 'list'
    $activeStart = -1
    $depth = 0
    for ($index = $list.TokenIndex; $index -le $list.TokenEnd; $index++) {
        $token = $tokens[$index]
        if ($depth -eq 1 -and $token.Value -eq '{') {
            $property = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $token.Index -Name 'guid'
            if ($null -ne $property) {
                $value = ConvertFrom-Json -InputObject ('{"value":' + $Content.Substring($property.Start, $property.End - $property.Start) + '}')
                $candidate = [guid]::Empty
                if ([guid]::TryParse([string]$value.value, [ref]$candidate) -and $candidate -eq $activeGuid) { $activeStart = $token.Index; break }
            }
        }
        if ($token.Value -eq '{' -or $token.Value -eq '[') { $depth++ }
        if ($token.Value -eq '}' -or $token.Value -eq ']') { $depth-- }
    }
    $fields = @('font','colorScheme','background','foreground','cursorColor','opacity','useAcrylic')
    if ($activeStart -ge 0) {
        foreach ($name in $fields) {
            $Content = Set-SimplyHostJsonProperty -Content $Content -ObjectStart $activeStart -Name $name -ValueJson (ConvertTo-Json -InputObject $ManagedProfile.$name -Depth 10 -Compress)
        }
    } else {
        # A built-in/dynamic profile may not yet have an explicit user-settings entry.
        $override = [ordered]@{ guid = '{' + $activeGuid.ToString() + '}' }
        foreach ($name in $fields) { $override[$name] = $ManagedProfile.$name }
        $json = ConvertTo-Json -InputObject $override -Depth 20 -Compress
        $Content = $Content.Insert($list.Start + 1, "`r`n$json,`r`n")
    }
    return $Content
}

function Set-SimplyHostTerminalSettings {
    param([object]$ManagedProfile, [switch]$KeepDefault)
    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )
    $pattern = '(?s)"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*.*?\*/|[{}\[\]:,]'
    $found = $false
    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $found = $true
        $content = [IO.File]::ReadAllText($path)
        $tokens = @(Get-SimplyHostJsonTokens -Content $content)
        if ($tokens.Count -lt 2 -or $tokens[0].Value -ne '{' -or $tokens[-1].Value -ne '}') { throw "Windows Terminal settings are not a JSON object: $path" }
        # Validate without comments/trailing commas, but preserve the original text for edits.
        $clean = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)
            if ($match.Value.StartsWith('/')) { return [regex]::Replace($match.Value, '[^\r\n]', ' ') }
            return $match.Value
        })
        for ($index = $tokens.Count - 2; $index -ge 0; $index--) {
            if ($tokens[$index].Value -eq ',' -and $tokens[$index + 1].Value -match '^[}\]]$') { $clean = $clean.Remove($tokens[$index].Index, 1).Insert($tokens[$index].Index, ' ') }
        }
        $null = ConvertFrom-Json -InputObject $clean
        $root = $tokens[0].Index
        if (-not $KeepDefault) {
            $content = Set-SimplyHostJsonProperty -Content $content -ObjectStart $root -Name 'defaultProfile' -ValueJson (ConvertTo-Json -InputObject $ManagedProfile.guid -Compress)
        }
        $profileJson = ConvertTo-Json -InputObject $ManagedProfile -Depth 20 -Compress
        $tokens = @(Get-SimplyHostJsonTokens -Content $content)
        $profiles = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $root -Name 'profiles'
        if ($null -eq $profiles) {
            $content = Set-SimplyHostJsonProperty -Content $content -ObjectStart $root -Name 'profiles' -ValueJson ('{"list":[' + $profileJson + ']}')
        } else {
            if ($tokens[$profiles.TokenIndex].Value -ne '{') { throw "Expected profiles to be an object in $path" }
            $list = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $profiles.Start -Name 'list'
            if ($null -eq $list) {
                $content = Set-SimplyHostJsonProperty -Content $content -ObjectStart $profiles.Start -Name 'list' -ValueJson ('[' + $profileJson + ']')
            } else {
                if ($tokens[$list.TokenIndex].Value -ne '[') { throw "Expected profiles.list to be an array in $path" }
                $managedStart = -1
                $arrayDepth = 0
                for ($index = $list.TokenIndex; $index -le $list.TokenEnd; $index++) {
                    $token = $tokens[$index]
                    if ($arrayDepth -eq 1 -and $token.Value -eq '{') {
                        $guidProperty = Find-SimplyHostJsonProperty -Tokens $tokens -ObjectStart $token.Index -Name 'guid'
                        if ($null -ne $guidProperty) {
                            $guid = ConvertFrom-Json -InputObject ('{"value":' + $content.Substring($guidProperty.Start, $guidProperty.End - $guidProperty.Start) + '}')
                            if ($guid.value -eq $ManagedProfile.guid) { $managedStart = $token.Index; break }
                        }
                    }
                    if ($token.Value -eq '{' -or $token.Value -eq '[') { $arrayDepth++ }
                    if ($token.Value -eq '}' -or $token.Value -eq ']') { $arrayDepth-- }
                }
                if ($managedStart -ge 0) {
                    # Explicit user-profile settings outrank fragments and defaults. Set our own profile's
                    # font/colors here, preserving unrelated profiles and custom fields on this profile.
                    foreach ($name in @('font','colorScheme','background','foreground','cursorColor','opacity','useAcrylic')) {
                        $valueJson = ConvertTo-Json -InputObject $ManagedProfile.$name -Depth 10 -Compress
                        $content = Set-SimplyHostJsonProperty -Content $content -ObjectStart $managedStart -Name $name -ValueJson $valueJson
                    }
                } else {
                    $comma = ','
                    if ($tokens[$list.TokenIndex + 1].Value -eq ']') { $comma = '' }
                    $content = $content.Insert($list.Start + 1, "`r`n$profileJson$comma`r`n")
                }
            }
        }
        $content = Set-SimplyHostActiveProfileAppearance -Content $content -ManagedProfile $ManagedProfile
        if ($PSCmdlet.ShouldProcess($path, 'Apply Solarized Dark and the Nerd Font to SimplyHost and the active Terminal profile')) { Write-SimplyHostFile -Path $path -Content $content }
    }
    if (-not $found) { Write-Verbose 'No Windows Terminal settings found; normal PowerShell uses its startup console helper.' }
}

function Test-SimplyHostNerdFont {
    param([object[]]$Hives = @([Microsoft.Win32.Registry]::CurrentUser, [Microsoft.Win32.Registry]::LocalMachine))
    foreach ($hive in $Hives) {
        if ($null -eq $hive) { continue }
        $key = $null
        try {
            $key = $hive.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts')
            if ($null -eq $key) { continue }
            # Read registry value names directly; avoid PowerShell's adapted property collections.
            foreach ($fontName in $key.GetValueNames()) {
                if ($fontName -match 'JetBrainsMono(?:\s*NFM|\s*Nerd\s*Font\s*Mono)') { return $true }
            }
        } catch [System.UnauthorizedAccessException] {
            Write-Warning 'Could not read a font registry key; checking the remaining font locations.'
        } finally {
            if ($null -ne $key) { $key.Dispose() }
        }
    }
    return $false
}

function Install-SimplyHostStartMenuShortcut {
    param([string]$ProfileGuid, [string]$TerminalExecutable)
    if (-not $env:APPDATA -or -not $TerminalExecutable) { return }
    $programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    $path = Join-Path $programs 'SimplyHost PowerShell.lnk'
    if ($PSCmdlet.ShouldProcess($path, 'Save a Start-menu entry for the themed PowerShell profile')) {
        [IO.Directory]::CreateDirectory($programs) | Out-Null
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($path)
        $shortcut.TargetPath = $TerminalExecutable
        $shortcut.Arguments = '-w new new-tab -p ' + $ProfileGuid
        $shortcut.WorkingDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
        $shortcut.Description = 'PowerShell with the SimplyHost Solarized Dark theme and Nerd Font'
        $shortcut.Save()
        Write-Host 'Saved Start-menu entry: SimplyHost PowerShell. Use this entry when reopening your themed terminal.'
    }
}

function Install-SimplyHostConsoleAppearance {
    $consolePath = Join-Path $env:LOCALAPPDATA 'SimplyHost\console.ps1'
    if (-not $PSCmdlet.ShouldProcess($consolePath, 'Persist font and Solarized colors for the normal PowerShell console')) { return }
    Write-SimplyHostFile -Path $consolePath -Content @'
# Applied on every PowerShell startup, including the built-in Start-menu shortcut.
if ($env:OS -eq 'Windows_NT' -and $Host.Name -eq 'ConsoleHost' -and -not $env:WT_SESSION) {
    try {
        if (-not ('SimplyHost.ConsoleAppearanceV2' -as [type])) {
            Add-Type -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
namespace SimplyHost {
    public static class ConsoleAppearanceV2 {
        [StructLayout(LayoutKind.Sequential)] public struct Coord { public short X, Y; }
        [StructLayout(LayoutKind.Sequential)] public struct Rect { public short Left, Top, Right, Bottom; }
        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct FontInfo {
            public uint Size, Font;
            public Coord Cell;
            public uint Family, Weight;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string Face;
        }
        [StructLayout(LayoutKind.Sequential)] public struct BufferInfo {
            public uint Size;
            public Coord BufferSize, Cursor;
            public ushort Attributes;
            public Rect Window;
            public Coord Maximum;
            public ushort PopupAttributes;
            [MarshalAs(UnmanagedType.Bool)] public bool Fullscreen;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst=16)] public uint[] Colors;
        }
        [DllImport("kernel32.dll")] static extern IntPtr GetStdHandle(int kind);
        [DllImport("kernel32.dll")] static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] static extern bool IsWindowVisible(IntPtr window);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetConsoleMode(IntPtr handle, out uint mode);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetConsoleMode(IntPtr handle, uint mode);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetConsoleScreenBufferInfoEx(IntPtr handle, ref BufferInfo info);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetConsoleScreenBufferInfoEx(IntPtr handle, ref BufferInfo info);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetConsoleTextAttribute(IntPtr handle, ushort attributes);
        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool GetCurrentConsoleFontEx(IntPtr handle, bool maximum, ref FontInfo info);
        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool SetCurrentConsoleFontEx(IntPtr handle, bool maximum, ref FontInfo info);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool ReadConsoleOutputAttribute(IntPtr handle, [Out] ushort[] data, uint length, Coord start, out uint count);
        [DllImport("kernel32.dll", SetLastError=true)] static extern bool WriteConsoleOutputAttribute(IntPtr handle, ushort[] data, uint length, Coord start, out uint count);
        static void Check(bool success) { if (!success) throw new Win32Exception(Marshal.GetLastWin32Error()); }
        public static void Apply() {
            IntPtr handle = GetStdHandle(-11);
            uint mode;
            if (!GetConsoleMode(handle, out mode)) return; // Redirected output has no console to theme.
            BufferInfo info = new BufferInfo();
            info.Size = (uint)Marshal.SizeOf(typeof(BufferInfo));
            Check(GetConsoleScreenBufferInfoEx(handle, ref info));
            ushort oldAttributes = info.Attributes;
            // Console color indexes follow BGR order, unlike ANSI's RGB order.
            string[] palette = { "073642", "268BD2", "859900", "2AA198", "DC322F", "D33682", "B58900", "EEE8D5",
                                 "002B36", "839496", "586E75", "93A1A1", "CB4B16", "6C71C4", "657B83", "FDF6E3" };
            for (int i=0; i<16; i++) {
                uint rgb = Convert.ToUInt32(palette[i], 16);
                info.Colors[i] = ((rgb & 255) << 16) | (rgb & 65280) | ((rgb >> 16) & 255);
            }
            info.Attributes = 0x89; // Background #002B36, foreground #839496.
            // This setter expects exclusive right/bottom edges; the getter returns inclusive ones.
            info.Window.Right++;
            info.Window.Bottom++;
            Check(SetConsoleScreenBufferInfoEx(handle, ref info));
            Check(SetConsoleTextAttribute(handle, 0x89));
            Check(SetConsoleMode(handle, mode | 4)); // ANSI colors used by Oh My Posh.
            // Recolor the existing default cells without clearing text or scrollback.
            ushort[] cells = new ushort[4096];
            int total = info.BufferSize.X * info.BufferSize.Y;
            for (int offset=0; offset<total; offset+=cells.Length) {
                Coord start = new Coord();
                start.X = (short)(offset % info.BufferSize.X);
                start.Y = (short)(offset / info.BufferSize.X);
                uint read, written;
                uint length = (uint)Math.Min(cells.Length, total-offset);
                Check(ReadConsoleOutputAttribute(handle, cells, length, start, out read));
                for (int i=0; i<read; i++) {
                    if ((cells[i] & 255) == (oldAttributes & 255)) cells[i] = (ushort)((cells[i] & 65280) | 0x89);
                }
                Check(WriteConsoleOutputAttribute(handle, cells, read, start, out written));
            }
            // Start-menu launches can be delegated to Terminal without WT_SESSION.
            // Its pseudoconsole has a hidden message window and cannot select the UI font.
            IntPtr window = GetConsoleWindow();
            if (window == IntPtr.Zero || !IsWindowVisible(window)) return;
            FontInfo font = new FontInfo();
            font.Size = (uint)Marshal.SizeOf(typeof(FontInfo));
            Check(GetCurrentConsoleFontEx(handle, false, ref font));
            font.Face = "JetBrainsMono NFM";
            font.Cell.X = 0;
            font.Cell.Y = 20;
            font.Family = 54;
            font.Weight = 400;
            Check(SetCurrentConsoleFontEx(handle, false, ref font));
            FontInfo actual = new FontInfo();
            actual.Size = font.Size;
            Check(GetCurrentConsoleFontEx(handle, false, ref actual));
            if (!String.Equals(actual.Face, font.Face, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Classic console selected '" + actual.Face + "' instead of JetBrainsMono NFM. Reopen PowerShell after the font installation; if it remains unavailable, restart Windows.");
        }
    }
}
"@
        }
        [SimplyHost.ConsoleAppearanceV2]::Apply()
        $Host.UI.RawUI.BackgroundColor = [ConsoleColor]::DarkGray
        $Host.UI.RawUI.ForegroundColor = [ConsoleColor]::Blue
    } catch { Write-Warning ('SimplyHost console appearance: ' + $_.Exception.Message) }
}
'@
    Set-SimplyHostProfileBlock -Name 'console' -Body @'
$simplyHostConsole = Join-Path $env:LOCALAPPDATA 'SimplyHost\console.ps1'
if (Test-Path -LiteralPath $simplyHostConsole) { . $simplyHostConsole }
'@
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
            @{ File = 'simplyhost.omp.json'; Value = $preset.oh_my_posh },
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
Write-Host ('SimplyHost terminal setup 2026.10.23.8 (PowerShell ' + $PSVersionTable.PSVersion.ToString() + ')')
$terminalProfile = $preset.windows_terminal.profiles[0]
if ($PSVersionTable.PSEdition -eq 'Core') { $terminalProfile.commandline = 'pwsh.exe -NoLogo' }
$fragmentPath = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\SimplyHost\terminal.json'
if ($PSCmdlet.ShouldProcess($fragmentPath, 'Install SimplyHost PowerShell profile and color schemes')) {
    Write-SimplyHostFile -Path $fragmentPath -Content ((ConvertTo-Json -InputObject $preset.windows_terminal -Depth 30) + "`n")
}
Write-Host 'Terminal profile: SimplyHost PowerShell, Solarized Dark (#002B36).'

if (-not $SkipPrompt) {
    $poshCommand = Get-Command oh-my-posh.exe -ErrorAction SilentlyContinue
    if (-not $poshCommand) {
        if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
            throw 'Oh My Posh is required. Install App Installer (winget), or install Oh My Posh from https://ohmyposh.dev/docs/installation/windows and rerun.'
        }
        if ($PSCmdlet.ShouldProcess('Oh My Posh', 'Install using winget')) {
            & winget.exe install --id JanDeDobbeleer.OhMyPosh --exact --source winget --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) { throw 'Oh My Posh installation failed; rerun after resolving the winget error.' }
            $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + $env:PATH
            $poshCommand = Get-Command oh-my-posh.exe -ErrorAction SilentlyContinue
            if (-not $poshCommand) {
                $poshPath = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin\oh-my-posh.exe'
                if (Test-Path -LiteralPath $poshPath) { $poshCommand = (Get-Item -LiteralPath $poshPath).FullName }
            }
            if (-not $poshCommand) { throw 'Oh My Posh was installed but is not available. Open a new PowerShell window and rerun.' }
        }
    }
    if ($poshCommand -and -not $SkipFontInstall) {
        $fontPresent = Test-SimplyHostNerdFont
        if (-not $fontPresent -and $PSCmdlet.ShouldProcess('JetBrains Mono Nerd Font', 'Install the font required for powerline icons')) {
            & $poshCommand font install 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip'
            if ($LASTEXITCODE -ne 0) { throw 'Font installation failed. Install JetBrainsMono NFM, then rerun (or use -SkipFontInstall if already installed).' }
        }
    }
    Install-SimplyHostConsoleAppearance
    $themePath = Join-Path $env:LOCALAPPDATA 'SimplyHost\themes\solarized-dark.omp.json'
    if ($PSCmdlet.ShouldProcess($themePath, 'Install the Powerlevel10k-style prompt theme')) {
        Write-SimplyHostFile -Path $themePath -Content ((ConvertTo-Json -InputObject $preset.oh_my_posh -Depth 30) + "`n")
    }
    if ($PSCmdlet.ShouldProcess($PROFILE.CurrentUserAllHosts, 'Replace the basic SimplyHost prompt with Oh My Posh')) {
        Set-SimplyHostProfileBlock -Name 'prompt' -Body @'
$simplyHostPosh = Get-Command oh-my-posh.exe -ErrorAction SilentlyContinue
if (-not $simplyHostPosh) {
    $simplyHostPoshPath = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin\oh-my-posh.exe'
    if (Test-Path -LiteralPath $simplyHostPoshPath) { $simplyHostPosh = (Get-Item -LiteralPath $simplyHostPoshPath).FullName }
}
if ($simplyHostPosh) {
    # Reloading a profile must replace the cached Oh My Posh module and its line-count state.
    if (Get-Module -Name oh-my-posh-core) { Remove-Module -Name oh-my-posh-core -Force }
    $simplyHostPreviousEncoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
        & $simplyHostPosh init pwsh --eval --config (Join-Path $env:LOCALAPPDATA 'SimplyHost\themes\solarized-dark.omp.json') | Invoke-Expression
    } finally { [Console]::OutputEncoding = $simplyHostPreviousEncoding }
} else { Write-Warning 'SimplyHost prompt needs Oh My Posh. Rerun the terminal installer.' }
'@
    }
}
Set-SimplyHostTerminalSettings -ManagedProfile $terminalProfile -KeepDefault:$KeepDefaultProfile
Write-Host 'Appearance saved for normal Windows PowerShell and Windows Terminal.'
Write-Host 'Font: JetBrainsMono NFM. Colors: background #002B36, text #839496. The active Terminal profile is also updated when WT_PROFILE_ID is available.'
Write-Host 'The built-in Windows PowerShell Start-menu entry will load the font, colors, and prompt on startup.'

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
$terminalExecutable = Get-Command wt.exe -CommandType Application -ErrorAction SilentlyContinue
if ($terminalExecutable) {
    Install-SimplyHostStartMenuShortcut -ProfileGuid $terminalProfile.guid -TerminalExecutable $terminalExecutable.Path
}
if (-not $NoLaunch) {
    $shellExecutable = Join-Path $PSHOME 'powershell.exe'
    if ($PSVersionTable.PSEdition -eq 'Core') { $shellExecutable = Join-Path $PSHOME 'pwsh.exe' }
    if ($PSCmdlet.ShouldProcess($shellExecutable, 'Open a fresh PowerShell window with the saved startup appearance')) {
        Start-Process -FilePath $shellExecutable -ArgumentList '-NoLogo'
    }
}
Write-Host 'Setup complete. Open Windows PowerShell normally from Start to use the saved appearance.'
