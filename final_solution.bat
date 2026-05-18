@echo off
echo ========================================
echo FINAL SOLUTION FOR FLUTTER BUILD
echo ========================================

echo 1. Killing all processes...
taskkill /F /IM java.exe
taskkill /F /IM gradle.exe
timeout /t 2

echo 2. Cleaning everything...
flutter clean
cd android
gradlew clean --no-daemon
cd ..
timeout /t 2

echo 3. Getting dependencies...
flutter pub get
timeout /t 2

echo 4. Building with minimal settings...
flutter build apk --debug --no-shrink --no-tree-shake-icons

echo ========================================
echo BUILD COMPLETE!
echo Check build/app/outputs/flutter-apk/app-debug.apk
echo ========================================
pause
