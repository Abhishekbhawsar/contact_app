import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/services/call_service.dart';
import '../data/models/contact_model.dart';
import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
    this.callService = const CallService(),
    this.heroTag,
  });

  final ContactModel contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final CallService callService;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.openContactLabel(contact.name),
      child: Card(
        child: ListTile(
          onTap: onTap,
          minVerticalPadding: 14,
          leading: ContactAvatar(contact: contact, hero: true, heroTag: heroTag),
          title: Text(
            contact.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            contact.phoneNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: contact.isFavorite
                    ? AppStrings.removeFromFavorites
                    : AppStrings.addToFavorites,
                icon: Icon(contact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                color: contact.isFavorite ? Colors.amber.shade700 : null,
                onPressed: onToggleFavorite,
              ),
              IconButton(
                tooltip: AppStrings.callContactLabel(contact.name),
                icon: const Icon(Icons.call_outlined),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final launched = await callService.call(contact.phoneNumber);
                  if (!launched) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text(AppStrings.couldNotStartCall)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
