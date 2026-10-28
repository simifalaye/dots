#
# Functions
#

function Write-Info($Msg) {
    # Usage:
    #   Write-Info <string>
    #
    # Description:
    #   Writes an informational message to the console in cyan,
    #   prefixed with [INFO].
    #
    # Parameters:
    #   $Msg <string>
    #       The informational message to display.
    #
    # Examples:
    #   Write-Info "Starting installation..."
    #   Write-Info "Successfully configured Windows."
    #
    # Returns:
    #   No output. Writes directly to the console.

    Write-Host "[INFO] $Msg" -ForegroundColor Cyan
}

function Write-Warn($Msg) {
    # Usage:
    #   Write-Warn <string>
    #
    # Description:
    #   Writes a warning message to the console in yellow,
    #   prefixed with [WARN].
    #
    # Parameters:
    #   $Msg <string>
    #       The warning message to display.
    #
    # Examples:
    #   Write-Warn "Application is already installed."
    #   Write-Warn "A restart may be required."
    #
    # Returns:
    #   No output. Writes directly to the console.

    Write-Host "[WARN] $Msg" -ForegroundColor Yellow
}

function Write-Err($Msg) {
    # Usage:
    #   Write-Err <string>
    #
    # Description:
    #   Writes an error message to the console in red,
    #   prefixed with [ERROR].
    #
    # Parameters:
    #   $Msg <string>
    #       The error message to display.
    #
    # Examples:
    #   Write-Err "Installation failed."
    #   Write-Err "Executable could not be found."
    #
    # Returns:
    #   No output. Writes directly to the console.

    Write-Host "[ERROR] $Msg" -ForegroundColor Red
}

function WingetInstall {
    # Usage:
    #   WingetInstall -AppId <string>
    #
    # Description:
    #   Checks whether the specified application is installed using
    #   winget. If the application is not detected, installs it
    #   while accepting package and source agreements.
    #
    # Parameters:
    #   -AppId <string>
    #       The winget package identifier of the application.
    #
    # Examples:
    #   WingetInstall -AppId 'Microsoft.PowerToys'
    #   WingetInstall -AppId '7zip.7zip'
    #
    # Returns:
    #   No explicitly defined return value. Displays installation
    #   information and invokes winget if installation is needed.

    param (
        [Parameter(Mandatory = $true)]
        [string[]]$AppIds
    )

    foreach ($AppId in $AppIds) {
        $isInstalled = winget list --id $AppId 2>$null | Select-String $AppId
        if (-not $isInstalled) {
            Write-Host "Installing $AppId..."
            winget install --id $AppId --accept-package-agreements --accept-source-agreements
        }
    }
}

function WingetUninstall {
    # Usage:
    #   WingetUninstall -AppIds <string[]>
    #
    # Description:
    #   Checks whether each specified application is installed using
    #   winget. Uninstalls detected applications and skips applications
    #   that are not detected.
    #
    # Parameters:
    #   -AppIds <string[]>
    #       One or more winget package identifiers to uninstall.
    #
    # Examples:
    #   WingetUninstall -AppIds 'Microsoft.PowerToys'
    #
    #   WingetUninstall -AppIds @(
    #       'Microsoft.PowerToys',
    #       '7zip.7zip'
    #   )
    #
    # Returns:
    #   No explicitly defined return value. Displays uninstall
    #   messages and invokes winget for detected applications.

    param (
        [Parameter(Mandatory = $true)]
        [string[]]$AppIds
    )

    foreach ($AppId in $AppIds) {
        $isInstalled = winget list --id $AppId 2>$null | Select-String $AppId
        if ($isInstalled) {
            Write-Host "Uninstalling $AppId..."
            winget uninstall --id $AppId
        }
    }
}

function Test-PendingReboot {
    # Usage:
    #   Test-PendingReboot
    #
    # Description:
    #   Checks common Windows registry locations for indicators
    #   that a system restart is pending, including Windows Update,
    #   Component-Based Servicing, pending file rename operations,
    #   and the SCCM client.
    #
    # Parameters:
    #   None.
    #
    # Examples:
    #   $RebootStatus = Test-PendingReboot
    #
    #   if ($RebootStatus.Pending) {
    #       Write-Warn "A restart is pending: $($RebootStatus.Reason)"
    #   }
    #   else {
    #       Write-Info "No reboot requirement detected."
    #   }
    #
    # Returns:
    #   PSCustomObject with the following properties:
    #       Pending <bool>   — Indicates whether a reboot was detected.
    #       Reason  <string> — The reason associated with the last
    #                          detected reboot indicator, or an empty
    #                          string if no indicator was detected.
    #
    # Notes:
    #   If multiple reboot indicators are detected, Reason contains
    #   only the last matching reason checked by the function.

    $pending = $false
    $reason = ""

    # Windows Update pending reboot
    $wuReboot = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue
    if ($wuReboot) {
        $pending = $true
        $reason = "Windows Update"
    }

    # Component-Based Servicing (CBS) pending reboot
    $cbsReboot = Get-Item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' -ErrorAction SilentlyContinue
    if ($cbsReboot) {
        $pending = $true
        $reason = "Component-Based Servicing"
    }

    # Pending file rename operations
    $pendingFileRename = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
    if ($pendingFileRename -and $pendingFileRename.PendingFileRenameOperations) {
        $pending = $true
        $reason = "File rename operations"
    }

    # SCCM/WSUS reboot flag (optional)
    $sccmReboot = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootRequired' -ErrorAction SilentlyContinue
    if ($sccmReboot) {
        $pending = $true
        $reason = "SCCM"
    }

    return [pscustomobject]@{
        Pending = $pending
        Reason = $reason
    }
}

function GetExePath {
  # Usage:
  #   GetExePath -Directories <string[]> -ExeName <string[]>
  #
  # Description:
  #   Recursively searches the specified directories for any of the
  #   specified executable names and returns the first match.
  #   Directories are searched in the order provided.
  #
  # Parameters:
  #   -Directories <string[]>
  #       One or more directory paths to search.
  #
  #   -ExeName <string[]>
  #       One or more executable names to match.
  #
  # Examples:
  #   GetExePath -Directories 'C:\Program Files', 'C:\Program Files (x86)' `
  #     -ExeName 'app.exe', 'app2.exe'
  #
  #   GetExePath -Directories @('C:\Tools', 'D:\Apps') `
  #     -ExeName @('app.exe', 'app2.exe')
  #
  # Returns:
  #   System.IO.FileInfo — the first matching executable, or no output
  #   if no match is found. Can check with `if (-not $Exe)`

  param (
    [Parameter(Mandatory = $true)]
    [string[]]$Directories,

    [Parameter(Mandatory = $true)]
    [string[]]$ExeName
  )

  foreach ($Directory in $Directories) {
    if (Test-Path -LiteralPath $Directory -PathType Container) {
      foreach ($Name in $ExeName) {
        $Result = Get-ChildItem -LiteralPath $Directory `
          -Filter $Name -File -Recurse `
          -ErrorAction SilentlyContinue |
          Select-Object -First 1

        if ($null -ne $Result) {
          return $Result
        }
      }
    }
  }
}

#
# Globals
#

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$gsudo = GetExePath `
    -Directories @(
        (Join-Path $env:ProgramFiles 'gsudo\Current')
    ) `
    -ExeName @('gsudo.exe')
