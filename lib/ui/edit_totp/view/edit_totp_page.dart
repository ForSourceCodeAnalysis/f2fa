import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totp_repository/totp_repository.dart';
import 'package:easy_localization/easy_localization.dart';

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
      child: const EditTotpView(),
    );
  }
}

class EditTotpView extends StatelessWidget {
  const EditTotpView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    final isNewTotp = context.select(
      (EditTodoBloc bloc) => bloc.state.isNewTotp,
    );

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
          shape: const CircleBorder(),
          onPressed: status.isLoadingOrSuccess
              ? null
              : () =>
                    context.read<EditTodoBloc>().add(const EditTotpSubmitted()),
          child: status.isLoadingOrSuccess
              ? const CircularProgressIndicator()
              : const Icon(Icons.check_rounded),
        ),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _TypeField(),
                SizedBox(height: 16),
                _IssuerField(),
                SizedBox(height: 16),
                _AccountField(),
                SizedBox(height: 16),
                _SecretField(),
                SizedBox(height: 16),
                _PeriodField(),
                SizedBox(height: 16),
                _DigitsField(),
                SizedBox(height: 16),
                _AlgorithmField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return DropdownButtonFormField<String>(
      key: const Key('editTotpView_type_dropdownField'),
      initialValue: state.type,
      decoration: InputDecoration(labelText: LocaleKeys.etpType.tr()),
      items: ['totp', 'hotp'].map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        context.read<EditTodoBloc>().add(EditTotpTypeChanged(value));
      },
    );
  }
}

class _IssuerField extends StatelessWidget {
  const _IssuerField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return TextFormField(
      key: const Key('editTotpView_issuer_textFormField'),
      initialValue: state.issuer,
      decoration: InputDecoration(labelText: LocaleKeys.etpIssuer.tr()),
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTotpIssuerChanged(value));
      },
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return TextFormField(
      key: const Key('editTotpView_account_textFormField'),
      initialValue: state.account,
      decoration: InputDecoration(labelText: LocaleKeys.etpAccount.tr()),
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTotpAccountChanged(value));
      },
    );
  }
}

class _SecretField extends StatefulWidget {
  const _SecretField();

  @override
  State<_SecretField> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<_SecretField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return TextFormField(
      key: const Key('editTotpView_secret_textFormField'),
      initialValue: state.secret,
      decoration: InputDecoration(
        labelText: LocaleKeys.etpSecret.tr(),
        suffixIcon: IconButton(
          // 添加一个按钮来切换密码显示
          icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured; // 切换状态
            });
          },
        ),
      ),
      obscureText: _isObscured,
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTotpSecretChanged(value));
      },
    );
  }
}

class _PeriodField extends StatelessWidget {
  const _PeriodField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return TextFormField(
      key: const Key('editTotpView_period_textFormField'),
      initialValue: state.period.toString(),
      decoration: InputDecoration(labelText: LocaleKeys.etpPeriod.tr()),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final period = int.tryParse(value);
        if (period != null) {
          context.read<EditTodoBloc>().add(EditTotpPeriodChanged(period));
        }
      },
    );
  }
}

class _DigitsField extends StatelessWidget {
  const _DigitsField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return DropdownButtonFormField<int>(
      key: const Key('editTotpView_digits_dropdownField'),
      initialValue: state.digits,
      decoration: InputDecoration(labelText: LocaleKeys.etpDigits.tr()),
      items: [6, 7, 8].map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<EditTodoBloc>().add(EditTotpDigitsChanged(value));
        }
      },
    );
  }
}

class _AlgorithmField extends StatelessWidget {
  const _AlgorithmField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return DropdownButtonFormField<String>(
      key: const Key('editTotpView_algorithm_dropdownField'),
      initialValue: state.algorithm,
      decoration: InputDecoration(labelText: LocaleKeys.etpAlgorithm.tr()),
      items: ['sha1', 'sha256', 'sha512'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<EditTodoBloc>().add(EditTotpAlgorithmChanged(value));
        }
      },
    );
  }
}
