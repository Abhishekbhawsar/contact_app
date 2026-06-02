import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contact_provider.dart';
import '../../providers/internet_provider.dart';
import '../../widgets/offline_banner.dart';
import '../add_edit_contact/add_edit_contact_screen.dart';
import '../contacts/contacts_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ContactProvider>();
    final isOffline = context.select<InternetProvider, bool>((value) => value.isOffline);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            tooltip: 'Refresh contacts',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: isOffline
                ? () => _showOfflineMessage(context)
                : provider.fetchContacts,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Semantics(
              label: 'Search contacts',
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search contacts',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        provider.searchContacts('');
                        setState(() {});
                      },
                    ),
                ],
                onChanged: (value) {
                  provider.searchContacts(value);
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isOffline) const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [ContactsScreen(), FavoritesScreen()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add contact',
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add'),
        onPressed: isOffline
            ? () => _showOfflineMessage(context)
            : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
                ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.star_outline_rounded), selectedIcon: Icon(Icons.star_rounded), label: 'Favorites'),
        ],
      ),
    );
  }

  void _showOfflineMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your internet is off. Please connect to the internet and try again.'),
      ),
    );
  }
}
