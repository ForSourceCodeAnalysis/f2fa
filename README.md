# f2fa

一款使用 `flutter` 开发的两步身份验证 `App` ，界面干净简洁，目前只支持了android平台。

[English](README_en.md)

## 特性
- 支持 `TOTP`,`HOTP`
- 兼容 `Google Authenticator`，`Microsoft Authenticator`
- 支持 `WebDAV` 进行多设备同步
- 支持端到端加密

## 开发指引
在进行构建前，请确保本地安装了 `flutter` 开发环境
1. 首先，`clone` 项目到本地

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
2. 运行处理依赖脚本
- `windows` 环境
```
./generate.bat
```
- `linux` 环境
```
bash ./generate.sh
```
3. 开发模式运行
```
flutter run
```

## 开源协议
MIT License.  [LICENSE](./LICENSE).

