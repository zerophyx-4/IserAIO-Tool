$url = 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8+7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.8_7.msi'
$out = Join-Path $env:TEMP 'OpenJDK17U-jdk_x64_windows_hotspot_17.0.8_7.msi'
Write-Output "Downloading JDK from $url to $out"
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
Write-Output "Installing JDK from $out"
Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i', $out, '/qn', '/norestart' -Wait -NoNewWindow
Write-Output 'INSTALLED'
