import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/widgets/action_sheet_menu.dart';
import 'package:list_in/features/profile/presentation/widgets/info_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductActionsService {
  // Show publication options
  static void showPublicationOptions(
      BuildContext context, GetPublicationEntity product) {
    final localizations = AppLocalizations.of(context)!;
    final options = [
      ActionSheetOption(
        title: localizations.boost_publication,
        icon: CupertinoIcons.rocket,
        iconColor: AppColors.primary,
        onPressed: () => showBoostUnavailableMessage(context),
      ),
      ActionSheetOption(
        title: localizations.delete_publication,
        icon: CupertinoIcons.delete,
        iconColor: AppColors.error,
        onPressed: () => showDeleteConfirmation(context, product.id),
        isDestructive: true,
      ),
    ];

    ActionSheetMenu.show(
      context: context,
      title: localizations.publication_options,
      message: localizations.choose_action,
      options: options,
    );
  }

  // Show delete confirmation dialog
  static Future<void> showDeleteConfirmation(
      BuildContext context, String productId) async {
    final localizations = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: Text(localizations.delete_publication),
              content: Text(
                localizations.delete_confirmation,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text(localizations.delete),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      context.read<UserPublicationsBloc>().add(
            DeleteUserPublication(publicationId: productId),
          );
      context.pop();
    }
  }

  // Show boost unavailable message
  static void showBoostUnavailableMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    InfoDialog.show(
      context: context,
      title: localizations.boost_unavailable,
      message: localizations.boost_unavailable_description,
    );
  }

  // Make a phone call
  static Future<void> makeCall(BuildContext context, String phoneNumber) async {
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final String uriString = 'tel:$cleanPhoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(uriString))) {
        await launchUrl(Uri.parse(uriString));
      } else {
        debugPrint("🤙Cannot launch URL: $uriString");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Error: Unable to launch call to $cleanPhoneNumber")),
        );
      }
    } catch (e) {
      debugPrint("🤙Cannot launch URL: $uriString");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }
}
