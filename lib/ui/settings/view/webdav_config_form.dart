import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:webdav_totp_api/webdav_totp_api.dart';

class WebDavConfigForm extends StatelessWidget {
  const WebDavConfigForm({this.initialWebdav, super.key});

  final WebdavConfig? initialWebdav;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditWebdavBloc(
        totpRepository: context.read<TotpRepository>(),
        localStorage: context.read<LocalStorageRepository>(),
        initialWebdav: initialWebdav,
      ),
      child: _FormView(),
    );
  }
}

class _FormView extends StatelessWidget {
  _FormView();

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final initialWebdav = context.read<EditWebdavBloc>().state.initialWebdav;
    final status = context.select((EditWebdavBloc bloc) => bloc.state.status);
    final webdavErr = context
        .read<LocalStorageRepository>()
        .box
        .get(LocalStorageRepository.webdavErrKey);

    return BlocListener<EditWebdavBloc, EditWebdavState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditWebdavStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == EditWebdavStatus.failure) {
          if (state.error == WebDAVErrorType.overwriteError) {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text(LocaleKeys.wcpOverwriteConfirm.tr()),
                  content: Text(LocaleKeys.wcpOverwriteConfirmTips.tr()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(LocaleKeys.cCancel.tr()),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<EditWebdavBloc>().add(EditWebdavSubmit(
                              url: state.url,
                              username: state.username,
                              password: state.password,
                              encryptKey: state.encryptKey,
                              overwrite: true,
                            ));
                        Navigator.of(context).pop();
                      },
                      child: Text(LocaleKeys.cConfirm.tr()),
                    ),
                  ],
                );
              },
            );
          } else {
            SnackBarWrapper.showSnackBar(
              context: context,
              message: context.tr('wcp${state.error?.name}Tips'),
            );
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.wcpWebdavConfig.tr()),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        name: 'url',
                        valueTransformer: (value) => value?.trim(),
                        initialValue: initialWebdav?.url,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.wcpUrl.tr(),
                          hintText: initialWebdav?.url == null
                              ? 'https://webdav.example.com/dav/f2fa.bin'
                              : null,
                          hintStyle: const TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
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
                        initialValue: initialWebdav?.username,
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
                        initialValue: initialWebdav?.password,
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
                        initialValue: initialWebdav?.encryptKey,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return tr('webdavConfigPagePasswordEmptyTips');
                        //   }
                        //   return null;
                        // },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (webdavErr != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${LocaleKeys.wcpLastSyncError.tr()}: ',
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        context.tr('wcp${webdavErr}Tips'),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final value = _formKey.currentState!.value;
                if (value['url'] == initialWebdav?.url &&
                    value['username'] == initialWebdav?.username &&
                    value['password'] == initialWebdav?.password &&
                    value['encryptkey'] == initialWebdav?.encryptKey) {
                  Navigator.of(context).pop();
                } else {
                  context.read<EditWebdavBloc>().add(EditWebdavSubmit(
                        url: value['url'],
                        username: value['username'],
                        password: value['password'],
                        encryptKey: value['encryptkey'],
                      ));
                }
              }
            },
            child: status.isLoadingOrSuccess
                ? const CupertinoActivityIndicator()
                : const Icon(Icons.check_rounded),
          )),
    );
  }
}
