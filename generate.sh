#!/usr/bin/bash

set -e

flutter pub get


dart run flutter_launcher_icons
dart run flutter_native_splash:create
dart run build_runner build