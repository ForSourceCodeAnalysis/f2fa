# f2fa

A two-step authentication `App` developed using `flutter`, with a clean and concise interface, supporting multiple platforms, `Android`, `Linux`, `Windows`, `ios` (not verified), `macos` (not verified).

[中文](README.md)

## Features
- Multi-platform support
- Support `TOTP`, `HOTP`
- Compatible with `Google Authenticator`，`Microsoft Authenticator`
- Support `WebDAV` for multi-device synchronization

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
## Possible problems and solutions

When compiling in `Windows` Chinese environment, you may encounter the following problems
> D:\\...\f2fa\windows\flutter\ephemeral\.plugin_symlinks\flutter_zxing\src\zxing\core\src\BitMatrixIO.cpp(1,1): warning C4819: The file contains a file that cannot be used in the current code page The character represented in (936). Please save the file in Unicode format to prevent data loss [D:\\...\f2fa\build\windows\x64\plugins\flutter_zxing\shared\zxing\core\ZXing.vcxproj]
>
>D:\\...\f2fa\windows\flutter\ephemeral\.plugin_symlinks\flutter_zxing\src\zxing\core\src\BitMatrixIO.cpp(36,49): error C3688: The text suffix "鈻" is invalid; not Found literal operator or literal operator template "operator """"鈻" [D:\\...\f2fa\build\windows\x64\plugins\flutter_zxing\shared\zxing\core\ZXing.vcxproj]

Solution reference: [C3688: 文本后缀“X265_LL”无效；未找到文文本运算符或文本运算符模板“operator """"X265_LL”](https://blog.csdn.net/strikedragon/article/details/84954663#:~:text=%E5%8F%8C%E5%87%BB%E6%AD%A4%E9%94%99%E8%AF%AF%E4%BC%9A%E8%B7%B3%E5%88%B0%E5%87%BA%E9%94%99%E7%9A%84%E6%96%87%E4%BB%B6%EF%BC%8C%E8%BF%99%E6%97%B6%E5%9C%A8%20Visual%20Studio%E8%8F%9C%E5%8D%95%E6%A0%8F%E4%B8%8A%E7%82%B9%E5%87%BB%E2%80%9C%E6%96%87%E4%BB%B6%E2%80%9D-%3E%E2%80%9C%E9%AB%98%E7%BA%A7%E4%BF%9D%E5%AD%98%E9%80%89%E9%A1%B9%E2%80%9D%EF%BC%8C%E5%9C%A8%E2%80%9C%E7%BC%96%E7%A0%81%E2%80%9D%E4%B8%8B%E6%8B%89%E6%A1%86%E9%80%89%E6%8B%A9%E2%80%9C%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%EF%BC%88GB2312%EF%BC%89%E2%80%9D%EF%BC%8C%E7%84%B6%E5%90%8E%E2%80%9C%E7%A1%AE%E5%AE%9A%E2%80%9D%E5%8D%B3%E5%8F%AF%E3%80%82%20%E9%87%8D%E6%96%B0%E7%BC%96%E8%AF%91%E5%B0%B1%E6%B2%A1%E9%97%AE%E9%A2%98%E5%95%A6%EF%BC%81%20%E5%A6%82%E6%9E%9C%E8%BF%98%E6%B2%A1%E8%A7%A3%E5%86%B3%EF%BC%8C%E5%8F%AF%E8%83%BD%E6%98%AF%E5%9B%A0%E4%B8%BA%E6%A0%BC%E5%BC%8F%E9%97%AE%E9%A2%98%EF%BC%9A,%E6%AF%94%E5%A6%82%20X265_LL%E5%89%8D%E9%9D%A2%E5%A2%9E%E5%8A%A0%E7%A9%BA%E6%A0%BC%EF%BC%8C%E5%8D%B3%E5%8F%AF%E8%A7%A3%E5%86%B3%E3%80%82%20%E6%96%87%E7%AB%A0%E6%B5%8F%E8%A7%88%E9%98%85%E8%AF%BB6.6k%E6%AC%A1%EF%BC%8C%E7%82%B9%E8%B5%9E7%E6%AC%A1%EF%BC%8C%E6%94%B6%E8%97%8F4%E6%AC%A1%E3%80%82%20%E8%BF%99%E7%A7%8D%E9%94%99%E8%AF%AF%E4%B8%80%E8%88%AC%E6%98%AF%E5%9C%A8%E5%AF%B9%E4%B8%8B%E8%BD%BD%E5%BE%97%E5%88%B0%E7%9A%84%E4%BB%A3%E7%A0%81%E8%BF%9B%E8%A1%8C%E7%BC%96%E8%AF%91%E6%97%B6%E5%87%BA%E7%8E%B0%EF%BC%8C%E5%AE%9E%E9%99%85%E6%98%AF%E6%96%87%E4%BB%B6%E7%BC%96%E7%A0%81%E9%97%AE%E9%A2%98%E3%80%82%20%E8%BF%99%E6%97%B6%E4%B8%8B%E8%BD%BD%E5%BE%97%E5%88%B0%E7%9A%84%E6%96%87%E4%BB%B6%E7%BC%96%E7%A0%81%E4%B8%BAUTF-8%EF%BC%8C%E8%80%8CWindows%E4%B8%AD%E6%96%87%E7%89%88%E9%BB%98%E8%AE%A4%E4%BD%BF%E7%94%A8GB2312%EF%BC%8C%E5%AF%B9%E4%BA%8EUTF-8%E7%BC%96%E7%A0%81%E7%9A%84%E6%9F%90%E4%BA%9B%E5%AD%97%E7%AC%A6%EF%BC%8C%E5%9C%A8%E4%B8%AD%E6%96%87%E7%89%88VS%E4%B8%8B%E5%B0%B1%E5%AE%B9%E6%98%93%E5%9B%A0%E8%A7%A3%E7%A0%81%E9%94%99%E8%AF%AF%E5%AF%BC%E8%87%B4%E4%B9%B1%E7%A0%81%E9%80%A0%E6%88%90%E7%BC%96%E8%AF%91%E9%94%99%E8%AF%AF%E3%80%82)

## Open Source Agreement
MIT License. [LICENSE](./LICENSE).