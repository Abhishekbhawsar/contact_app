import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/contact_model.dart';
import '../data/repositories/contact_repository.dart';

class ContactProvider extends ChangeNotifier {
  ContactProvider(this._repository);

  final ContactRepository _repository;
  StreamSubscription<List<ContactModel>>? _subscription;
  List<ContactModel> _contacts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ContactModel> get contacts => _filter(_contacts);
  List<ContactModel> get favorites => _filter(_contacts.where((contact) => contact.isFavorite).toList());
  List<ContactModel> get allContacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void fetchContacts() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchContacts().timeout(const Duration(seconds: 20)).listen(
      (contacts) {
        _contacts = contacts;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addContact(ContactModel contact) => _run(() => _repository.addContact(contact));

  Future<void> updateContact(ContactModel contact) => _run(() => _repository.updateContact(contact));

  Future<void> deleteContact(String id) => _run(() => _repository.deleteContact(id));

  Future<void> toggleFavorite(ContactModel contact) => _run(() => _repository.toggleFavorite(contact));

  void searchContacts(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  ContactModel? contactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } on StateError {
      return null;
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Firestore request timed out. Check Firebase setup and internet connection.');
        },
      );
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ContactModel> _filter(List<ContactModel> source) {
    if (_searchQuery.isEmpty) return List.unmodifiable(source);
    return source.where((contact) {
      final haystack = [
        contact.name,
        contact.phoneNumber,
        contact.email,
        contact.company,
      ].join(' ').toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList(growable: false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
