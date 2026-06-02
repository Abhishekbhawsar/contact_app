import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  const ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email = '',
    this.company = '',
    this.address = '',
    this.notes = '',
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String company;
  final String address;
  final String notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return _firstLetter(parts.first);
    return '${_firstLetter(parts.first)}${_firstLetter(parts.last)}'.toUpperCase();
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? company,
    String? address,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      company: company ?? this.company,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ContactModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ContactModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      company: data['company'] as String? ?? '',
      address: data['address'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      isFavorite: data['isFavorite'] as bool? ?? false,
      createdAt: _dateFrom(data['createdAt']),
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
      'email': email.trim(),
      'company': company.trim(),
      'address': address.trim(),
      'notes': notes.trim(),
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _dateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static String _firstLetter(String value) {
    if (value.isEmpty) return '';
    return String.fromCharCode(value.runes.first).toUpperCase();
  }
}
