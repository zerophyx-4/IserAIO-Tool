<#
Build the Flutter Android release APK and ensure the generated artifact is available.
Run this from the repository root:
  .\build_release.ps1
#>

$projectRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Push-Location $projectRoot

try {
    Write-Host "Cleaning Flutter build outputs..."
    flutter clean

    Write-Host "Building release APK..."
    flutter build apk --release --android-skip-build-dependency-validation

    $apkPath = Join-Path $projectRoot "android\app\build\outputs\flutter-apk\app-release.apk"
    if (-Not (Test-Path $apkPath)) {
        $apkPath = Join-Path $projectRoot "android\app\build\outputs\apk\release\app-release.apk"
    }

    if (Test-Path $apkPath) {
        Write-Host "Release APK generated:" $apkPath
        exit 0
    }

    Write-Host "ERROR: Release APK was not found after build."
    exit 1
} finally {
    Pop-Location
}
