@echo off
echo Fixing Flutter Gradle Build Issues...

echo 1. Killing all Java processes...
taskkill /F /IM java.exe

echo 2. Cleaning Gradle caches...
if exist "%USERPROFILE%\.gradle\caches" rmdir /s /q "%USERPROFILE%\.gradle\caches"

echo 3. Cleaning Flutter build...
flutter clean

echo 4. Getting dependencies...
flutter pub get

echo 5. Building APK...
flutter build apk --debug

echo Done! Check the build output above for any errors.
pause
