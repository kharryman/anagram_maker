@echo off
echo Building Flutter app apk...
CALL flutter build apk

if %errorlevel% neq 0 (
    echo Error: Failed to build apk.
    exit /b %errorlevel%
)

echo Installing app bundle on device...
CALL adb install -r build\app\outputs\apk\release\app-release.apk

echo Installation complete.
