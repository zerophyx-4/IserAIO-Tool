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

    Write-Host "Building release APK with Gradle directly..."
    Set-Location "${projectRoot}\android"
    .\gradlew.bat clean assembleRelease

    $apkSource = Join-Path $projectRoot "android\app\build\outputs\apk\release\app-release.apk"
    $apkOutputDir = Join-Path $projectRoot "build\app\outputs\flutter-apk"
    $apkOutput = Join-Path $apkOutputDir "app-release.apk"

    if (-Not (Test-Path $apkSource)) {
        Write-Host "ERROR: Gradle did not generate the expected APK at $apkSource"
        exit 1
    }

    if (-Not (Test-Path $apkOutputDir)) {
        New-Item -ItemType Directory -Path $apkOutputDir | Out-Null
    }

    Copy-Item -Path $apkSource -Destination $apkOutput -Force
    Write-Host "Release APK generated:" $apkOutput
    exit 0
} finally {
    Pop-Location
}
