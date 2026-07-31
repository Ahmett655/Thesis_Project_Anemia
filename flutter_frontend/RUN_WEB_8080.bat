@echo off
REM ============================================================
REM  Anemia Risk Assessment - Web launcher (Google Sign-In safe)
REM  ALWAYS runs on port 8080, the origin registered in Google
REM  Cloud Console. Double-click this instead of the Android
REM  Studio green Run button to avoid the "origin_mismatch" error.
REM ============================================================
cd /d "%~dp0"
echo Starting Anemia app on http://localhost:8080 ...
flutter run -d chrome --web-port=8080
pause
