// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get readme => '文件结构说明';

  @override
  String get homePage => '首页';

  @override
  String get hpInvalidQRCodeErrMsg => '二维码无效';

  @override
  String get hpSearchHintTxt => '搜索TOTP条目';

  @override
  String get hpPopMenuScanAdd => '扫码添加';

  @override
  String get hpPopMenuManAdd => '手动添加';

  @override
  String get hpEmptyListTips => '点击下面的“+”添加新条目';

  @override
  String get hpNoMatchItemsTips => '没有匹配的条目';

  @override
  String get totpMenu => '组件totp菜单';

  @override
  String get tmCopy => '复制';

  @override
  String get tmEdit => '编辑';

  @override
  String get tmDelete => '删除';

  @override
  String get tmCopiedTips => '已复制到剪贴板';

  @override
  String get tmDeleteDialogTitle => '删除条目';

  @override
  String get tmDeleteDialogContent => '确定要删除选中的条目吗？';

  @override
  String get tmDeleteDialogCancelBtn => '取消';

  @override
  String get tmDeleteDialogConfirmBtn => '确定';

  @override
  String get webdavPage => 'WebDAV 配置页';

  @override
  String get wpOperationSuccess => '操作成功';

  @override
  String get wpAppbarTitle => 'WebDAV 配置';

  @override
  String get wpFormUrlLabel => '地址';

  @override
  String get wpFormUsernameLabel => '用户名';

  @override
  String get wpFormPasswordLabel => '密码';

  @override
  String get wpFormEncryptLabel => '加密密钥';

  @override
  String get wpSyncOperationCardTitle => '同步操作';

  @override
  String get wpForceSyncBtnText => '强制同步';

  @override
  String get wpExitSyncBtnText => '退出同步';

  @override
  String get wpLastSyncError => '上次同步错误：';

  @override
  String get addeditTotpPage => '添加/编辑TOTP条目页';

  @override
  String get atpOperationFailedErrMsg => '操作失败';

  @override
  String get atpAddAppbarTitle => '添加TOTP条目';

  @override
  String get atpEditAppbarTitle => '编辑TOTP条目';

  @override
  String get atpDupDialogTitle => '已存在同名条目';

  @override
  String get atpDupDialogContent => '已存在同名条目，是否覆盖？';

  @override
  String get atpDupDialogCancelBtn => '取消';

  @override
  String get atpDupDialogConfirmBtn => '确定';

  @override
  String get atpFormOtpTypeLabel => 'OTP类型';

  @override
  String get atpFormOtpIssuerLabel => 'Issuer';

  @override
  String get atpFormOtpAccountLabel => '账号';

  @override
  String get atpFormOtpSecretLabel => '密钥';

  @override
  String get atpFormOtpPeriodLabel => '周期';

  @override
  String get atpFormOtpDigitsLabel => '位数';

  @override
  String get atpFormOtpAlgorithmLabel => '算法';

  @override
  String get atpFormOtpRemarkLabel => '备注';

  @override
  String get atpFormOtpIconLabel => '图标';

  @override
  String get settingsPage => '设置页';

  @override
  String get spAppbarTitle => '设置';

  @override
  String get spAppearanceLabel => '外观';

  @override
  String get spAboutLabel => '关于';

  @override
  String get spFeedbackLabel => '反馈与交流';

  @override
  String get spImportExportLabel => '导入/导出';

  @override
  String get spLanguageLabel => '语言';

  @override
  String get spRecycleBinLabel => '回收站';

  @override
  String get spSyncLabel => '同步';

  @override
  String get settingsThemePage => '主题设置页';

  @override
  String get stpAppbarTitle => '主题设置';

  @override
  String get stpThemeModeLabel => '主题模式';

  @override
  String get stpThemeModeLight => '浅色';

  @override
  String get stpThemeModeDark => '深色';

  @override
  String get stpThemeModeSystem => '跟随系统';

  @override
  String get stpThemeColorLabel => '主题颜色';

  @override
  String get stpThemeRandomLabel => '随机颜色';

  @override
  String get stpThemeRandomDesc => '每次启动应用时，随机选择一个主题颜色';

  @override
  String get settingsLanguagePage => '语言设置';

  @override
  String get slpAppBarTitle => '语言设置';

  @override
  String get slpCurrentLanguage => '当前语言:';

  @override
  String get importExportPage => '导入/导出页';

  @override
  String get iepAppbarTitle => '导入/导出';

  @override
  String get iepImportTitle => '导入';

  @override
  String get iepExportTitle => '导出';

  @override
  String get iepExportSuccessDialogTitle => '导出成功';

  @override
  String get iepExportSuccessDialogPath => '导出路径';

  @override
  String get iepExportPathCopiedTips => '导出路径已复制';

  @override
  String get iepExportSuccessDialogCopyPathBtn => '复制路径';

  @override
  String get iepExportSuccessDialogConfirmBtn => '确认';

  @override
  String get iepExportFailedTips => '导出失败';

  @override
  String get iepImportSuccessTips => '导入成功';

  @override
  String get iepImportFailedTips => '导入失败';

  @override
  String get recycleBinPage => '回收站';

  @override
  String get rbpAppbarTitle => '回收站';

  @override
  String get rbpClearAllDialogTitle => '清空所有已删除项';

  @override
  String get rbpClearAllDialogContent => '确定要清空所有已删除项吗，清空后将无法恢复';

  @override
  String get rbpClearAllDialogCancelBtn => '取消';

  @override
  String get rbpClearAllDialogConfirmBtn => '确定';

  @override
  String get rbpEmptyItemsTips => '没有已删除的项';

  @override
  String get rbpRestoreBtn => '恢复';

  @override
  String get rbpDelPermanentlyBtn => '彻底删除';

  @override
  String get feedbackPage => '反馈';

  @override
  String get fpAppbarTitle => '反馈交流';

  @override
  String get webdavUnsupportedAuthMethod => '不支持的 WebDAV 认证方式';

  @override
  String get webdavAuthFailed => 'WebDAV 认证失败，请检查您的用户名和密码';

  @override
  String get webdavResourceNotFound => 'WebDAV 资源未找到，请检查您的 URL';

  @override
  String get webdavRequestFailed => 'WebDAV 客户端请求失败，请根据返回的http状态码进行排查';

  @override
  String get webdavConnectErr => '连接异常，请检查您的网络或URL是否正确';

  @override
  String get webdavNotDir => '设置的webdav路径不是目录，请设置到目录一级，程序会自动管理其中的文件';

  @override
  String get webdavCreateFileFailed => '创建WebDAV文件失败，请检查权限或路径是否正确';

  @override
  String get webdavUnknownErr => '未知错误，请检查权限或路径是否正确';
}
