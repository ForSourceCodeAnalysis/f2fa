import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 这是说明文字，实际上不会使用。翻译按文件组织，例如以 homepage 开头的在 home_page.dart 中使用
  ///
  /// In zh, this message translates to:
  /// **'文件结构说明'**
  String get readme;

  /// 这是分隔符，以下是在 home_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get homePage;

  /// 无效二维码错误信息
  ///
  /// In zh, this message translates to:
  /// **'二维码无效'**
  String get hpInvalidQRCodeErrMsg;

  /// 搜索框提示文字
  ///
  /// In zh, this message translates to:
  /// **'搜索 TOTP 条目'**
  String get hpSearchHintTxt;

  /// 扫描二维码添加条目
  ///
  /// In zh, this message translates to:
  /// **'扫码添加'**
  String get hpPopMenuScanAdd;

  /// 手动添加条目
  ///
  /// In zh, this message translates to:
  /// **'手动添加'**
  String get hpPopMenuManAdd;

  /// 空列表提示文字
  ///
  /// In zh, this message translates to:
  /// **'点击下方的\'+\'添加新条目'**
  String get hpEmptyListTips;

  /// 无匹配条目提示文字
  ///
  /// In zh, this message translates to:
  /// **'无匹配条目'**
  String get hpNoMatchItemsTips;

  /// 补全缺失的TOTP信息对话框标题
  ///
  /// In zh, this message translates to:
  /// **'补全信息'**
  String get hpScanCompleteInfoDialogTitle;

  /// 当扫描的二维码缺少账号或发行方信息时的对话框消息
  ///
  /// In zh, this message translates to:
  /// **'扫码解析出的账号或发行商缺失，是否手动补全'**
  String get hpScanCompleteInfoDialogContent;

  /// 取消按钮文字
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get hpScanCompleteInfoDialogCancelBtn;

  /// 确定按钮文字
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get hpScanCompleteInfoDialogConfirmBtn;

  /// 这是分隔符，以下是在 totp_menu.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'组件 totp 菜单'**
  String get totpMenu;

  /// 复制菜单
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get tmCopy;

  /// 编辑菜单
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get tmEdit;

  /// 删除菜单
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get tmDelete;

  /// 复制操作成功提示文字
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get tmCopiedTips;

  /// 删除条目确认对话框标题
  ///
  /// In zh, this message translates to:
  /// **'删除条目'**
  String get tmDeleteDialogTitle;

  /// 删除条目确认对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的条目吗？'**
  String get tmDeleteDialogContent;

  /// 删除条目确认对话框取消按钮文本
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get tmDeleteDialogCancelBtn;

  /// 删除条目确认对话框确认按钮文本
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get tmDeleteDialogConfirmBtn;

  /// 这是分隔符，以下是在 Webdav_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 配置页'**
  String get webdavPage;

  /// 操作成功提示文字
  ///
  /// In zh, this message translates to:
  /// **'操作成功'**
  String get wpOperationSuccess;

  /// WebDAV 配置页标题
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 配置'**
  String get wpAppbarTitle;

  /// WebDAV 地址输入框标签
  ///
  /// In zh, this message translates to:
  /// **'地址'**
  String get wpFormUrlLabel;

  /// WebDAV 用户名输入框标签
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get wpFormUsernameLabel;

  /// WebDAV 密码输入框标签
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get wpFormPasswordLabel;

  /// WebDAV 加密密钥输入框标签
  ///
  /// In zh, this message translates to:
  /// **'加密密钥'**
  String get wpFormEncryptLabel;

  /// WebDAV 同步操作卡片标题
  ///
  /// In zh, this message translates to:
  /// **'同步操作'**
  String get wpSyncOperationCardTitle;

  /// 强制同步按钮文字
  ///
  /// In zh, this message translates to:
  /// **'强制同步'**
  String get wpForceSyncBtnText;

  /// 退出同步按钮文字
  ///
  /// In zh, this message translates to:
  /// **'退出同步'**
  String get wpExitSyncBtnText;

  /// 上次同步错误提示
  ///
  /// In zh, this message translates to:
  /// **'上次同步错误：'**
  String get wpLastSyncError;

  /// 这是分隔符，以下是在 addedit_totp_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'添加/编辑 TOTP 条目页'**
  String get addeditTotpPage;

  /// 操作失败提示文字
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get atpOperationFailedErrMsg;

  /// 添加 TOTP 条目页标题
  ///
  /// In zh, this message translates to:
  /// **'添加 TOTP 条目'**
  String get atpAddAppbarTitle;

  /// 编辑 TOTP 条目页标题
  ///
  /// In zh, this message translates to:
  /// **'编辑 TOTP 条目'**
  String get atpEditAppbarTitle;

  /// 已存在同名条目确认对话框标题
  ///
  /// In zh, this message translates to:
  /// **'已存在同名条目'**
  String get atpDupDialogTitle;

  /// 已存在同名条目确认对话框内容
  ///
  /// In zh, this message translates to:
  /// **'已存在同名条目，是否覆盖？'**
  String get atpDupDialogContent;

  /// 已存在同名条目确认对话框取消按钮文字
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get atpDupDialogCancelBtn;

  /// 已存在同名条目确认对话框确认按钮文字
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get atpDupDialogConfirmBtn;

  /// OTP 类型选择框标签
  ///
  /// In zh, this message translates to:
  /// **'OTP 类型'**
  String get atpFormOtpTypeLabel;

  /// Issuer 输入框标签
  ///
  /// In zh, this message translates to:
  /// **'Issuer'**
  String get atpFormOtpIssuerLabel;

  /// 账号输入框标签
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get atpFormOtpAccountLabel;

  /// 密钥输入框标签
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get atpFormOtpSecretLabel;

  /// TOTP 周期输入框标签
  ///
  /// In zh, this message translates to:
  /// **'周期'**
  String get atpFormOtpPeriodLabel;

  /// TOTP 位数选择框标签
  ///
  /// In zh, this message translates to:
  /// **'位数'**
  String get atpFormOtpDigitsLabel;

  /// TOTP 算法选择框标签
  ///
  /// In zh, this message translates to:
  /// **'算法'**
  String get atpFormOtpAlgorithmLabel;

  /// TOTP 备注输入框标签
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get atpFormOtpRemarkLabel;

  /// TOTP 图标选择框标签
  ///
  /// In zh, this message translates to:
  /// **'图标'**
  String get atpFormOtpIconLabel;

  /// 这是分隔符，以下是在 settings_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'设置页'**
  String get settingsPage;

  /// 设置页标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get spAppbarTitle;

  /// 设置页外观选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get spAppearanceLabel;

  /// 设置页关于选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get spAboutLabel;

  /// 设置页反馈与交流选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'反馈与交流'**
  String get spFeedbackLabel;

  /// 设置页导入/导出选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'导入/导出'**
  String get spImportExportLabel;

  /// 设置页语言选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get spLanguageLabel;

  /// 设置页回收站选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'回收站'**
  String get spRecycleBinLabel;

  /// 设置页同步选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get spSyncLabel;

  /// 设置页日志选项卡标题
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get spLogLabel;

  /// 这是分隔符，以下是在 theme_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'主题设置页'**
  String get settingsThemePage;

  /// 主题设置页标题
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get stpAppbarTitle;

  /// 主题设置页主题模式选择框标签
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get stpThemeModeLabel;

  /// 主题设置页主题模式浅色选项文字
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get stpThemeModeLight;

  /// 主题设置页主题模式深色选项文字
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get stpThemeModeDark;

  /// 主题设置页主题模式跟随系统选项文字
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get stpThemeModeSystem;

  /// 主题设置页主题颜色选择框标签
  ///
  /// In zh, this message translates to:
  /// **'主题颜色'**
  String get stpThemeColorLabel;

  /// 主题设置页主题颜色随机选项文字
  ///
  /// In zh, this message translates to:
  /// **'随机颜色'**
  String get stpThemeRandomLabel;

  /// 主题设置页主题颜色随机选项描述
  ///
  /// In zh, this message translates to:
  /// **'每次启动应用时，随机选择一个主题颜色'**
  String get stpThemeRandomDesc;

  /// 这是分隔符，以下是在 language_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get settingsLanguagePage;

  /// 语言设置页标题
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get slpAppBarTitle;

  /// 语言设置页当前语言
  ///
  /// In zh, this message translates to:
  /// **'当前语言:'**
  String get slpCurrentLanguage;

  /// 这是分隔符，以下是在 import_export_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'导入/导出页'**
  String get importExportPage;

  /// 导入/导出设置页标题
  ///
  /// In zh, this message translates to:
  /// **'导入/导出'**
  String get iepAppbarTitle;

  /// 导入/导出设置页描述
  ///
  /// In zh, this message translates to:
  /// **'通过导入导出功能，您可以备份和恢复您的 TOTP 数据。支持 JSON 格式的文件操作。'**
  String get iepDesc;

  /// 导入/导出设置页导入标题
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get iepImportTitle;

  /// 导入/导出设置页导出标题
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get iepExportTitle;

  /// 导入/导出设置页导出成功弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'导出成功'**
  String get iepExportSuccessDialogTitle;

  /// 导入/导出设置页导出成功弹窗导出路径文字
  ///
  /// In zh, this message translates to:
  /// **'导出路径'**
  String get iepExportSuccessDialogPath;

  /// 导入/导出设置页导出成功弹窗导出路径已复制文字
  ///
  /// In zh, this message translates to:
  /// **'导出路径已复制'**
  String get iepExportPathCopiedTips;

  /// 导入/导出设置页导出成功弹窗复制路径按钮文字
  ///
  /// In zh, this message translates to:
  /// **'复制路径'**
  String get iepExportSuccessDialogCopyPathBtn;

  /// 导入/导出设置页导出成功弹窗确认按钮文字
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get iepExportSuccessDialogConfirmBtn;

  /// 导入/导出设置页导出失败弹窗文字
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get iepExportFailedTips;

  /// 导入/导出设置页导入成功弹窗文字
  ///
  /// In zh, this message translates to:
  /// **'导入成功'**
  String get iepImportSuccessTips;

  /// 导入/导出设置页导入失败弹窗文字
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get iepImportFailedTips;

  /// 这是分隔符，以下是在 recycle_bin_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'回收站'**
  String get recycleBinPage;

  /// 回收站页标题
  ///
  /// In zh, this message translates to:
  /// **'回收站'**
  String get rbpAppbarTitle;

  /// 回收站页清空所有已删除项弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'清空所有已删除项'**
  String get rbpClearAllDialogTitle;

  /// 回收站页清空所有已删除项弹窗确认文字
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有已删除项吗，清空后将无法恢复'**
  String get rbpClearAllDialogContent;

  /// 回收站页清空所有已删除项弹窗取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get rbpClearAllDialogCancelBtn;

  /// 回收站页清空所有已删除项弹窗确定按钮
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get rbpClearAllDialogConfirmBtn;

  /// 回收站页没有已删除的项提示
  ///
  /// In zh, this message translates to:
  /// **'没有已删除的项'**
  String get rbpEmptyItemsTips;

  /// 回收站页恢复按钮
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get rbpRestoreBtn;

  /// 回收站页彻底删除按钮
  ///
  /// In zh, this message translates to:
  /// **'彻底删除'**
  String get rbpDelPermanentlyBtn;

  /// 回收站页彻底删除确认标题
  ///
  /// In zh, this message translates to:
  /// **'彻底删除确认'**
  String get rbpDelDialogTitle;

  /// 回收站页彻底删除确认内容
  ///
  /// In zh, this message translates to:
  /// **'确定要彻底删除所选项吗？'**
  String get rbpDelDialogContent;

  /// 回收站页彻底删除确认按钮
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get rbpDelDialogConfirmBtn;

  /// 回收站页彻底删除取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get rbpDelDialogCancelBtn;

  /// 这是分隔符，以下是在 feedback_page.dart 中使用的翻译
  ///
  /// In zh, this message translates to:
  /// **'反馈'**
  String get feedbackPage;

  /// 标题
  ///
  /// In zh, this message translates to:
  /// **'反馈交流'**
  String get fpAppbarTitle;

  /// 描述文字
  ///
  /// In zh, this message translates to:
  /// **'如果您有什么问题或建议，可以通过下面的方式反馈给我们，我们会尽快回复您。'**
  String get fpDesc;

  /// 邮箱文字
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get fpEmail;

  /// QQ文字
  ///
  /// In zh, this message translates to:
  /// **'QQ'**
  String get fpQQ;

  /// feedback_page.dart 中的已复制到剪贴板提示
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get fpCopiedTips;

  /// 不支持的 WebDAV 认证方式，错误提示
  ///
  /// In zh, this message translates to:
  /// **'不支持的 WebDAV 认证方式'**
  String get webdavUnsupportedAuthMethod;

  /// WebDAV 认证失败，错误提示
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 认证失败，请检查您的用户名和密码'**
  String get webdavAuthFailed;

  /// WebDAV 资源未找到，错误提示
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 资源未找到，请检查您的 URL'**
  String get webdavResourceNotFound;

  /// WebDAV 客户端请求失败，错误提示
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 客户端请求失败，请根据返回的 http 状态码进行排查'**
  String get webdavRequestFailed;

  /// 连接异常，错误提示
  ///
  /// In zh, this message translates to:
  /// **'连接异常，请检查您的网络或 URL 是否正确'**
  String get webdavConnectErr;

  /// 设置的 webdav 路径不是目录，请设置到目录一级，错误提示
  ///
  /// In zh, this message translates to:
  /// **'设置的 webdav 路径不是目录，请设置到目录一级，程序会自动管理其中的文件'**
  String get webdavNotDir;

  /// 创建 WebDAV 文件失败，请检查权限或路径是否正确，错误提示
  ///
  /// In zh, this message translates to:
  /// **'创建 WebDAV 文件失败，请检查权限或路径是否正确'**
  String get webdavCreateFileFailed;

  /// 未知错误，请检查权限或路径是否正确，错误提示
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get webdavUnknownErr;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
