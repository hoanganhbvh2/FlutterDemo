# Automated Mobile Build Script for APK & AAB (Google Play / CH Play)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (Test-Path "$ScriptDir\flutter_demo") {
    $FlutterDir = "$ScriptDir\flutter_demo"
} else {
    $FlutterDir = $ScriptDir
}
Set-Location $FlutterDir

Write-Host '========================================================' -ForegroundColor Cyan
Write-Host '🚀 AUTOMATED FLUTTER PRODUCTION BUILD PROCESS STARTED' -ForegroundColor Cyan
Write-Host '========================================================' -ForegroundColor Cyan

$ConfigFile = "$FlutterDir\app_config.json"
if (-not (Test-Path $ConfigFile)) {
    Write-Error "File app_config.json not found at: $ConfigFile"
    exit 1
}

Write-Host 'Reading configuration from app_config.json...' -ForegroundColor Yellow
$Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

$AppName = $Config.appName
$PackageName = $Config.packageName
$VersionName = $Config.versionName
$VersionCode = $Config.versionCode
$ApiBaseUrl = $Config.apiBaseUrl
$Env = $Config.environment

Write-Host "   App Name: $AppName" -ForegroundColor Green
Write-Host "   Package Name: $PackageName" -ForegroundColor Green
Write-Host "   Version: $VersionName+$VersionCode" -ForegroundColor Green
Write-Host "   API Server URL: $ApiBaseUrl" -ForegroundColor Green
Write-Host "   Environment: $Env" -ForegroundColor Green

# 1. Update pubspec.yaml
$PubspecFile = "$FlutterDir\pubspec.yaml"
if (Test-Path $PubspecFile) {
    Write-Host 'Updating pubspec.yaml...' -ForegroundColor Yellow
    $PubContent = Get-Content $PubspecFile -Raw
    $PubContent = $PubContent -replace '(?m)^version:\s*.*$', "version: $VersionName+$VersionCode"
    Set-Content -Path $PubspecFile -Value $PubContent -NoNewline
}

# 2. Update android/app/build.gradle.kts
$GradleFile = "$FlutterDir\android\app\build.gradle.kts"
if (Test-Path $GradleFile) {
    Write-Host 'Updating android/app/build.gradle.kts...' -ForegroundColor Yellow
    $GradleContent = Get-Content $GradleFile -Raw
    $GradleContent = $GradleContent -replace 'namespace\s*=\s*".*?"', "namespace = `"$PackageName`""
    $GradleContent = $GradleContent -replace 'applicationId\s*=\s*".*?"', "applicationId = `"$PackageName`""
    Set-Content -Path $GradleFile -Value $GradleContent -NoNewline
}

# 3. Update AndroidManifest.xml
$ManifestFile = "$FlutterDir\android\app\src\main\AndroidManifest.xml"
if (Test-Path $ManifestFile) {
    Write-Host 'Updating AndroidManifest.xml label...' -ForegroundColor Yellow
    $ManifestContent = Get-Content $ManifestFile -Raw
    $ManifestContent = $ManifestContent -replace 'android:label=".*?"', "android:label=`"$AppName`""
    Set-Content -Path $ManifestFile -Value $ManifestContent -NoNewline
}

# 4. Clean & Fetch
Write-Host 'Running flutter clean...' -ForegroundColor Yellow
flutter clean

Write-Host 'Fetching packages (flutter pub get)...' -ForegroundColor Yellow
flutter pub get

# 5. Analyze
Write-Host 'Running flutter analyze...' -ForegroundColor Yellow
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
flutter analyze --no-fatal-infos
$analyzeResult = $LASTEXITCODE
$ErrorActionPreference = $prevEap

if ($analyzeResult -ne 0) {
    Write-Error 'flutter analyze failed with errors. Please fix them before building release.'
    exit 1
}
Write-Host 'Flutter analyze completed successfully!' -ForegroundColor Green

# 6. Create Output Folder
$OutputDir = "$FlutterDir\build_output"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$CleanAppName = "HocMeo"
$ApkTargetName = "$CleanAppName-v$VersionName-build$VersionCode.apk"
$AabTargetName = "$CleanAppName-v$VersionName-build$VersionCode.aab"

$FinalApkPath = "$OutputDir\$ApkTargetName"
$FinalAabPath = "$OutputDir\$AabTargetName"

# 7. Build APK
Write-Host 'Building Production APK...' -ForegroundColor Cyan
flutter build apk --release --build-name=$VersionName --build-number=$VersionCode --dart-define=API_BASE_URL=$ApiBaseUrl

$BuiltApk = "$FlutterDir\build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $BuiltApk) {
    Copy-Item $BuiltApk $FinalApkPath -Force
    Write-Host "Production APK built: $FinalApkPath" -ForegroundColor Green
}

# 8. Build AAB (CH Play)
Write-Host 'Building Production AAB (App Bundle for CH Play)...' -ForegroundColor Cyan
flutter build appbundle --release --build-name=$VersionName --build-number=$VersionCode --dart-define=API_BASE_URL=$ApiBaseUrl

$BuiltAab = "$FlutterDir\build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $BuiltAab) {
    Copy-Item $BuiltAab $FinalAabPath -Force
    Write-Host "Production AAB built: $FinalAabPath" -ForegroundColor Green
}

Write-Host '========================================================' -ForegroundColor Green
Write-Host 'PRODUCTION BUILD COMPLETED SUCCESSFULLY!' -ForegroundColor Green
Write-Host '========================================================' -ForegroundColor Green

if (Test-Path $FinalApkPath) {
    $ApkInfo = Get-Item $FinalApkPath
    $ApkSize = [math]::Round($ApkInfo.Length / 1MB, 2)
    Write-Host "APK File: $FinalApkPath ($ApkSize MB)" -ForegroundColor Yellow
}

if (Test-Path $FinalAabPath) {
    $AabInfo = Get-Item $FinalAabPath
    $AabSize = [math]::Round($AabInfo.Length / 1MB, 2)
    Write-Host "AAB File (CH Play): $FinalAabPath ($AabSize MB)" -ForegroundColor Yellow
}
