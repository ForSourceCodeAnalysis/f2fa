import 'package:f2fa/blocs/blocs.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';

class WebdavPage extends StatelessWidget {
  const WebdavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WebdavBloc(totprepository: context.read<TotpRepository>())
            ..add(const WebdavStatusSubscribe()),
      child: const _FormView(),
    );
  }
}

class _FormView extends StatefulWidget {
  const _FormView();

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPwdVisible = false;
  bool _isEncryptKeyVisible = false;
  final _webdavConfig = GetIt.I.get<LocalStorage>().getWebdavConfig();

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return BlocConsumer<WebdavBloc, WebdavState>(
      listener: (context, state) {
        if (state.status == WebdavStatus.success) {
          showSnackBar(
            context: context,
            message: al.wpOperationSuccess,
            duration: const Duration(seconds: 2),
          );
        }
        if (state.status == WebdavStatus.failure) {
          showSnackBar(
            context: context,
            message: state.error,
            duration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
        final webdavErr = state.webdavErr;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: Text(al.wpAppbarTitle)),
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
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FormBuilderTextField(
                                name: 'url',
                                valueTransformer: (value) => value?.trim(),
                                initialValue: _webdavConfig?.url,
                                decoration: InputDecoration(
                                  labelText: '* ${al.wpFormUrlLabel}',
                                  prefixIcon: Icon(
                                    Icons.link,
                                    color: colorScheme.primary,
                                  ),
                                  hintText: _webdavConfig?.url == null
                                      ? 'https://webdav.example.com/dav/f2fa/'
                                      : null,
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.url(),
                                ]),
                              ),
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'username',
                                valueTransformer: (value) => value?.trim(),
                                initialValue: _webdavConfig?.username,
                                decoration: InputDecoration(
                                  labelText: '* ${al.wpFormUsernameLabel}',
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                validator: FormBuilderValidators.required(),
                              ),
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'password',
                                valueTransformer: (value) => value?.trim(),
                                initialValue: _webdavConfig?.password,
                                decoration: InputDecoration(
                                  labelText: '* ${al.wpFormPasswordLabel}',
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: colorScheme.primary,
                                  ),
                                  suffixIcon: _webdavConfig == null
                                      ? IconButton(
                                          icon: Icon(
                                            _isPwdVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPwdVisible = !_isPwdVisible;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                obscureText: _webdavConfig == null
                                    ? !_isPwdVisible
                                    : true,
                              ),

                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'encryptKey',
                                valueTransformer: (value) => value?.trim(),
                                initialValue: _webdavConfig?.encryptKey,
                                decoration: InputDecoration(
                                  labelText: '* ${al.wpFormEncryptLabel}',
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: colorScheme.primary,
                                  ),
                                  suffixIcon:
                                      //  widget.initialWebdav == null?
                                      IconButton(
                                        icon: Icon(
                                          _isEncryptKeyVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isEncryptKeyVisible =
                                                !_isEncryptKeyVisible;
                                          });
                                        },
                                      ),
                                  // : null,
                                ),
                                obscureText: !_isEncryptKeyVisible,
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
                          al.wpSyncOperationCardTitle,
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
                                    state.status == WebdavStatus.loading ||
                                        _webdavConfig == null
                                    ? null
                                    : () {
                                        context.read<WebdavBloc>().add(
                                          WebdavForceSync(),
                                        );
                                      },

                                icon: Icon(
                                  Icons.sync,
                                  color: colorScheme.primary,
                                ),
                                label: Text(al.wpForceSyncBtnText),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    state.status == WebdavStatus.loading ||
                                        _webdavConfig == null
                                    ? null
                                    : () {
                                        context.read<WebdavBloc>().add(
                                          WebdavExitSync(),
                                        );
                                      },
                                icon: Icon(
                                  Icons.cancel,
                                  color: colorScheme.primary,
                                ),
                                label: Text(al.wpExitSyncBtnText),
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
                if (webdavErr != null)
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
                                '${al.wpLastSyncError}:',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            webdavErr.toString(),
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
                if (value['url'] == _webdavConfig?.url &&
                    value['username'] == _webdavConfig?.username &&
                    value['password'] == _webdavConfig?.password &&
                    value['encryptKey'] == _webdavConfig?.encryptKey) {
                  Navigator.of(context).pop();
                } else {
                  context.read<WebdavBloc>().add(
                    WebdavSubmit(
                      url: value['url'],
                      username: value['username'],
                      password: value['password'],
                      encryptKey: value['encryptKey'],
                    ),
                  );
                }
              }
            },
            child: state.status == WebdavStatus.loading
                ? const CupertinoActivityIndicator()
                : const Icon(Icons.check_rounded),
          ),
        );
      },
    );
  }
}
