import 'package:f2fa/blocs/blocs.dart';
import 'package:f2fa/l10n/l10n.dart';
import 'package:f2fa/models/models.dart';
import 'package:f2fa/pages/pages.dart';
import 'package:f2fa/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class TotpMenuButton extends StatelessWidget {
  const TotpMenuButton({required this.totp, super.key});

  final Totp totp;

  Future<void> _showMenuAt(
    BuildContext parentContext,
    Offset globalPosition,
  ) async {
    final al = AppLocalizations.of(parentContext)!;
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
              Text(al.tmCopy),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(width: 8),
              Text(al.tmEdit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete),
              const SizedBox(width: 8),
              Text(al.tmDelete),
            ],
          ),
        ),
      ],
    );

    switch (selected) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: totp.code));
        if (parentContext.mounted) {
          showSnackBar(context: parentContext, message: al.tmCopiedTips);
        }
        break;
      case 'edit':
        if (parentContext.mounted) {
          parentContext.push(const AddEditTotpRoute().location, extra: totp);
        }
        break;
      case 'delete':
        if (parentContext.mounted) {
          showDialog(
            context: parentContext,
            builder: (dialogContext) => AlertDialog(
              title: Text(al.tmDeleteDialogTitle),
              content: Text(al.tmDeleteDialogContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(al.tmDeleteDialogCancelBtn),
                ),
                TextButton(
                  onPressed: () {
                    // use the parentContext (where the bloc is available)
                    parentContext.read<TotpsOverviewBloc>().add(
                      TotpsOverviewTotpDeleted(totp),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: Text(al.tmDeleteDialogConfirmBtn),
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
        child: Icon(Icons.more_horiz),
      ),
    );
  }
}
