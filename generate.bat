@echo off

call flutter pub get
if %errorlevel% neq 0 exit /b %errorlevel%

call dart run easy_localization:generate -S assets\translations
if %errorlevel% neq 0 exit /b %errorlevel%

call dart run easy_localization:generate -S assets\translations -f keys -o locale_keys.g.dart
if %errorlevel% neq 0 exit /b %errorlevel%

call dart run flutter_launcher_icons
if %errorlevel% neq 0 exit /b %errorlevel%

cd packages\local_storage_repository\
if %errorlevel% neq 0 exit /b %errorlevel%

call dart run build_runner build
if %errorlevel% neq 0 exit /b %errorlevel%

cd ..
if %errorlevel% neq 0 exit /b %errorlevel%

cd totp_api
if %errorlevel% neq 0 exit /b %errorlevel%

call dart run build_runner build
if %errorlevel% neq 0 exit /b %errorlevel%

echo All commands have been executed successfully.
