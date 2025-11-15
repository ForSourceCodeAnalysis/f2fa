import 'dart:convert';
import 'dart:io';

import 'package:f2fa/pages/pages.dart';
import 'package:f2fa/services/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(al.iepAppbarTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 功能介绍区域
                  _buildInfoSection(context, theme),
                  const SizedBox(height: 32),

                  // 导入功能区域
                  _buildImportSection(context, theme),
                  const SizedBox(height: 24),

                  // 导出功能区域
                  _buildExportSection(context, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: .2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '功能介绍',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '通过导入导出功能，您可以备份和恢复您的TOTP数据。支持JSON格式的文件操作。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection(BuildContext context, ThemeData theme) {
    final al = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () async {
          setState(() {
            _isLoading = true;
          });
          await _importFromFile(context);
          setState(() {
            _isLoading = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.file_download,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  al.iepImportTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportSection(BuildContext context, ThemeData theme) {
    final al = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () async {
          setState(() {
            _isLoading = true;
          });
          await _exportPlainToDir(context);
          setState(() {
            _isLoading = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.file_upload,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  al.iepExportTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportPlainToDir(BuildContext context) async {
    final al = AppLocalizations.of(context)!;

    try {
      final suggested =
          'totps_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';

      Directory? docs = await getDownloadsDirectory();
      if (docs == null) {
        final sdir = await getApplicationSupportDirectory();
        docs = Directory('${sdir.path}/downloads');
        await docs.create(recursive: true);
      }
      final filePath = '${docs.path}/$suggested';

      if (!context.mounted) {
        return;
      }
      final totpRepo = context.read<TotpRepository>();
      final all = await totpRepo.getAllTotps();
      final jsonStr = jsonEncode(all.map((e) => e.toJson()).toList());

      final file = File(filePath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(jsonStr, flush: true);

      if (!mounted) return;
      final dirToOpen = docs.path;
      await Clipboard.setData(ClipboardData(text: dirToOpen));

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return AlertDialog(
            title: Text(al.iepExportSuccessDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(al.iepExportSuccessDialogPath),
                const SizedBox(height: 6),
                SelectableText(filePath),
                const SizedBox(height: 8),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    await Clipboard.setData(ClipboardData(text: dirToOpen));
                    if (!dialogCtx.mounted) return;
                    Navigator.of(dialogCtx).pop();
                    if (!mounted) return;
                    showSnackBar(
                      context: context,
                      message: al.iepExportPathCopiedTips,
                    );
                  } catch (_) {}
                },
                child: Text(al.iepExportSuccessDialogCopyPathBtn),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(al.iepExportSuccessDialogConfirmBtn),
              ),
            ],
          );
        },
      );
      return;
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(
        context: context,
        message: '${al.iepExportFailedTips}: $e',
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _importFromFile(BuildContext context) async {
    final al = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // 用户取消选择
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null || filePath.isEmpty || !context.mounted) {
        return;
      }
      await context.read<TotpRepository>().importTotpsFromFile(filePath);

      if (!context.mounted) return;

      showSnackBar(context: context, message: al.iepImportSuccessTips);
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(
        context: context,
        message: '${al.iepImportFailedTips}: $e',
        duration: const Duration(seconds: 5),
      );
    }
  }
}
