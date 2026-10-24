#Requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('menu','doctor','health','ports','storage','inventory','backup','backup-check','new-service','logs','compose-update','template')]
    [string]$Tool = 'menu',
    [string]$Source, [string]$Destination, [int]$Keep = 7, [double]$MaxAgeHours = 48,
    [string]$Directory, [string]$OutputPath, [int[]]$Port = @(),
    [ValidateSet('container','service','compose')][string]$Kind,
    [string]$Name, [switch]$Follow, [switch]$Strict,
    [switch]$NoPrompt, [switch]$AddCommand, [switch]$Help
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$installerSource = $PSCommandPath
if ($Help) {
    @'
Native Windows tools (PowerShell 5.1+):
  windows.ps1 -Tool menu
  windows.ps1 -Tool doctor [-Strict]
  windows.ps1 -Tool health
  windows.ps1 -Tool ports [-Port 80,443]
  windows.ps1 -Tool storage
  windows.ps1 -Tool inventory [-OutputPath NEW.json]
  windows.ps1 -Tool backup -Source DIRECTORY -Destination DIRECTORY [-Keep 7]
  windows.ps1 -Tool backup-check -Destination DIRECTORY [-MaxAgeHours 48]
  windows.ps1 -Tool new-service [-Directory NEW_DIRECTORY]
  windows.ps1 -Tool logs [-Kind container|compose|service] [-Name NAME] [-Directory DIRECTORY] [-Follow]
  windows.ps1 -Tool compose-update [-Directory DIRECTORY]
Backup tools require Python 3.8+. Docker tools require a running Docker daemon and Compose v2.
Windows service logs use the System event log; systemd is Linux-only.
Repeat shortcuts: -AddCommand, or answer the optional profile question. -NoPrompt skips optional questions.
'@
    return
}
if ($env:OS -ne 'Windows_NT') { throw 'Use the .sh tools on macOS/Linux.' }
function Ask([string]$Message) {
    if ([Console]::IsInputRedirected) { throw "Supply arguments for unattended use: $Message" }
    $value = Read-Host $Message
    if ([string]::IsNullOrWhiteSpace($value)) { throw 'A value is required.' }
    return $value
}
function Confirm-Action([string]$Message) {
    if ([Console]::IsInputRedirected) { throw 'Run interactively to confirm this operation.' }
    return (Read-Host ($Message + ' [y/N]')) -match '^(y|yes)$'
}
function Invoke-Docker {
    # Keep this a simple function: advanced-function common parameters consume Docker's -d.
    & docker.exe @args
    if ($LASTEXITCODE -ne 0) { throw ('Docker failed: ' + ($args -join ' ')) }
}
function Require-Docker {
    if (-not (Get-Command docker.exe -ErrorAction SilentlyContinue)) { throw 'Install and start Docker Desktop (or configure a Docker context) first.' }
    Invoke-Docker info | Out-Null
    Invoke-Docker compose version | Out-Host
}
function Enter-Project([string]$Path) {
    if (-not $Path) { $Path = Ask 'Compose project directory' }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw 'Project directory does not exist.' }
    Push-Location -LiteralPath $Path
    try {
        if (-not (@('compose.yaml','compose.yml','docker-compose.yaml','docker-compose.yml') | Where-Object { Test-Path -LiteralPath $_ })) { throw 'No Compose file in this directory.' }
        Invoke-Docker compose config --quiet
    } catch { Pop-Location; throw }
}
function Write-NewFile([string]$Path, [string]$Content) {
    $stream = New-Object IO.FileStream($Path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $bytes = $utf8.GetBytes($Content); $stream.Write($bytes,0,$bytes.Length) } finally { $stream.Dispose() }
}
function Get-Disks {
    @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID, Size, FreeSpace)
}
function Show-Diagnostics([switch]$Health) {
    $issues = 0
    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    Write-Host ($os.Caption + ' | ' + $env:COMPUTERNAME)
    Write-Host ('Uptime: ' + ((Get-Date) - $os.LastBootUpTime))
    Write-Host ('Memory available: {0:P1}' -f ($os.FreePhysicalMemory / $os.TotalVisibleMemorySize))
    if ($os.FreePhysicalMemory / $os.TotalVisibleMemorySize -lt 0.1) { Write-Warning 'Less than 10% memory available.'; $issues++ }
    $disks = @(Get-Disks)
    $disks | Format-Table | Out-Host
    foreach ($disk in $disks) { if ($disk.Size -gt 0 -and $disk.FreeSpace / $disk.Size -lt 0.1) { Write-Warning ('Low disk space: ' + $disk.DeviceID); $issues++ } }
    if (-not $Health) {
        foreach ($command in @('curl.exe','tar.exe','python.exe','docker.exe')) {
            if (Get-Command $command -ErrorAction SilentlyContinue) { Write-Host "Available: $command" }
            else { Write-Warning "Missing: $command"; $issues++ }
        }
        Get-NetIPConfiguration | Format-Table InterfaceAlias,IPv4Address,IPv4DefaultGateway | Out-Host
        Write-Host ('Logical CPUs: ' + $computer.NumberOfLogicalProcessors)
    }
    if (Get-Command docker.exe -ErrorAction SilentlyContinue) {
        try {
            $ids = @(Invoke-Docker ps -aq)
            Invoke-Docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | Out-Host
            if ($Health) {
                foreach ($id in $ids) {
                    $container = @(Invoke-Docker inspect $id | ConvertFrom-Json)[0]
                    $state = $container.State
                    $badHealth = $state.PSObject.Properties['Health'] -and $state.Health.Status -ne 'healthy'
                    if ($state.Status -notin @('running','exited') -or $badHealth -or ($state.Status -eq 'exited' -and $state.ExitCode -ne 0)) { $issues++ }
                }
            }
        } catch { Write-Warning $_.Exception.Message; $issues++ }
    }
    Write-Host "Findings: $issues"
    return $issues
}
function Invoke-Inventory {
    $errors = New-Object 'System.Collections.Generic.List[object]'
    function Collect([scriptblock]$Block, [string]$Label) {
        try { & $Block } catch { $errors.Add(@{command=$Label; error=$_.Exception.Message}); return $null }
    }
    $os = Collect { Get-CimInstance Win32_OperatingSystem } 'OS'
    $computer = Collect { Get-CimInstance Win32_ComputerSystem } 'Computer'
    $result = [ordered]@{
        schema_version = 1; collected_at = [DateTime]::UtcNow.ToString('o')
        hostname = $env:COMPUTERNAME; os = 'Windows'; release = $null; architecture = $env:PROCESSOR_ARCHITECTURE
        logical_cpus = [Environment]::ProcessorCount; memory_bytes = $null
        block_devices = @(Collect { Get-Disks } 'Disks')
        interfaces = @(Collect { Get-NetIPAddress | Select-Object InterfaceAlias,IPAddress,AddressFamily } 'Addresses')
        routes = @(Collect { Get-NetRoute | Select-Object DestinationPrefix,NextHop,InterfaceAlias,RouteMetric } 'Routes')
        errors = $errors
    }
    if ($os) { $result.release = $os.Version }
    if ($computer) { $result.memory_bytes = $computer.TotalPhysicalMemory }
    $json = ($result | ConvertTo-Json -Depth 10) + "`n"
    if ($OutputPath) { Write-NewFile ([IO.Path]::GetFullPath($OutputPath)) $json; Write-Host "Saved $OutputPath" }
    else { Write-Output $json }
}
function Invoke-Ports {
    foreach ($value in $Port) { if ($value -lt 1 -or $value -gt 65535) { throw 'Ports must be between 1 and 65535.' } }
    $listeners = @(
        Get-NetTCPConnection | Where-Object State -eq Listen | Select-Object @{n='Protocol';e={'TCP'}},LocalAddress,LocalPort,OwningProcess
        Get-NetUDPEndpoint | Select-Object @{n='Protocol';e={'UDP'}},LocalAddress,LocalPort,OwningProcess
    )
    if ($Port.Count) { $listeners = @($listeners | Where-Object { $_.LocalPort -in $Port }) }
    $listeners | Sort-Object LocalPort,Protocol | Format-Table | Out-Host
    if ($Port.Count -and $listeners.Count) { throw 'One or more requested ports are occupied.' }
}
function Invoke-NewService {
    if (-not $Directory) { $Directory = Ask 'New project directory' }
    $service = Ask 'Service name (lowercase letters, digits, hyphens; start with a letter)'
    if ($service -notmatch '^[a-z][a-z0-9-]*$') { throw 'Invalid service name.' }
    $image = Ask 'Image with explicit tag or digest'
    if ($image -notmatch '^[a-zA-Z0-9][a-zA-Z0-9._/:@-]+$' -or ($image -notmatch '@sha256:' -and ($image.Split('/')[-1] -notmatch ':'))) { throw 'Supply an image with a tag or digest.' }
    $internal = 0; $external = 0
    if (-not [int]::TryParse((Ask 'Container port'),[ref]$internal) -or $internal -lt 1 -or $internal -gt 65535) { throw 'Invalid container port.' }
    if (-not [int]::TryParse((Ask 'Localhost port'),[ref]$external) -or $external -lt 1 -or $external -gt 65535) { throw 'Invalid host port.' }
    $mount = Ask 'Absolute data path inside container (e.g. /data)'
    if (-not $mount.StartsWith('/') -or $mount -match '[\r\n]') { throw 'Use an absolute Linux-container data path.' }
    $health = Ask 'HTTP health endpoint inside container (e.g. http://localhost:80/)'
    if ($health -notmatch '^https?://' -or $health -match '[\r\n]') { throw 'Use an HTTP(S) URL.' }
    if (Test-Path -LiteralPath $Directory) { throw 'Project directory exists; nothing was overwritten.' }
    # CreateDirectory is not exclusive; use New-Item without -Force to reject a concurrent creator.
    New-Item -ItemType Directory -Path $Directory -ErrorAction Stop | Out-Null
    $target = (Resolve-Path -LiteralPath $Directory).ProviderPath
    [IO.Directory]::CreateDirectory((Join-Path $target 'data')) | Out-Null
    Write-NewFile (Join-Path $target '.env') "IMAGE=$image`nHOST_PORT=$external`nCONTAINER_PORT=$internal`n"
    $serviceJson = ConvertTo-Json $service -Compress
    $mountJson = ConvertTo-Json $mount -Compress
    $checkJson = ConvertTo-Json -InputObject @('CMD','wget','-q','--spider',$health) -Compress
    $compose = @'
services:
  SERVICE:
    image: "${IMAGE:?Set IMAGE in .env}"
    restart: unless-stopped
    ports:
      - "127.0.0.1:${HOST_PORT}:${CONTAINER_PORT}"
    volumes:
      - type: bind
        source: ./data
        target: MOUNT
    healthcheck:
      test: CHECK
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s
'@
    $compose = [regex]::Replace($compose, 'SERVICE:|MOUNT|CHECK', [System.Text.RegularExpressions.MatchEvaluator]{
        param($match)
        switch ($match.Value) {
            'SERVICE:' { return $serviceJson + ':' }
            'MOUNT' { return $mountJson }
            'CHECK' { return $checkJson }
        }
    })
    Write-NewFile (Join-Path $target 'compose.yaml') $compose
    Write-NewFile (Join-Path $target '.gitignore') ".env`ndata/`n.simplyhost-updates/`n"
    Write-NewFile (Join-Path $target 'README.md') "# $service`n`nReview paths, permissions, and image requirements. Health checks require wget inside the container. Ports bind to localhost. Back up application data before upgrades.`n`nStart: docker compose config --quiet; docker compose up -d --wait`n"
    Write-Host "Created $target"
}
function Invoke-Logs {
    if (-not $Kind) { $Kind = Ask 'Log source: container, compose, or service' }
    if ($Kind -eq 'service') {
        if (-not $Name) { $Name = Ask 'Windows service name (Service Control Manager events)' }
        if ($Follow) { throw 'Follow mode is supported for Docker logs; rerun without -Follow for Windows service events.' }
        $service = Get-Service -Name $Name -ErrorAction Stop
        Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Service Control Manager'} -MaxEvents 1000 |
            Where-Object { $_.Message -like ('*' + $service.DisplayName + '*') -or $_.Message -like ('*' + $service.Name + '*') } |
            Select-Object -First 100 TimeCreated,Id,LevelDisplayName,Message | Format-List | Out-Host
    } elseif ($Kind -in @('container','compose')) {
        Require-Docker
        $arguments = @('logs','--tail','100')
        if ($Follow) { $arguments += '--follow' }
        if ($Kind -eq 'container') {
            if (-not $Name) { Invoke-Docker ps -a --format '{{.Names}}' | Out-Host; $Name = Ask 'Container name' }
            Invoke-Docker @arguments '--' $Name | Out-Host
        } else {
            Enter-Project $Directory
            try { Invoke-Docker compose @arguments | Out-Host } finally { Pop-Location }
        }
    } else { throw 'Use container, compose, or service.' }
}
function Invoke-ComposeUpdate {
    Require-Docker
    Enter-Project $Directory
    $lock = $null
    try {
        $lockPath = Join-Path (Get-Location).ProviderPath '.simplyhost-update.lock'
        $lock = New-Object IO.FileStream($lockPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
        $configJson = (Invoke-Docker compose config --format json) -join "`n"
        $config = $configJson | ConvertFrom-Json
        $services = @($config.services.PSObject.Properties)
        if (-not $services.Count) { throw 'No services found.' }
        foreach ($entry in $services) {
            $service = $entry.Value
            if ($entry.Name -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_.-]*$' -or $service.PSObject.Properties['build'] -or -not $service.PSObject.Properties['image'] -or $service.PSObject.Properties['profiles']) { throw 'Use image-only services without profiles.' }
            if ($service.PSObject.Properties['deploy'] -and $service.deploy.PSObject.Properties['replicas'] -and $service.deploy.replicas -ne 1) { throw 'Only one container per service is supported.' }
        }
        Invoke-Docker compose ps | Out-Host
        Invoke-Docker compose config --images | Out-Host
        Write-Host 'Application data must already be backed up. Image rollback cannot reverse migrations.'
        if (-not (Confirm-Action 'Save configuration/current images and pull configured tags?')) { return }
        $snapshot = Join-Path (Get-Location).ProviderPath ('.simplyhost-updates\update-' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmss') + '-' + [guid]::NewGuid().ToString('N'))
        [IO.Directory]::CreateDirectory($snapshot) | Out-Null
        # Resolved configuration can contain secrets; restrict its directory to this user.
        $acl = New-Object Security.AccessControl.DirectorySecurity
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
        $acl.SetOwner($identity)
        $acl.SetAccessRuleProtection($true,$false)
        $rule = New-Object Security.AccessControl.FileSystemAccessRule($identity,'FullControl','ContainerInherit,ObjectInherit','None','Allow')
        $acl.AddAccessRule($rule)
        Set-Acl -LiteralPath $snapshot -AclObject $acl
        Write-NewFile (Join-Path $snapshot 'config.json') $configJson
        Write-NewFile (Join-Path $snapshot 'compose.yaml') ((Invoke-Docker compose config) -join "`n")
        $rollback = "services:`n"
        foreach ($entry in $services) {
            $ids = @(Invoke-Docker compose ps --all --quiet $entry.Name)
            if ($ids.Count -ne 1) { throw ('Expected one running container: ' + $entry.Name) }
            $container = @(Invoke-Docker inspect $ids[0] | ConvertFrom-Json)[0]
            if ($container.State.Status -ne 'running' -or ($container.State.PSObject.Properties['Health'] -and $container.State.Health.Status -ne 'healthy')) { throw ('Service is not healthy: ' + $entry.Name) }
            $tag = ('simplyhost-rollback/' + $config.name + '-' + $entry.Name + ':' + (Split-Path -Leaf $snapshot)).ToLowerInvariant()
            Invoke-Docker image tag $container.Image $tag | Out-Host
            $rollback += '  ' + (ConvertTo-Json $entry.Name -Compress) + ":`n    image: " + (ConvertTo-Json $tag -Compress) + "`n    pull_policy: never`n"
        }
        Write-NewFile (Join-Path $snapshot 'rollback.yaml') $rollback
        $locationQuote = (Get-Location).ProviderPath.Replace("'","''")
        $snapshotQuote = $snapshot.Replace("'","''")
        $projectQuote = ([string]$config.name).Replace("'","''")
        $restore = "Set-Location -LiteralPath '$locationQuote'`r`n" + "& docker.exe compose --project-name '$projectQuote' --file '$snapshotQuote\compose.yaml' --file '$snapshotQuote\rollback.yaml' up -d --pull never --no-build --wait --wait-timeout 120`r`n" + 'if ($LASTEXITCODE -ne 0) { throw "Rollback failed." }'
        Write-NewFile (Join-Path $snapshot 'rollback.ps1') $restore
        Write-Host "Saved rollback: $snapshot\rollback.ps1"
        Invoke-Docker compose pull | Out-Host
        if (-not (Confirm-Action 'Recreate services and wait for health checks?')) { return }
        try { Invoke-Docker compose up -d --pull never --no-build --wait --wait-timeout 120 | Out-Host }
        catch { throw "Update failed. Inspect logs and data-migration compatibility before running $snapshot\rollback.ps1" }
        Invoke-Docker compose ps | Out-Host
    } finally {
        try { if ($lock) { $lock.Dispose(); Remove-Item -LiteralPath $lockPath -Force } }
        finally { Pop-Location }
    }
}
function Invoke-BackupTool {
    if (-not $Destination) { $Destination = Ask 'Backup destination directory' }
    if ($Keep -lt 1 -or $MaxAgeHours -le 0) { throw 'Keep and MaxAgeHours must be positive.' }
    $python = $null
    foreach ($candidate in @('python.exe','python3.exe')) {
        $command = Get-Command $candidate -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            & $command.Source -c 'import sys; sys.exit(0 if sys.version_info >= (3,8) else 1)' 2>$null
            if ($LASTEXITCODE -eq 0) { $python = $command.Source; break }
        }
    }
    if (-not $python) { throw 'Backup tools need Python 3.8+. Install Python from python.org, reopen PowerShell, and rerun.' }
    $scripts = @{}
    $scripts['backup'] = @'
import datetime, hashlib, json, os, tarfile, tempfile, sys
from pathlib import Path
source, dest = (Path(p).expanduser().resolve() for p in sys.argv[1:3])
keep = int(sys.argv[3])
if not source.is_dir(): raise SystemExit('Source is not a directory.')
if dest == source or source in dest.parents: raise SystemExit('Backup destination must be outside the source.')
os.umask(0o077)
dest.mkdir(parents=True, exist_ok=True)
key = hashlib.sha256(str(source).encode()).hexdigest()[:16]
lock = (dest/('.simplyhost-'+key+'.lock')).open('a')
try:
    if os.name == 'nt':
        import msvcrt
        if lock.tell() == 0: lock.write('0'); lock.flush()
        lock.seek(0)
        msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
    else:
        import fcntl
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    raise SystemExit('A backup of this source is already running or its lock cannot be acquired.')
# A private staging directory keeps incomplete archives out of backup-check/retention.
with tempfile.TemporaryDirectory(prefix='.simplyhost-', dir=dest) as temporary:
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    name = f'simplyhost-backup-{key}-{stamp}.tar.gz'
    archive = Path(temporary)/name
    with tarfile.open(archive, 'w:gz', dereference=False) as tar:
        tar.add(source, arcname='data', recursive=True)
    # Reading every byte validates gzip CRC and tar payload readability.
    with tarfile.open(archive, 'r:gz') as tar:
        for member in tar:
            if member.isfile():
                with tar.extractfile(member) as f:
                    while f.read(1024*1024): pass
    digest = hashlib.file_digest(archive.open('rb'), 'sha256').hexdigest() if hasattr(hashlib, 'file_digest') else None
    if digest is None:
        h = hashlib.sha256()
        with archive.open('rb') as f:
            for chunk in iter(lambda: f.read(1024*1024), b''): h.update(chunk)
        digest = h.hexdigest()
    metadata = {'schema_version':1, 'source':str(source), 'created_at':datetime.datetime.now(datetime.timezone.utc).isoformat(), 'sha256':digest}
    sidecar = Path(temporary)/(name+'.json')
    sidecar.write_text(json.dumps(metadata, indent=2)+'\n')
    archive.rename(dest/name)
    sidecar.rename(dest/sidecar.name)
# Only prune matching, complete SimplyHost archives after a verified backup succeeds.
archives = sorted(p for p in dest.glob(f'simplyhost-backup-{key}-*.tar.gz') if not p.is_symlink() and p.is_file() and Path(str(p)+'.json').is_file())
for old in archives[:-keep]:
    old.unlink(); Path(str(old)+'.json').unlink()
    print('Pruned '+old.name)
print('Verified backup: '+str(dest/name))
print('Restore into an empty directory: tar -xzf ARCHIVE -C EMPTY_DIRECTORY (files are under data/).')
'@
    $scripts['backup-check'] = @'
import datetime, hashlib, json, re, sys, tarfile
from pathlib import Path
path = Path(sys.argv[1]).expanduser()
if not path.is_dir(): raise SystemExit('Backup directory does not exist.')
archives = sorted(path.glob('simplyhost-backup-*.tar.gz'))
if not archives: raise SystemExit('MISSING: no SimplyHost backups found.')
errors = 0
newest = {}
for archive in archives:
    try:
        if archive.is_symlink(): raise ValueError('Archive is a symlink')
        if not re.fullmatch(r'simplyhost-backup-[0-9a-f]{16}-[0-9]{8}T[0-9]{12}Z.tar.gz', archive.name):
            raise ValueError('Unexpected archive filename')
        meta = json.loads(Path(str(archive)+'.json').read_text())
        if not isinstance(meta['source'], str): raise ValueError('Invalid source')
        h = hashlib.sha256()
        with archive.open('rb') as f:
            for chunk in iter(lambda: f.read(1024*1024), b''): h.update(chunk)
        if h.hexdigest() != meta['sha256']: raise ValueError('Checksum mismatch')
        with tarfile.open(archive, 'r:gz') as tar:
            for member in tar:
                if member.isfile():
                    with tar.extractfile(member) as f:
                        while f.read(1024*1024): pass
        date = datetime.datetime.fromisoformat(meta['created_at'])
        age = (datetime.datetime.now(datetime.timezone.utc)-date).total_seconds()/3600
        if age < -1: raise ValueError('Backup date is in the future')
        newest[meta['source']] = min(newest.get(meta['source'], float('inf')), age)
        print('OK: '+archive.name)
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError, EOFError) as e:
        errors += 1; print('FAILED: '+archive.name+': '+str(e))
for source, age in newest.items():
    print(f'{"STALE" if age > float(sys.argv[2]) else "FRESH"}: {source} -- {age:.1f} hours')
    if age > float(sys.argv[2]): errors += 1
raise SystemExit(1 if errors else 0)
'@
    $arguments = @($Destination, $MaxAgeHours.ToString([Globalization.CultureInfo]::InvariantCulture))
    if ($Tool -eq 'backup') {
        if (-not $Source) { $Source = Ask 'Source directory' }
        $arguments = @($Source, $Destination, [string]$Keep)
    }
    $scripts[$Tool] | & $python - @arguments
    if ($LASTEXITCODE -ne 0) { throw 'Backup operation reported an error; see the output above.' }
}
function Add-RepeatCommand {
    if ($NoPrompt -and -not $AddCommand) { return }
    if (-not $AddCommand -and ([Console]::IsInputRedirected -or -not (Confirm-Action ("Add sh-$Tool to your PowerShell profile for repeat use?")))) { return }
    $saved = Join-Path $env:LOCALAPPDATA 'SimplyHost\scripts\windows.ps1'
    [IO.Directory]::CreateDirectory((Split-Path -Parent $saved)) | Out-Null
    if ([IO.Path]::GetFullPath($saved) -ne [IO.Path]::GetFullPath($installerSource)) { Copy-Item -LiteralPath $installerSource -Destination $saved -Force }
    $profilePath = $PROFILE.CurrentUserAllHosts
    [IO.Directory]::CreateDirectory((Split-Path -Parent $profilePath)) | Out-Null
    $content = ''
    if (Test-Path -LiteralPath $profilePath) { $content = [IO.File]::ReadAllText($profilePath) }
    $block = "# BEGIN SimplyHost $Tool command`r`nfunction global:sh-$Tool { & '" + $saved.Replace("'","''") + "' -Tool '$Tool' @args }`r`n# END SimplyHost $Tool command"
    $pattern = '(?ms)^# BEGIN SimplyHost ' + [regex]::Escape($Tool) + ' command\r?\n.*?^# END SimplyHost ' + [regex]::Escape($Tool) + ' command(?=\r?$)'
    if ([regex]::IsMatch($content,$pattern)) { $content = [regex]::Replace($content,$pattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m) $block}) }
    else { $content += "`r`n" + $block + "`r`n" }
    if ((Test-Path -LiteralPath $profilePath) -and [IO.File]::ReadAllText($profilePath) -ne $content) { Copy-Item -LiteralPath $profilePath -Destination ($profilePath + '.simplyhost-' + [guid]::NewGuid().ToString('N') + '.bak') }
    [IO.File]::WriteAllText($profilePath,$content,(New-Object System.Text.UTF8Encoding($true)))
    Write-Host "Saved sh-$Tool. Open a new PowerShell session to use it."
}
function Show-Menu {
    $tools = @('doctor','health','ports','storage','inventory','backup','backup-check','new-service','logs','compose-update','nvim','powershell')
    while ($true) {
        for ($index=0; $index -lt $tools.Count; $index++) { Write-Host ("{0}. {1}" -f ($index+1), $tools[$index]) }
        $answer = Ask 'Tool number, or q to quit'
        if ($answer -eq 'q') { return }
        $selected = 0
        if (-not [int]::TryParse($answer,[ref]$selected) -or $selected -lt 1 -or $selected -gt $tools.Count) { Write-Host 'Invalid selection.'; continue }
        $chosen = $tools[$selected-1]
        try {
            if ($chosen -in @('nvim','powershell')) {
                $temporary = Join-Path ([IO.Path]::GetTempPath()) ('simplyhost-' + [guid]::NewGuid().ToString('N') + '.ps1')
                try { Invoke-WebRequest -UseBasicParsing -Uri ("https://scripts.simplyhost.org/$chosen.ps1") -OutFile $temporary; & $temporary }
                finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary } }
            } else { & $installerSource -Tool $chosen }
        } catch { Write-Warning $_.Exception.Message }
    }
}
switch ($Tool) {
    menu { Show-Menu }
    doctor { $issues = Show-Diagnostics; if ($Strict -and $issues -gt 0) { throw "$issues findings." } }
    health { $issues = Show-Diagnostics -Health; if ($issues -gt 0) { throw "$issues findings." } }
    ports { Invoke-Ports }
    storage { Get-Disks | Format-Table | Out-Host; Get-Disk | Format-Table Number,FriendlyName,PartitionStyle,OperationalStatus,Size | Out-Host }
    inventory { Invoke-Inventory }
    backup { Invoke-BackupTool }
    backup-check { Invoke-BackupTool }
    new-service { Invoke-NewService }
    logs { Invoke-Logs }
    compose-update { Invoke-ComposeUpdate }
    template { Write-Host 'SimplyHost script template. Copy this script and replace its action with your own.' }
}
# Reports keep stdout suitable for JSON consumers.
Add-RepeatCommand
