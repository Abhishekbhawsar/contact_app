import '../datasources/contact_remote_datasource.dart';
import '../models/contact_model.dart';

abstract class ContactRepository {
  Stream<List<ContactModel>> watchContacts();
  Future<void> addContact(ContactModel contact);
  Future<void> updateContact(ContactModel contact);
  Future<void> deleteContact(String id);
  Future<void> toggleFavorite(ContactModel contact);
}

class FirestoreContactRepository implements ContactRepository {
  FirestoreContactRepository(this._remoteDataSource);

  final ContactRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ContactModel>> watchContacts() => _remoteDataSource.watchContacts();

  @override
  Future<void> addContact(ContactModel contact) => _remoteDataSource.addContact(contact);

  @override
  Future<void> updateContact(ContactModel contact) => _remoteDataSource.updateContact(contact);

  @override
  Future<void> deleteContact(String id) => _remoteDataSource.deleteContact(id);

  @override
  Future<void> toggleFavorite(ContactModel contact) => _remoteDataSource.toggleFavorite(contact);
}
