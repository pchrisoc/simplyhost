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
    [switch]$Help
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($Help) {
    Write-Output 'Usage: .\powershell.ps1 [-ExportPath NEW_DIRECTORY] [-InstallPrompt] [-AddCommand] [-NoPrompt] [-SkipPrompt] [-SkipFontInstall] [-KeepDefaultProfile] [-WhatIf]'
    Write-Output 'Installs a Solarized Dark Windows Terminal profile, a Powerlevel10k-style Oh My Posh prompt, and JetBrains Mono Nerd Font. Makes the themed profile the default unless -KeepDefaultProfile is set.'
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
    "shell": "PowerShell uses an Oh My Posh configuration with a Powerlevel10k-style two-line powerline prompt and Solarized Dark colors."
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
            "type": "text",
            "style": "plain",
            "foreground": "#586E75",
            "template": "\u256d\u2500"
          },
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
          }
        ]
      },
      {
        "type": "prompt",
        "alignment": "right",
        "segments": [
          {
            "type": "status",
            "style": "powerline",
            "powerline_symbol": "\ue0b2",
            "foreground": "#859900",
            "background": "#444444",
            "template": " {{ if eq .Code 0 }}\uf00c{{ else }}\uf00d {{ .Code }}{{ end }} ",
            "options": {
              "always_enabled": true
            },
            "invert_powerline": true,
            "foreground_templates": [
              "{{ if gt .Code 0 }}#DC322F{{ end }}"
            ]
          },
          {
            "type": "executiontime",
            "style": "powerline",
            "powerline_symbol": "\ue0b2",
            "foreground": "#B58900",
            "background": "#444444",
            "template": " {{ .FormattedMs }} ",
            "options": {
              "threshold": 3000,
              "style": "austin"
            },
            "invert_powerline": true
          },
          {
            "type": "text",
            "style": "plain",
            "foreground": "#586E75",
            "template": "\u2500\u256e"
          }
        ]
      },
      {
        "type": "prompt",
        "alignment": "left",
        "newline": true,
        "segments": [
          {
            "type": "text",
            "style": "plain",
            "foreground": "#586E75",
            "template": "\u2570\u2500"
          },
          {
            "type": "text",
            "style": "plain",
            "foreground": "#859900",
            "foreground_templates": [
              "{{ if gt .Code 0 }}#DC322F{{ end }}"
            ],
            "template": "\u276f"
          }
        ]
      }
    ],
    "transient_prompt": {
      "foreground": "#839496",
      "background": "transparent",
      "template": "\u276f "
    },
    "secondary_prompt": {
      "foreground": "#586E75",
      "background": "transparent",
      "template": "\u2570\u2500 "
    }
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
function Set-SimplyHostTerminalDefault {
    param([string]$Guid)
    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )
    # Preserve JSON-with-comments and formatting; change only the root defaultProfile value.
    $tokenPattern = '(?s)"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*.*?\*/|[{}\[\]:,]'
    $found = $false
    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $found = $true
        $content = [IO.File]::ReadAllText($path)
        $matches = [regex]::Matches($content, $tokenPattern)
        $tokens = @($matches | Where-Object { -not $_.Value.StartsWith('/') })
        if ($tokens.Count -lt 2 -or $tokens[0].Value -ne '{' -or $tokens[-1].Value -ne '}') {
            throw "Windows Terminal settings are not a JSON object: $path"
        }
        # Validate a temporary JSON representation before editing; do not rewrite users' comments.
        $clean = [regex]::Replace($content, $tokenPattern, [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)
            if ($match.Value.StartsWith('/')) { return [regex]::Replace($match.Value, '[^\r\n]', ' ') }
            return $match.Value
        })
        for ($index = $tokens.Count - 2; $index -ge 0; $index--) {
            if ($tokens[$index].Value -eq ',' -and $tokens[$index + 1].Value -match '^[}\]]$') {
                $clean = $clean.Remove($tokens[$index].Index, 1).Insert($tokens[$index].Index, ' ')
            }
        }
        $null = ConvertFrom-Json -InputObject $clean
        $depth = 0
        $values = @()
        for ($index = 0; $index -lt $tokens.Count; $index++) {
            $token = $tokens[$index]
            if ($depth -eq 1 -and $token.Value -ceq '"defaultProfile"' -and $index + 2 -lt $tokens.Count -and $tokens[$index + 1].Value -eq ':') {
                $value = $tokens[$index + 2]
                if (-not $value.Value.StartsWith('"')) { throw "Invalid defaultProfile value in $path" }
                $values += $value
            }
            if ($token.Value -eq '{' -or $token.Value -eq '[') { $depth++ }
            if ($token.Value -eq '}' -or $token.Value -eq ']') { $depth-- }
        }
        $quotedGuid = ConvertTo-Json -InputObject $Guid -Compress
        if ($values.Count -gt 0) {
            foreach ($value in ($values | Sort-Object Index -Descending)) {
                $content = $content.Remove($value.Index, $value.Length).Insert($value.Index, $quotedGuid)
            }
        } else {
            $comma = ','
            if ($tokens[1].Value -eq '}') { $comma = '' }
            $content = $content.Insert($tokens[0].Index + 1, "`r`n    `"defaultProfile`": $quotedGuid$comma`r`n")
        }
        if ($PSCmdlet.ShouldProcess($path, 'Make SimplyHost PowerShell the default Windows Terminal profile')) {
            Write-SimplyHostFile -Path $path -Content $content
        }
    }
    if (-not $found) {
        Write-Warning 'No Windows Terminal settings file found. Open Terminal once and rerun, or select SimplyHost PowerShell in Settings > Startup > Default profile.'
    }
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
        $fontPresent = $false
        foreach ($fontKey in @('HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts', 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts')) {
            if (Test-Path -LiteralPath $fontKey) {
                $fontValues = Get-ItemProperty -LiteralPath $fontKey
                if ($null -eq $fontValues) { continue }
                # Explicit enumeration also handles empty keys under Windows PowerShell 5.1 strict mode.
                foreach ($fontProperty in $fontValues.PSObject.Properties) {
                    if ($fontProperty.Name -match 'JetBrainsMono.*Nerd Font Mono') {
                        $fontPresent = $true
                        break
                    }
                }
            }
        }
        if (-not $fontPresent -and $PSCmdlet.ShouldProcess('JetBrains Mono Nerd Font', 'Install the font required for powerline icons')) {
            & $poshCommand font install 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip'
            if ($LASTEXITCODE -ne 0) { throw 'Font installation failed. Install JetBrainsMono Nerd Font Mono, then rerun (or use -SkipFontInstall if already installed).' }
        }
    }
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
    & $simplyHostPosh init pwsh --config (Join-Path $env:LOCALAPPDATA 'SimplyHost\themes\solarized-dark.omp.json') | Invoke-Expression
} else { Write-Warning 'SimplyHost prompt needs Oh My Posh. Rerun the terminal installer.' }
'@
    }
}
if (-not $KeepDefaultProfile) { Set-SimplyHostTerminalDefault -Guid $terminalProfile.guid }
Write-Host 'Close and reopen Windows Terminal to load the font, Solarized Dark profile, and powerline prompt.'
Write-Host 'To open the themed profile directly: wt -p "SimplyHost PowerShell"'

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
