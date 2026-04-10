$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PipelineScript = Join-Path $RootDir "run_memsifter_pipeline.ps1"
$AutomationDir = Join-Path $RootDir "Automation Script"
$DumpDir = "G:\Telegram_memory_dumps"

if (-not (Test-Path -LiteralPath $PipelineScript -PathType Leaf)) {
    throw "Pipeline script not found: $PipelineScript"
}

if (-not (Test-Path -LiteralPath $AutomationDir -PathType Container)) {
    throw "Automation Script directory not found: $AutomationDir"
}

# Full set:
# $Browsers   = @("chrome", "firefox")
# $TgVersions = @("a", "k")
# $Modes      = @("normal", "private")
# $TabStates  = @("open", "close")

# Current narrowed test set:
$Browsers   = @("chrome")
$TgVersions = @("a")
$Modes      = @("normal")
$TabStates  = @("open")

$CampaignId = Get-Date -Format "yyyyMMdd_HHmmss"

$AutomationFailures = New-Object System.Collections.Generic.List[string]
$ExtractionFailures = New-Object System.Collections.Generic.List[string]
$DumpQueue = New-Object System.Collections.Generic.List[object]

$TotalCount = $Browsers.Count * $TgVersions.Count * $Modes.Count * $TabStates.Count
$RunIndex = 0

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

Write-Host ""
Write-Host "==================== PHASE 1: AUTOMATION ===================="

foreach ($TgVersion in $TgVersions) {
    foreach ($TabState in $TabStates) {
        foreach ($Browser in $Browsers) {
            foreach ($Mode in $Modes) {
                $RunIndex++
                $Label = "${CampaignId}_${Browser}_${TgVersion}_${Mode}_${TabState}"
                $ScenarioFile = Join-Path $AutomationDir "scenario_${TabState}_receiver.yaml"

                if (-not (Test-Path -LiteralPath $ScenarioFile -PathType Leaf)) {
                    throw "Scenario file not found: $ScenarioFile"
                }

                Write-Host ""
                Write-Host "################################################################"
                Write-Host "[*] Automation run $RunIndex/$TotalCount"
                Write-Host "[*] tg_version=$TgVersion, tab_state=$TabState, browser=$Browser, mode=$Mode"
                Write-Host "[*] label=$Label"
                Write-Host "[*] scenario=$ScenarioFile"
                Write-Host "################################################################"

                $MarkerTime = Get-Date

                try {
                    & powershell.exe -ExecutionPolicy Bypass -File $PipelineScript `
                        -Browser $Browser `
                        -TgVersion $TgVersion `
                        -Mode $Mode `
                        -TabState $TabState `
                        -ScenarioFile $ScenarioFile `
                        -DumpDir $DumpDir `
                        -Label $Label `
                        -AutomationOnly

                    if ($LASTEXITCODE -ne 0) {
                        $Failure = "$Browser,$TgVersion,$Mode,$TabState"
                        $AutomationFailures.Add($Failure)
                        Write-Host "[!] Automation failed: $Failure"
                        continue
                    }
                }
                catch {
                    $Failure = "$Browser,$TgVersion,$Mode,$TabState"
                    $AutomationFailures.Add($Failure)
                    Write-Host "[!] Automation failed: $Failure"
                    Write-Host $_
                }
            }
        }
    }
}

Write-Host ""
Write-Host "==================== SUMMARY ===================="
Write-Host "[*] Campaign ID: $CampaignId"
Write-Host "[*] Total combinations: $TotalCount"
Write-Host "[*] Dumps queued: $($DumpQueue.Count)"
Write-Host "[*] Automation failures: $($AutomationFailures.Count)"
Write-Host "[*] Extraction failures: $($ExtractionFailures.Count)"

if ($AutomationFailures.Count -gt 0) {
    Write-Host "[!] Failed during automation:"
    foreach ($Item in $AutomationFailures) {
        Write-Host "    - $Item"
    }
}

if ($ExtractionFailures.Count -gt 0) {
    Write-Host "[!] Failed during extraction:"
    foreach ($Item in $ExtractionFailures) {
        Write-Host "    - $Item"
    }
}

if ($AutomationFailures.Count -gt 0 -or $ExtractionFailures.Count -gt 0) {
    exit 1
}

Write-Host "[*] All runs completed successfully"