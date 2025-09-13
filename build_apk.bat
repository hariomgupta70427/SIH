@echo off
echo Building Railway Parts Management APK...
echo.

REM Check Flutter installation
flutter doctor --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo Cleaning previous builds...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Building APK...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✓ APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Opening build folder...
    explorer build\app\outputs\flutter-apk\
) else (
    echo.
    echo ✗ Build failed. Check the errors above.
)

pause