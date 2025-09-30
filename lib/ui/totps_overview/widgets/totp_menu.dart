import 'package:f2fa/generated/generated.dart';
import 'package:f2fa/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:easy_localization/easy_localization.dart';

/// Reusable overflow menu button for a Totp item.
/// Shows an overlay menu anchored at the tap position and performs
/// copy / edit / delete actions.
class TotpMenuButton extends StatelessWidget {
  const TotpMenuButton({required this.totp, super.key});

  final Totp totp;

  Future<void> _showMenuAt(
    BuildContext parentContext,
    Offset globalPosition,
  ) async {
    final overlay =
        Overlay.of(parentContext).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: parentContext,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy),
              const SizedBox(width: 8),
              Text(LocaleKeys.tltCopyCode.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(width: 8),
              Text(LocaleKeys.cEdit.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete),
              const SizedBox(width: 8),
              Text(LocaleKeys.cDelete.tr()),
            ],
          ),
        ),
      ],
    );

    switch (selected) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: totp.code));
        if (parentContext.mounted) {
          SnackBarWrapper.showSnackBar(
            context: parentContext,
            message: LocaleKeys.tltCodeCopied.tr(),
          );
        }
        break;
      case 'edit':
        if (parentContext.mounted) {
          Navigator.of(parentContext).push(
            MaterialPageRoute(builder: (c) => EditTotpPage(initialTotp: totp)),
          );
        }
        break;
      case 'delete':
        if (parentContext.mounted) {
          showDialog(
            context: parentContext,
            builder: (dialogContext) => AlertDialog(
              title: Text(LocaleKeys.tltDeleteItem.tr()),
              content: Text(LocaleKeys.tltDeleteConfirmAsk.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(LocaleKeys.cCancel.tr()),
                ),
                TextButton(
                  onPressed: () {
                    // use the parentContext (where the bloc is available)
                    parentContext.read<TotpsOverviewBloc>().add(
                      TotpsOverviewTotpDeleted(totp),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: Text(LocaleKeys.cConfirm.tr()),
                ),
              ],
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap an IconButton with GestureDetector so we can capture the
    // global tap-down position and open the overlay menu anchored there.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _showMenuAt(context, details.globalPosition),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Icon(Icons.more_vert),
      ),
    );
  }
}
