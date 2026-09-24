# vim: ft=ps1
param(
    [switch]$PostReboot
)

$ErrorActionPreference = 'Stop'

$runOncePath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
$runOnceName = 'ChezmoiSetupWsl'

function Test-UbuntuInstalled {
    $env:WSL_UTF8 = '1'
    try {
        $distros = @(
            wsl.exe --list --quiet 2>$null |
                ForEach-Object { ($_ -replace "`0", '').Trim() } |
                Where-Object { $_ }
        )

        return $distros -contains 'Ubuntu'
    }
    catch {
        return $false
    }
}

function Test-WslComponentsInstalled {
    try {
        $features = @(
            'Microsoft-Windows-Subsystem-Linux'
            'VirtualMachinePlatform'
        )
        $states = $features | ForEach-Object {
            (Get-WindowsOptionalFeature -Online -FeatureName $_).State.ToString()
        }

        return ($states | Where-Object {
            $_ -notin @('Enabled', 'EnablePending')
        }).Count -eq 0
    }
    catch {
        return $false
    }
}

function Install-WslComponents {
    Write-Host 'Installing WSL components...'

    $process = Start-Process `
        -FilePath 'wsl.exe' `
        -ArgumentList '--install', '--no-distribution' `
        -Verb RunAs `
        -Wait `
        -PassThru

    if ($process.ExitCode -notin @(0, 3010, 1641)) {
        throw "wsl --install --no-distribution failed with exit code $($process.ExitCode)"
    }

    return $process.ExitCode
}

function Install-Ubuntu {
    if (Test-UbuntuInstalled) {
        Write-Host 'Ubuntu is already installed in WSL.'
        return
    }

    Write-Host 'Installing Ubuntu in WSL...'

    $process = Start-Process `
        -FilePath 'wsl.exe' `
        -ArgumentList '--install', '-d', 'Ubuntu', '--no-launch' `
        -Wait `
        -PassThru `
        -NoNewWindow

    if ($process.ExitCode -ne 0) {
        throw "wsl --install -d Ubuntu --no-launch failed with exit code $($process.ExitCode)"
    }

    Write-Host 'Ubuntu installed in WSL.'
}

function Set-ResumeCommand {
    $command = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{0}" -PostReboot' -f $PSCommandPath

    New-Item -Path $runOncePath -Force | Out-Null

    New-ItemProperty `
        -Path $runOncePath `
        -Name $runOnceName `
        -Value $command `
        -PropertyType String `
        -Force | Out-Null

    Write-Host 'Registered WSL setup to resume after reboot.'
}

function Remove-ResumeCommand {
    Remove-ItemProperty `
        -Path $runOncePath `
        -Name $runOnceName `
        -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# Phase 2: Resume after reboot
# ---------------------------------------------------------------------------

if ($PostReboot) {
    Write-Host 'Resuming WSL setup after reboot...'

    Remove-ResumeCommand

    if (-not (Test-WslComponentsInstalled)) {
        throw 'WSL components are still not enabled after reboot.'
    }

    Install-Ubuntu
    return
}

# ---------------------------------------------------------------------------
# Phase 1: Install WSL components
# ---------------------------------------------------------------------------

if (Test-UbuntuInstalled) {
    Write-Host 'Ubuntu is already installed in WSL.'
    return
}

if (Test-WslComponentsInstalled) {
    Write-Host 'WSL components are already installed.'
    Install-Ubuntu
    return
}

Set-ResumeCommand

try {
    $exitCode = Install-WslComponents

    if ($exitCode -in @(3010, 1641)) {
        Write-Host 'WSL components installed. A reboot is required.'
        Write-Host 'Setup will resume automatically after the next sign-in.'
        return
    }

    # WSL components were enabled without requiring a reboot.
    Remove-ResumeCommand
    Install-Ubuntu
}
catch {
    Remove-ResumeCommand
    throw
}
