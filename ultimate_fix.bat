@echo off
echo ========================================
echo ULTIMATE FIX FOR FLUTTER BUILD
echo ========================================

echo 1. Killing ALL processes...
taskkill /F /IM java.exe
taskkill /F /IM gradle.exe
taskkill /F /IM flutter.exe
timeout /t 3

echo 2. Deleting ALL caches...
if exist "%USERPROFILE%\.gradle" rmdir /s /q "%USERPROFILE%\.gradle"
if exist "%USERPROFILE%\.flutter-cache" rmdir /s /q "%USERPROFILE%\.flutter-cache"
if exist "%APPDATA%\Pub\Cache" rmdir /s /q "%APPDATA%\Pub\Cache"
timeout /t 2

echo 3. Clean Flutter...
flutter clean
timeout /t 2

echo 4. Clean Gradle...
cd android
gradlew clean --no-daemon --refresh-keys
cd ..
timeout /t 2

echo 5. Get dependencies...
flutter pub get
timeout /t 2

echo 6. Build APK...
flutter build apk --debug --no-shrink --no-tree-shake-icons

echo ========================================
echo BUILD COMPLETE!
echo APK Location: build/app/outputs/flutter-apk/app-debug.apk
echo ========================================
pause
