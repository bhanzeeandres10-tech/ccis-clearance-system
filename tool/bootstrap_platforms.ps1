[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter was not found on PATH. Install the Flutter SDK, restart the terminal, and run 'flutter doctor' before running this script."
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$backupRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ccis-clearance-pwa-" + [guid]::NewGuid())
$preserve = @(
  'web/index.html',
  'web/manifest.json',
  'web/flutter_bootstrap.js',
  'web/sw.js',
  'web/icons/ccis-clearance-icon.svg',
  'web/icons/ccis-clearance-maskable.svg'
)

New-Item -ItemType Directory -Path $backupRoot | Out-Null

try {
  foreach ($relativePath in $preserve) {
    $source = Join-Path $projectRoot $relativePath
    if (Test-Path -LiteralPath $source) {
      $destination = Join-Path $backupRoot $relativePath
      New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
      Copy-Item -LiteralPath $source -Destination $destination -Force
    }
  }

  Push-Location $projectRoot
  try {
    & flutter create . --platforms=android,web
    if ($LASTEXITCODE -ne 0) { throw "flutter create failed with exit code $LASTEXITCODE." }
  }
  finally {
    Pop-Location
  }

  # Flutter uses the package name as the Android label by default. Keep the
  # installed application's name aligned with the CCIS CLEARANCE web manifest.
  $androidManifest = Join-Path $projectRoot 'android/app/src/main/AndroidManifest.xml'
  if (Test-Path -LiteralPath $androidManifest) {
    $manifestContent = Get-Content -LiteralPath $androidManifest -Raw
    $manifestContent = $manifestContent -replace 'android:label="[^"]*"', 'android:label="CCIS CLEARANCE"'
    Set-Content -LiteralPath $androidManifest -Value $manifestContent -NoNewline
  }

  foreach ($relativePath in $preserve) {
    $source = Join-Path $backupRoot $relativePath
    if (Test-Path -LiteralPath $source) {
      $destination = Join-Path $projectRoot $relativePath
      New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
      Copy-Item -LiteralPath $source -Destination $destination -Force
    }
  }

  Push-Location $projectRoot
  try {
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed with exit code $LASTEXITCODE." }
  }
  finally {
    Pop-Location
  }

  Write-Host "CCIS CLEARANCE platforms are ready. Run 'flutter run -d chrome' for web or connect an Android device/emulator."
}
finally {
  if (Test-Path -LiteralPath $backupRoot) {
    Remove-Item -LiteralPath $backupRoot -Recurse -Force
  }
}
