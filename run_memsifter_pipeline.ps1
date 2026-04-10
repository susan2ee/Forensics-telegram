param(
    [ValidateSet("chrome", "firefox")]
    [string]$Browser,

    [ValidateSet("a", "k")]
    [string]$TgVersion,

    [ValidateSet("normal", "private")]
    [string]$Mode,

    [ValidateSet("open", "close")]
    [string]$TabState,

    [string]$ScenarioFile = "",
    [string]$DumpDir = "",
    [string]$Dump = "",
    [string]$Label = "",
    [string]$PythonBin = "",

    [switch]$AutomationOnly,
    [switch]$ExtractOnly,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VolDir = Join-Path $RootDir "volatility3"
$AutomationDir = Join-Path $RootDir "Automation Script"
$DumpDirDefault = Join-Path $RootDir "Memory_dumps"

if ([string]::IsNullOrWhiteSpace($DumpDir)) {
    $DumpDir = $DumpDirDefault
}

if ([string]::IsNullOrWhiteSpace($PythonBin)) {
    $PythonBin = "python"
}

function Show-Usage {
    @"
Usage:
  .\run_memsifter_pipeline.ps1 -Browser <chrome|firefox> -TgVersion <a|k> -Mode <normal|private> -TabState <open|close> [options]
  .\run_memsifter_pipeline.ps1 -Dump <path> -TgVersion <a|k> -ExtractOnly [options]

Options:
  -ScenarioFile <path>   Explicit scenario YAML
  -DumpDir <dir>         Directory containing generated memory dumps (default: .\Memory_dumps)
  -Dump <path>           Skip automation and extract a specific dump only
  -Label <text>          Optional log label
  -PythonBin <path>      Python executable to use
  -AutomationOnly        Run automation only, do not run extractor
  -ExtractOnly           Run extractor only; requires -Dump and -TgVersion
  -Help                  Show this help

Examples:
  .\run_memsifter_pipeline.ps1 -Browser chrome -TgVersion a -Mode normal -TabState close
  .\run_memsifter_pipeline.ps1 -Browser firefox -TgVersion k -Mode private -TabState open
  .\run_memsifter_pipeline.ps1 -Browser chrome -TgVersion a -Mode normal -TabState open -AutomationOnly
  .\run_memsifter_pipeline.ps1 -Dump .\Memory_dumps\some_dump.elf -TgVersion a -ExtractOnly
"@
}

function Fail([string]$Message) {
    throw $Message
}

function Resolve-ScenarioFile {
    param(
        [string]$Tab
    )

    if (-not [string]::IsNullOrWhiteSpace($ScenarioFile)) {
        if (Test-Path -LiteralPath $ScenarioFile -PathType Leaf) {
            return (Resolve-Path -LiteralPath $ScenarioFile).Path
        }
        Fail "Scenario file not found: $ScenarioFile"
    }

    $Candidates = @(
        (Join-Path $RootDir "scenario_${Tab}_sender.yaml"),
        (Join-Path $AutomationDir "scenario_${Tab}_sender.yaml"),
        (Join-Path (Join-Path $RootDir "scenarios") "scenario_${Tab}_sender.yaml")
    )

    foreach ($Candidate in $Candidates) {
        if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $Candidate).Path
        }
    }

    Fail "No scenario file found for tab_state='$Tab'"
}

function Get-NewDumps {
    param(
        [string]$TargetDumpDir,
        [datetime]$MarkerTime
    )

    $WantedExts = @(".raw", ".elf", ".dmp", ".dump", ".mem", ".bin")

    if (-not (Test-Path -LiteralPath $TargetDumpDir -PathType Container)) {
        return @()
    }

    $AllFiles = Get-ChildItem -LiteralPath $TargetDumpDir -File |
        Where-Object { $_.LastWriteTime -ge $MarkerTime } |
        Sort-Object LastWriteTime, Name

    $Preferred = $AllFiles | Where-Object { $WantedExts -contains $_.Extension.ToLower() }

    if (@($Preferred).Count -gt 0) {
        return @($Preferred)
    }

    return @($AllFiles)
}

function Wait-ForStableFile {
    param(
        [string]$Path,
        [int]$Checks = 3,
        [int]$DelaySeconds = 2
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Fail "File not found while waiting for stability: $Path"
    }

    $LastSize = -1
    $StableCount = 0

    while ($StableCount -lt $Checks) {
        $CurrentSize = (Get-Item -LiteralPath $Path).Length

        if ($CurrentSize -eq $LastSize) {
            $StableCount++
        }
        else {
            $StableCount = 0
            $LastSize = $CurrentSize
        }

        Start-Sleep -Seconds $DelaySeconds
    }
}

function Run-ExtractorOnDump {
    param(
        [string]$DumpPath,
        [string]$ExtractorTgVersion
    )

    if (-not (Test-Path -LiteralPath $DumpPath -PathType Leaf)) {
        Fail "Dump file not found: $DumpPath"
    }

    $AbsDumpPath = (Resolve-Path -LiteralPath $DumpPath).Path
    Wait-ForStableFile -Path $AbsDumpPath

    Write-Host "[*] Using dump: $AbsDumpPath"
    Write-Host "[*] Running extractor from: $VolDir with tg_version=$ExtractorTgVersion"

    Push-Location $VolDir
    try {
        & $PythonBin "run_telegram_extractor_tool.py" $AbsDumpPath "--tg-version" $ExtractorTgVersion
        if ($LASTEXITCODE -ne 0) {
            Fail "Extractor failed for dump: $AbsDumpPath"
        }
    }
    finally {
        Pop-Location
    }
}

if ($Help) {
    Show-Usage
    exit 0
}

if ($AutomationOnly -and $ExtractOnly) {
    Fail "Use only one of -AutomationOnly or -ExtractOnly."
}

if (-not (Test-Path -LiteralPath $VolDir -PathType Container)) {
    Fail "volatility3 directory not found: $VolDir"
}
if (-not (Test-Path -LiteralPath (Join-Path $VolDir "run_telegram_extractor_tool.py") -PathType Leaf)) {
    Fail "Extractor entrypoint not found: $(Join-Path $VolDir 'run_telegram_extractor_tool.py')"
}

if (-not (Test-Path -LiteralPath $DumpDir -PathType Container)) {
    New-Item -ItemType Directory -Path $DumpDir -Force | Out-Null
}

if ($ExtractOnly) {
    if ([string]::IsNullOrWhiteSpace($Dump)) {
        Fail "-ExtractOnly requires -Dump."
    }
    if ([string]::IsNullOrWhiteSpace($TgVersion)) {
        Fail "-ExtractOnly requires -TgVersion."
    }

    Run-ExtractorOnDump -DumpPath $Dump -ExtractorTgVersion $TgVersion
    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($Dump)) {
    if ([string]::IsNullOrWhiteSpace($TgVersion)) {
        Fail "-Dump requires -TgVersion."
    }

    Run-ExtractorOnDump -DumpPath $Dump -ExtractorTgVersion $TgVersion
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Browser) -or
    [string]::IsNullOrWhiteSpace($TgVersion) -or
    [string]::IsNullOrWhiteSpace($Mode) -or
    [string]::IsNullOrWhiteSpace($TabState)) {
    Show-Usage
    Fail "Browser, TgVersion, Mode, and TabState are required unless -Dump is used."
}

if (-not (Test-Path -LiteralPath $AutomationDir -PathType Container)) {
    Fail "Automation Script directory not found: $AutomationDir"
}
if (-not (Test-Path -LiteralPath (Join-Path $AutomationDir "main.py") -PathType Leaf)) {
    Fail "Automation entrypoint not found: $(Join-Path $AutomationDir 'main.py')"
}

$ScenarioPath = Resolve-ScenarioFile -Tab $TabState

$RunName = "${Browser}_${TgVersion}_${Mode}_${TabState}"
if (-not [string]::IsNullOrWhiteSpace($Label)) {
    $RunName = "${Label}_${RunName}"
}

Write-Host "============================================================"
Write-Host "[*] Starting pipeline run: $RunName"
Write-Host "[*] Scenario: $ScenarioPath"
Write-Host "[*] Dump dir: $DumpDir"
Write-Host "[*] Mode: $(if ($AutomationOnly) { 'AutomationOnly' } else { 'FullPipeline' })"
Write-Host "============================================================"

$MarkerTime = Get-Date

Push-Location $AutomationDir
try {
    "" | & $PythonBin "main.py" `
        "--browser" $Browser `
        "--tg-version" $TgVersion `
        "--mode" $Mode `
        "--scenario-file" $ScenarioPath

    if ($LASTEXITCODE -ne 0) {
        Fail "Automation failed for run: $RunName"
    }
}
finally {
    Pop-Location
}

$Dumps = @(Get-NewDumps -TargetDumpDir $DumpDir -MarkerTime $MarkerTime)

if ($Dumps.Count -eq 0) {
    Fail "No new dump files were created in: $DumpDir"
}

Write-Host "[*] Found $($Dumps.Count) new dump(s)"
foreach ($DumpFile in $Dumps) {
    Write-Host "    - $($DumpFile.FullName)"
}

if ($AutomationOnly) {
    Write-Host "[*] Automation-only mode: skipping extraction"
    exit 0
}

foreach ($DumpFile in $Dumps) {
    Run-ExtractorOnDump -DumpPath $DumpFile.FullName -ExtractorTgVersion $TgVersion
}

Write-Host "[*] Completed pipeline run: $RunName"