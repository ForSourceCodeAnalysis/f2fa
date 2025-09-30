import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EditTotpPage extends StatelessWidget {
  const EditTotpPage({super.key, this.initialTotp});

  final Totp? initialTotp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditTodoBloc(
        totpRepository: context.read<TotpRepository>(),
        initialTotp: initialTotp,
      ),
      child: EditTotpView(initialTotp: initialTotp),
    );
  }
}

class EditTotpView extends StatefulWidget {
  const EditTotpView({super.key, this.initialTotp});

  final Totp? initialTotp;

  @override
  State<EditTotpView> createState() => _EditTotpViewState();
}

class _EditTotpViewState extends State<EditTotpView> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    final isNewTotp = context.read<EditTodoBloc>().state.isNewTotp;

    final initial = widget.initialTotp;
    final initialValues = <String, dynamic>{
      'type': initial?.type ?? 'totp',
      'issuer': initial?.issuer ?? '',
      'account': initial?.account ?? '',
      'secret': initial?.secret ?? '',
      'period': initial?.period ?? 30,
      'digits': initial?.digits ?? 6,
      'algorithm': initial?.algorithm ?? 'sha1',
    };

    return BlocListener<EditTodoBloc, EditTotpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditTotpStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == EditTotpStatus.failure) {
          SnackBarWrapper.showSnackBar(
            context: context,
            message: LocaleKeys.hpAddFail.tr(),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNewTotp
                ? LocaleKeys.etpAddItem.tr()
                : LocaleKeys.etpEditItem.tr(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: LocaleKeys.cSave.tr(),
          onPressed: () async {
            final formState = _formKey.currentState;
            if (formState == null) return;
            formState.save();
            if (!formState.validate()) return;
            final v = formState.value;

            final rawPeriod = v['period'];
            final period = rawPeriod is int
                ? rawPeriod
                : int.tryParse((rawPeriod ?? '').toString()) ?? 30;

            final rawDigits = v['digits'];
            final digits = rawDigits is int
                ? rawDigits
                : int.tryParse((rawDigits ?? '').toString()) ?? 6;
            final totp = Totp(
              type: v['type'],
              issuer: v['issuer'],
              account: v['account'],
              secret: v['secret'],
              period: period,
              digits: digits,
              algorithm: v['algorithm'],
              createdAt:
                  initial?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
              updatedAt:
                  initial?.updatedAt ?? DateTime.now().millisecondsSinceEpoch,
              deleteStatus: 0,
            );
            if (totp.id != initial?.id) {
              final eindex = context.read<TotpRepository>().existIndex(
                totp.id,
                oldId: initial?.id,
              );
              if (eindex != -1) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(LocaleKeys.etpDupTipsTitle.tr()),
                    content: Text(LocaleKeys.etpDupTipsContent.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(LocaleKeys.cCancel.tr()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(LocaleKeys.cConfirm.tr()),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<EditTodoBloc>().add(EditTotpSubmitted(totp));
                  return;
                }
              } else {
                context.read<EditTodoBloc>().add(EditTotpSubmitted(totp));
              }
            } else {
              context.read<EditTodoBloc>().add(EditTotpSubmitted(totp));
            }
          },

          child: status == EditTotpStatus.loading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Icon(Icons.check_rounded),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FormBuilder(
                      key: _formKey,
                      // initialValue: initialValues,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormBuilderDropdown<String>(
                            name: 'type',
                            initialValue: initialValues['type'],
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpType.tr(),
                            ),
                            items: ['totp', 'hotp']
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.toUpperCase()),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderTextField(
                            name: 'issuer',
                            initialValue: initialValues['issuer'],
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpIssuer.tr(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderTextField(
                            name: 'account',
                            initialValue: initialValues['account'],
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpAccount.tr(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderTextField(
                            name: 'secret',
                            initialValue: initialValues['secret'],
                            obscureText: _isObscured,
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpSecret.tr(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _isObscured = !_isObscured),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderTextField(
                            name: 'period',
                            initialValue: initialValues['period'].toString(),
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpPeriod.tr(),
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          FormBuilderDropdown<int>(
                            name: 'digits',
                            initialValue: initialValues['digits'],
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpDigits.tr(),
                            ),
                            items: [6, 7, 8]
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d.toString()),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderDropdown<String>(
                            name: 'algorithm',
                            initialValue: initialValues['algorithm'],
                            decoration: InputDecoration(
                              labelText: LocaleKeys.etpAlgorithm.tr(),
                            ),
                            items: ['sha1', 'sha256', 'sha512']
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a.toUpperCase()),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Legacy per-field widgets removed: FormBuilder is used for local input state.
