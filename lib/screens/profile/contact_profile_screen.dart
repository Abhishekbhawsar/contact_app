import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/services/call_service.dart';
import '../../data/models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/contact_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';
import '../add_edit_contact/add_edit_contact_screen.dart';

class ContactProfileScreen extends StatelessWidget {
  const ContactProfileScreen({
    super.key,
    required this.contactId,
    this.callService = const CallService(),
    this.heroTag,
  });

  final String contactId;
  final CallService callService;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) {
        final contact = provider.contactById(contactId);
        if (contact == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: AppStrings.contactNotFound,
              message: AppStrings.contactNotFoundMessage,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.contactDetails),
            actions: [
              IconButton(
                tooltip: contact.isFavorite
                    ? AppStrings.removeFromFavorites
                    : AppStrings.addToFavorites,
                icon: Icon(contact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                color: contact.isFavorite ? Colors.amber.shade700 : null,
                onPressed: () => provider.toggleFavorite(contact),
              ),
              IconButton(
                tooltip: AppStrings.editContact,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ResponsivePage(
              child: ListView(
                children: [
                  _ProfileHeader(contact: contact, heroTag: heroTag),
                  const SizedBox(height: 24),
                  _ActionRow(
                    onCall: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final launched = await callService.call(contact.phoneNumber);
                      if (!launched) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text(AppStrings.couldNotStartCall)),
                        );
                      }
                    },
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
                    ),
                    onDelete: () => _confirmDelete(context, provider, contact),
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(icon: Icons.call_outlined, title: AppStrings.phone, value: contact.phoneNumber),
                  _InfoCard(icon: Icons.mail_outline_rounded, title: AppStrings.email, value: contact.email),
                  _InfoCard(icon: Icons.business_outlined, title: AppStrings.company, value: contact.company),
                  _InfoCard(icon: Icons.place_outlined, title: AppStrings.address, value: contact.address),
                  _InfoCard(icon: Icons.notes_outlined, title: AppStrings.notes, value: contact.notes),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, ContactProvider provider, ContactModel contact) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text(AppStrings.deleteContactQuestion),
        content: Text(AppStrings.deleteContactMessage(contact.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text(AppStrings.cancel)),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    try {
      await provider.deleteContact(contact.id);
      messenger.showSnackBar(const SnackBar(content: Text(AppStrings.contactDeleted)));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text(AppStrings.couldNotDeleteContact)));
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.contact, this.heroTag});

  final ContactModel contact;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContactAvatar(contact: contact, size: 120, hero: true, heroTag: heroTag),
        const SizedBox(height: 18),
        Text(
          contact.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          contact.phoneNumber,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onCall,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onCall;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final children = [
          FilledButton.icon(onPressed: onCall, icon: const Icon(Icons.call_rounded), label: const Text(AppStrings.call)),
          OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), label: const Text(AppStrings.edit)),
          TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded), label: const Text(AppStrings.delete)),
        ];

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children.expand((child) => [child, const SizedBox(height: 8)]).take(children.length * 2 - 1).toList(),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children.expand((child) => [child, const SizedBox(width: 10)]).take(children.length * 2 - 1).toList(),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value),
        ),
      ),
    );
  }
}
