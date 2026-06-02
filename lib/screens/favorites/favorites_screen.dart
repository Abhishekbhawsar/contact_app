import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contact_provider.dart';
import '../../widgets/contact_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_page.dart';
import '../profile/contact_profile_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) {
        final favorites = provider.favorites;
        return ResponsivePage(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: favorites.isEmpty
                ? const EmptyState(
                    icon: Icons.star_outline_rounded,
                    title: 'No favorites yet',
                    message: 'Star important people to keep them close at hand.',
                  )
                : ListView.separated(
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final contact = favorites[index];
                      return ContactListTile(
                        contact: contact,
                        heroTag: 'favorites-${contact.id}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ContactProfileScreen(
                              contactId: contact.id,
                              heroTag: 'favorites-${contact.id}',
                            ),
                          ),
                        ),
                        onToggleFavorite: () => provider.toggleFavorite(contact),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
