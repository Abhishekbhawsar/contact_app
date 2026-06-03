import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/contact_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';
import '../profile/contact_profile_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.allContacts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null && provider.allContacts.isEmpty) {
          return EmptyState(
            icon: Icons.cloud_off_outlined,
            title: AppStrings.unableToLoadContacts,
            message: provider.errorMessage!,
          );
        }

        return ResponsivePage(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: provider.contacts.isEmpty
                ? EmptyState(
                    key: ValueKey(provider.searchQuery),
                    icon: provider.searchQuery.isEmpty ? Icons.person_add_alt_1_outlined : Icons.search_off_rounded,
                    title: provider.searchQuery.isEmpty
                        ? AppStrings.noContactsYet
                        : AppStrings.noMatchingContacts,
                    message: provider.searchQuery.isEmpty
                        ? AppStrings.addContactEmptyMessage
                        : AppStrings.searchEmptyMessage,
                  )
                : _ContactList(contacts: provider.contacts),
          ),
        );
      },
    );
  }
}

class _ContactList extends StatelessWidget {
  const _ContactList({required this.contacts});

  final List<ContactModel> contacts;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ContactProvider>();
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final delayIndex = index > 8 ? 8 : index;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 180 + (delayIndex * 35)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ContactListTile(
            contact: contact,
            heroTag: 'contacts-${contact.id}',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContactProfileScreen(
                  contactId: contact.id,
                  heroTag: 'contacts-${contact.id}',
                ),
              ),
            ),
            onToggleFavorite: () async {
              await provider.toggleFavorite(contact);
            },
          ),
        );
      },
    );
  }
}
