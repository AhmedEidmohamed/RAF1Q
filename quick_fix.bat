@echo off
echo Quick Fix for Flutter Build Issues...

echo 1. Killing all processes...
taskkill /F /IM java.exe
taskkill /F /IM gradle.exe

echo 2. Cleaning everything...
flutter clean
cd android
gradlew clean --no-daemon --refresh-keys
cd ..

echo 3. Getting dependencies...
flutter pub get

echo 4. Building APK directly...
flutter build apk --debug --no-shrink --no-tree-shake-icons

echo Done!
pause
