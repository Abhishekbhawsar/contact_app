import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              title: 'Contact not found',
              message: 'This contact may have been deleted.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact details'),
            actions: [
              IconButton(
                tooltip: contact.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                icon: Icon(contact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                color: contact.isFavorite ? Colors.amber.shade700 : null,
                onPressed: () => provider.toggleFavorite(contact),
              ),
              IconButton(
                tooltip: 'Edit contact',
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
                        messenger.showSnackBar(const SnackBar(content: Text('Could not start a call.')));
                      }
                    },
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
                    ),
                    onDelete: () => _confirmDelete(context, provider, contact),
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(icon: Icons.call_outlined, title: 'Phone', value: contact.phoneNumber),
                  _InfoCard(icon: Icons.mail_outline_rounded, title: 'Email', value: contact.email),
                  _InfoCard(icon: Icons.business_outlined, title: 'Company', value: contact.company),
                  _InfoCard(icon: Icons.place_outlined, title: 'Address', value: contact.address),
                  _InfoCard(icon: Icons.notes_outlined, title: 'Notes', value: contact.notes),
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
        title: const Text('Delete contact?'),
        content: Text('This will permanently delete ${contact.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    try {
      await provider.deleteContact(contact.id);
      messenger.showSnackBar(const SnackBar(content: Text('Contact deleted.')));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not delete contact.')));
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
          FilledButton.icon(onPressed: onCall, icon: const Icon(Icons.call_rounded), label: const Text('Call')),
          OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), label: const Text('Edit')),
          TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded), label: const Text('Delete')),
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
