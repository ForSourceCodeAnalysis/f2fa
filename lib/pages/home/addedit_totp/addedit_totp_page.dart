import 'package:f2fa/blocs/blocs.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:f2fa/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EditTotpPage extends StatelessWidget {
  const EditTotpPage({super.key, this.initialTotp});

  final Totp? initialTotp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditTotpBloc(
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
    final status = context.select((EditTotpBloc bloc) => bloc.state.status);
    final isNewTotp = context.read<EditTotpBloc>().state.isNewTotp;
    final al = AppLocalizations.of(context)!;

    final initial = widget.initialTotp;
    final initialValues = <String, dynamic>{
      'type': initial?.type ?? 'totp',
      'issuer': initial?.issuer ?? '',
      'account': initial?.account ?? '',
      'secret': initial?.secret ?? '',
      'period': initial?.period ?? 30,
      'digits': initial?.digits ?? 6,
      'algorithm': initial?.algorithm ?? 'sha1',
      'remark': initial?.remark ?? '',
      'icon': initial?.icon ?? '',
    };

    return BlocListener<EditTotpBloc, EditTotpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditTotpStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == EditTotpStatus.failure) {
          showSnackBar(
            context: context,
            message: '${al.atpOperationFailedErrMsg} ${state.err.toString()}',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isNewTotp ? al.atpAddAppbarTitle : al.atpEditAppbarTitle),
        ),
        floatingActionButton: FloatingActionButton(
          // tooltip: al.save,
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
              remark: v['remark'],
              icon: v['icon'],
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
                    title: Text(al.atpDupDialogTitle),
                    content: Text(al.atpDupDialogContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(al.atpDupDialogCancelBtn),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(al.atpDupDialogConfirmBtn),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<EditTotpBloc>().add(EditTotpSubmitted(totp));
                  return;
                }
              } else {
                context.read<EditTotpBloc>().add(EditTotpSubmitted(totp));
              }
            } else {
              context.read<EditTotpBloc>().add(EditTotpSubmitted(totp));
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
                              labelText: al.atpFormOtpTypeLabel,
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
                              labelText: al.atpFormOtpIssuerLabel,
                            ),
                            validator: FormBuilderValidators.required(),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderTextField(
                            name: 'account',
                            initialValue: initialValues['account'],
                            decoration: InputDecoration(
                              labelText: al.atpFormOtpAccountLabel,
                            ),
                            validator: FormBuilderValidators.required(),
                          ),

                          const SizedBox(height: 16),

                          FormBuilderTextField(
                            name: 'secret',
                            initialValue: initialValues['secret'],
                            obscureText: _isObscured,
                            decoration: InputDecoration(
                              labelText: al.atpFormOtpSecretLabel,
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
                              labelText: al.atpFormOtpPeriodLabel,
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          FormBuilderDropdown<int>(
                            name: 'digits',
                            initialValue: initialValues['digits'],
                            decoration: InputDecoration(
                              labelText: al.atpFormOtpDigitsLabel,
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
                              labelText: al.atpFormOtpAlgorithmLabel,
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
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'remark',
                            initialValue: initialValues['remark'],
                            decoration: InputDecoration(
                              labelText: al.atpFormOtpRemarkLabel,
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return FormBuilderValidators.maxLength(500)(
                                  value,
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'icon',
                            initialValue: initialValues['icon'],
                            decoration: InputDecoration(
                              labelText: al.atpFormOtpIconLabel,
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return FormBuilderValidators.url()(value);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 48),
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
