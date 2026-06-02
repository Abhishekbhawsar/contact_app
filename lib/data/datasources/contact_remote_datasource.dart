import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/contact_model.dart';

class ContactRemoteDataSource {
  ContactRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _contacts =>
      _firestore.collection(AppConstants.contactsCollection);

  Stream<List<ContactModel>> watchContacts() {
    return _contacts.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map(ContactModel.fromFirestore).toList(),
        );
  }

  Future<void> addContact(ContactModel contact) {
    final document = contact.id.isEmpty ? _contacts.doc() : _contacts.doc(contact.id);
    return document.set(contact.copyWith(id: document.id).toFirestore());
  }

  Future<void> updateContact(ContactModel contact) {
    return _contacts.doc(contact.id).update(
          contact.copyWith(updatedAt: DateTime.now()).toFirestore(),
        );
  }

  Future<void> deleteContact(String id) => _contacts.doc(id).delete();

  Future<void> toggleFavorite(ContactModel contact) {
    return _contacts.doc(contact.id).update({
      'isFavorite': !contact.isFavorite,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
