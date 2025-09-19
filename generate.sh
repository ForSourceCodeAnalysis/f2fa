#!/usr/bin/bash

set -e

flutter pub get

dart run easy_localization:generate -S assets/translations
dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart

dart run flutter_launcher_icons
dart run flutter_native_splash:create


cd packages/local_storage_repository/
dart run build_runner build
cd ../totp_api
dart run build_runner build
