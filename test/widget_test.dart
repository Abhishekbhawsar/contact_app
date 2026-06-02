import 'package:contact_app/data/models/contact_model.dart';
import 'package:contact_app/data/repositories/contact_repository.dart';
import 'package:contact_app/main.dart';
import 'package:contact_app/providers/internet_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContactRepository implements ContactRepository {
  final List<ContactModel> _contacts = [
    ContactModel(
      id: '1',
      name: 'Aarav Shah',
      phoneNumber: '+911234567890',
      email: 'aarav@example.com',
      company: 'Blue Labs',
      isFavorite: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  @override
  Stream<List<ContactModel>> watchContacts() => Stream.value(_contacts);

  @override
  Future<void> addContact(ContactModel contact) async => _contacts.add(contact);

  @override
  Future<void> updateContact(ContactModel contact) async {
    final index = _contacts.indexWhere((item) => item.id == contact.id);
    if (index != -1) _contacts[index] = contact;
  }

  @override
  Future<void> deleteContact(String id) async => _contacts.removeWhere((contact) => contact.id == id);

  @override
  Future<void> toggleFavorite(ContactModel contact) async {
    await updateContact(contact.copyWith(isFavorite: !contact.isFavorite));
  }
}

class FakeInternetProvider extends InternetProvider {
  @override
  Future<void> startMonitoring() async {}
}

void main() {
  testWidgets('renders contacts home screen', (tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeContactRepository(),
        internetProvider: FakeInternetProvider(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contacts'), findsWidgets);
    expect(find.text('Aarav Shah'), findsOneWidget);
    expect(find.text('+911234567890'), findsOneWidget);
  });
}
