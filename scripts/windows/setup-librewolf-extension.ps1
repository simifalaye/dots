# vim: ft=ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$AddonId,

    [string]$PolicyFile = "$env:ProgramFiles\LibreWolf\distribution\policies.json"
)

$ErrorActionPreference = 'Stop'

# Require jq.
if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
    throw "jq is required but was not found in PATH."
}

if (-not (Test-Path -LiteralPath (Split-Path -Parent $PolicyFile))) {
    throw "Policy directory does not exist: $PolicyFile"
}

# Load existing JSON or initialize an empty object.
$json = if (Test-Path -LiteralPath $PolicyFile) {
    [System.IO.File]::ReadAllText($PolicyFile)
} else {
    '{}'
}

# Validate existing JSON.
$json | jq -e 'type == \"object\"' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Invalid policy JSON: $PolicyFile"
}

# Update the extension policy while preserving everything else.
$updated = $json | jq --arg id $AddonId `
                      --arg url "https://addons.mozilla.org/firefox/downloads/latest/$AddonId/latest.xpi" '
    .policies = (.policies // {}) |
    .policies.ExtensionSettings = (.policies.ExtensionSettings // {}) |
    .policies.ExtensionSettings[$id] = {
        installation_mode: \"normal_installed\",
        install_url: $url,
        private_browsing: true
    }
'
if ($LASTEXITCODE -ne 0) {
    throw "Failed to update extension policy."
}

# Verify the required settings.
$updated | jq -e --arg id $AddonId '
    .policies.ExtensionSettings[$id] == {
        installation_mode: \"normal_installed\",
        install_url: (\"https://addons.mozilla.org/firefox/downloads/latest/\" + $id + \"/latest.xpi\"),
        private_browsing: true
    }
' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Extension policy validation failed."
}

# Skip the write if the JSON is already equivalent.
$before = ($json | jq -cS '.')
$after  = ($updated | jq -cS '.')

if ($LASTEXITCODE -ne 0) {
    throw "Failed to compare policy JSON."
}

if ($before -ceq $after) {
    Write-Host "Extension policy is already configured."
    return
}

# Write UTF-8 without BOM.
$utf8 = New-Object System.Text.UTF8Encoding($false)
$temp = [System.IO.Path]::GetTempFileName()

try {
    [System.IO.File]::WriteAllText($temp, ($updated -join "`n") + "`n", $utf8)
    Move-Item -LiteralPath $temp -Destination $PolicyFile -Force
}
finally {
    if (Test-Path -LiteralPath $temp) {
        Remove-Item -LiteralPath $temp -Force
    }
}

Write-Host "Extension policy configured: $AddonId"
