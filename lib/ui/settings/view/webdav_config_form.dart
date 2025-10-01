import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:totp_repository/totp_repository.dart';

class WebDavConfigForm extends StatelessWidget {
  final WebdavConfig? initialWebdav;

  const WebDavConfigForm({super.key, this.initialWebdav});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditWebdavBloc(
        localStorage: context.read<LocalStorageRepository>(),
        totprepository: context.read<TotpRepository>(),
      )..add(const EditWebdavStatusSubscribe()),
      child: _FormView(initialWebdav: initialWebdav),
    );
  }
}

class _FormView extends StatefulWidget {
  final WebdavConfig? initialWebdav;

  const _FormView({this.initialWebdav});

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditWebdavBloc, EditWebdavState>(
      listener: (context, state) {
        if (state.status == EditWebdavStatus.success) {
          SnackBarWrapper.showSnackBar(
            context: context,
            message: LocaleKeys.cOperationSuccess.tr(),
            duration: const Duration(seconds: 2),
          );
        }
        if (state.status == EditWebdavStatus.failure) {
          SnackBarWrapper.showSnackBar(
            context: context,
            message: state.error,
            duration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
        final syncErrorInfo = state.webdavStatus.errorInfo;

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.wcpWebdavConfig.tr())),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.spWebdav.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FormBuilderTextField(
                                name: 'url',
                                valueTransformer: (value) => value?.trim(),
                                initialValue: widget.initialWebdav?.url,
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.wcpUrl.tr(),
                                  hintText: widget.initialWebdav?.url == null
                                      ? 'https://webdav.example.com/dav/f2fa.bin'
                                      : null,
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocaleKeys.wcpEmptyURLTips.tr();
                                  }
                                  final uri = Uri.tryParse(value);
                                  if (!(uri != null &&
                                      uri.hasScheme &&
                                      uri.isAbsolute)) {
                                    return LocaleKeys.wcpInvalidURLTips.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'username',
                                valueTransformer: (value) => value?.trim(),
                                initialValue: widget.initialWebdav?.username,
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.cUsername.tr(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocaleKeys.wcpEmptyUsernameTips.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              PasswordField(
                                name: 'password',
                                label: LocaleKeys.cPassword.tr(),
                                initialValue: widget.initialWebdav?.password,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocaleKeys.wcpEmptyPasswordTips.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              PasswordField(
                                name: 'encryptkey',
                                label: LocaleKeys.wcpEncryptKey.tr(),
                                initialValue: widget.initialWebdav?.encryptKey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 同步操作卡片
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.wcpSyncOperation.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 16),

                        // 操作按钮
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    state.status == EditWebdavStatus.loading ||
                                        state.webdavStatus.configured == false
                                    ? null
                                    : () {
                                        context.read<EditWebdavBloc>().add(
                                          EditWebdavForceSync(),
                                        );
                                      },

                                icon: const Icon(Icons.sync),
                                label: Text(LocaleKeys.wcpForceSync.tr()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    state.status == EditWebdavStatus.loading ||
                                        state.webdavStatus.configured == false
                                    ? null
                                    : () {
                                        context.read<EditWebdavBloc>().add(
                                          EditWebdavExitSync(),
                                        );
                                      },
                                icon: const Icon(Icons.cancel),
                                label: Text(LocaleKeys.wcpExitSync.tr()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 错误信息显示
                if (syncErrorInfo.isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${LocaleKeys.wcpLastSyncError.tr()}:',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            syncErrorInfo,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.start,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              // Dismiss soft keyboard before validating/submitting
              FocusScope.of(context).unfocus();
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final value = _formKey.currentState!.value;
                if (value['url'] == widget.initialWebdav?.url &&
                    value['username'] == widget.initialWebdav?.username &&
                    value['password'] == widget.initialWebdav?.password &&
                    value['encryptkey'] == widget.initialWebdav?.encryptKey) {
                  Navigator.of(context).pop();
                } else {
                  context.read<EditWebdavBloc>().add(
                    EditWebdavSubmit(
                      url: value['url'],
                      username: value['username'],
                      password: value['password'],
                      encryptKey: value['encryptkey'],
                    ),
                  );
                }
              }
            },
            child: state.status == EditWebdavStatus.loading
                ? const CupertinoActivityIndicator()
                : const Icon(Icons.check_rounded),
          ),
        );
      },
    );
  }
}
