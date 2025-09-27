# f2fa

A two-step authentication `App` developed using `flutter`, with a clean and concise interface.Currently, only the Android platform is supported.


[中文](README.md)

## Features
- Support `TOTP`, `HOTP`
- Compatible with `Google Authenticator`，`Microsoft Authenticator`
- Support `WebDAV` for multi-device synchronization
- Support end-to-end encryption


## Build Guide
Before building, make sure you have the `flutter` development environment installed locally
1. First, clone the project locally

Github
```
git clone https://github.com/jenken827/f2fa.git
cd f2fa
```
Gitee
```
git clone https://gitee.com/jenken827/f2fa.git
cd f2fa
```
2. Run script to resolve dependencies
- `windows` enviroment
```
./generate.bat
```
- `linux` enviroment
```
bash ./generate.sh
```
3. Run in development mode
```
flutter run
```

## Open Source Agreement
MIT License. [LICENSE](./LICENSE).