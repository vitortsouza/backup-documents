[CmdletBinding()]
param(
    [string]$Source = "$HOME\Documents",
    [string]$Destination = 'C:\Backup\Documents',
    [string[]]$ExcludeDirs = @('Imagens', 'Pictures', 'Videos', 'Music', 'Músicas'),
    [string]$LogPath = (Join-Path ([System.IO.Path]::GetTempPath()) 'BackupDocuments.log'),
    [switch]$ListOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    throw "Origem não encontrada: $Source"
}

$sourceFull = [System.IO.Path]::GetFullPath($Source).TrimEnd('\', '/')
$destinationFull = [System.IO.Path]::GetFullPath($Destination).TrimEnd('\', '/')

if (
    $destinationFull -eq $sourceFull -or
    $destinationFull.StartsWith($sourceFull + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
) {
    throw "O destino não pode ser igual ou estar dentro da origem."
}

if (-not $ListOnly -and -not (Test-Path -LiteralPath $Destination -PathType Container)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

$robocopyArgs = @(
    $Source,
    $Destination,
    '/E',
    '/Z',
    '/R:2',
    '/W:5',
    '/XO',
    '/XJ'
)

if ($ExcludeDirs -and $ExcludeDirs.Count -gt 0) {
    $robocopyArgs += '/XD'
    $robocopyArgs += $ExcludeDirs
}

if ($ListOnly) {
    $robocopyArgs += '/L'
}

if ($LogPath) {
    $logDirectory = Split-Path -Parent $LogPath
    if ($logDirectory -and -not (Test-Path -LiteralPath $logDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }
    $robocopyArgs += "/LOG+:$LogPath"
    $robocopyArgs += '/TEE'
}

Write-Host "Origem : $Source"
Write-Host "Destino: $Destination"
if ($LogPath) {
    Write-Host "Log    : $LogPath"
}

& robocopy @robocopyArgs
$exitCode = $LASTEXITCODE

if ($exitCode -ge 8) {
    Write-Error "Robocopy retornou o código $exitCode."
    exit $exitCode
}

Write-Host "Backup concluído: $Source -> $Destination (robocopy código $exitCode)"
exit 0
