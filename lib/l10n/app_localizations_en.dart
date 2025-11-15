// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get readme => 'File structure description';

  @override
  String get homePage => 'Home Page';

  @override
  String get hpInvalidQRCodeErrMsg => 'Invalid QR code';

  @override
  String get hpSearchHintTxt => 'Search TOTP entries';

  @override
  String get hpPopMenuScanAdd => 'Scan to add';

  @override
  String get hpPopMenuManAdd => 'Manual add';

  @override
  String get hpEmptyListTips => 'Click the \'+\' below to add a new entry';

  @override
  String get hpNoMatchItemsTips => 'No matching entries';

  @override
  String get totpMenu => 'TOTP Menu Component';

  @override
  String get tmCopy => 'Copy';

  @override
  String get tmEdit => 'Edit';

  @override
  String get tmDelete => 'Delete';

  @override
  String get tmCopiedTips => 'Copied to clipboard';

  @override
  String get tmDeleteDialogTitle => 'Delete entry';

  @override
  String get tmDeleteDialogContent =>
      'Are you sure you want to delete the selected entry?';

  @override
  String get tmDeleteDialogCancelBtn => 'Cancel';

  @override
  String get tmDeleteDialogConfirmBtn => 'Confirm';

  @override
  String get webdavPage => 'WebDAV Configuration Page';

  @override
  String get wpOperationSuccess => 'Operation successful';

  @override
  String get wpAppbarTitle => 'WebDAV Configuration';

  @override
  String get wpFormUrlLabel => 'URL';

  @override
  String get wpFormUsernameLabel => 'Username';

  @override
  String get wpFormPasswordLabel => 'Password';

  @override
  String get wpFormEncryptLabel => 'Encryption key';

  @override
  String get wpSyncOperationCardTitle => 'Sync Operations';

  @override
  String get wpForceSyncBtnText => 'Force Sync';

  @override
  String get wpExitSyncBtnText => 'Exit Sync';

  @override
  String get wpLastSyncError => 'Last sync error:';

  @override
  String get addeditTotpPage => 'Add/Edit TOTP Entry Page';

  @override
  String get atpOperationFailedErrMsg => 'Operation failed';

  @override
  String get atpAddAppbarTitle => 'Add TOTP Entry';

  @override
  String get atpEditAppbarTitle => 'Edit TOTP Entry';

  @override
  String get atpDupDialogTitle => 'Entry with same name exists';

  @override
  String get atpDupDialogContent =>
      'An entry with the same name already exists. Overwrite?';

  @override
  String get atpDupDialogCancelBtn => 'Cancel';

  @override
  String get atpDupDialogConfirmBtn => 'Confirm';

  @override
  String get atpFormOtpTypeLabel => 'OTP Type';

  @override
  String get atpFormOtpIssuerLabel => 'Issuer';

  @override
  String get atpFormOtpAccountLabel => 'Account';

  @override
  String get atpFormOtpSecretLabel => 'Secret';

  @override
  String get atpFormOtpPeriodLabel => 'Period';

  @override
  String get atpFormOtpDigitsLabel => 'Digits';

  @override
  String get atpFormOtpAlgorithmLabel => 'Algorithm';

  @override
  String get atpFormOtpRemarkLabel => 'Remark';

  @override
  String get atpFormOtpIconLabel => 'Icon';

  @override
  String get settingsPage => 'Settings Page';

  @override
  String get spAppbarTitle => 'Settings';

  @override
  String get spAppearanceLabel => 'Appearance';

  @override
  String get spAboutLabel => 'About';

  @override
  String get spFeedbackLabel => 'Feedback & Communication';

  @override
  String get spImportExportLabel => 'Import/Export';

  @override
  String get spLanguageLabel => 'Language';

  @override
  String get spRecycleBinLabel => 'Recycle Bin';

  @override
  String get spSyncLabel => 'Sync';

  @override
  String get settingsThemePage => 'Theme Settings Page';

  @override
  String get stpAppbarTitle => 'Theme Settings';

  @override
  String get stpThemeModeLabel => 'Theme Mode';

  @override
  String get stpThemeModeLight => 'Light';

  @override
  String get stpThemeModeDark => 'Dark';

  @override
  String get stpThemeModeSystem => 'Follow System';

  @override
  String get stpThemeColorLabel => 'Theme Color';

  @override
  String get stpThemeRandomLabel => 'Random Color';

  @override
  String get stpThemeRandomDesc =>
      'Randomly select a theme color each time the app starts';

  @override
  String get settingsLanguagePage => 'Language Settings';

  @override
  String get slpAppBarTitle => 'Language Settings';

  @override
  String get slpCurrentLanguage => 'Current Language:';

  @override
  String get importExportPage => 'Import/Export Page';

  @override
  String get iepAppbarTitle => 'Import/Export';

  @override
  String get iepImportTitle => 'Import';

  @override
  String get iepExportTitle => 'Export';

  @override
  String get iepExportSuccessDialogTitle => 'Export Successful';

  @override
  String get iepExportSuccessDialogPath => 'Export Path';

  @override
  String get iepExportPathCopiedTips => 'Export path copied';

  @override
  String get iepExportSuccessDialogCopyPathBtn => 'Copy Path';

  @override
  String get iepExportSuccessDialogConfirmBtn => 'Confirm';

  @override
  String get iepExportFailedTips => 'Export failed';

  @override
  String get iepImportSuccessTips => 'Import successful';

  @override
  String get iepImportFailedTips => 'Import failed';

  @override
  String get recycleBinPage => 'Recycle Bin';

  @override
  String get rbpAppbarTitle => 'Recycle Bin';

  @override
  String get rbpClearAllDialogTitle => 'Clear All Deleted Items';

  @override
  String get rbpClearAllDialogContent =>
      'Are you sure you want to clear all deleted items? This action cannot be undone.';

  @override
  String get rbpClearAllDialogCancelBtn => 'Cancel';

  @override
  String get rbpClearAllDialogConfirmBtn => 'Confirm';

  @override
  String get rbpEmptyItemsTips => 'No deleted items';

  @override
  String get rbpRestoreBtn => 'Restore';

  @override
  String get rbpDelPermanentlyBtn => 'Delete Permanently';

  @override
  String get feedbackPage => 'Feedback';

  @override
  String get fpAppbarTitle => 'Feedback & Communication';

  @override
  String get webdavUnsupportedAuthMethod =>
      'Unsupported WebDAV authentication method';

  @override
  String get webdavAuthFailed =>
      'WebDAV authentication failed, please check your username and password';

  @override
  String get webdavResourceNotFound =>
      'WebDAV resource not found, please check your URL';

  @override
  String get webdavRequestFailed =>
      'WebDAV client request failed, please check the returned HTTP status code';

  @override
  String get webdavConnectErr =>
      'Connection error, please check your network or URL';

  @override
  String get webdavNotDir =>
      'The WebDAV path is not a directory, please set it to the directory level, the program will automatically manage files within it';

  @override
  String get webdavCreateFileFailed =>
      'Failed to create WebDAV file, please check permissions or path';

  @override
  String get webdavUnknownErr =>
      'Unknown error, please check permissions or path';
}
