import 'package:flutter/material.dart';

import '../data/models/contact_model.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.contact,
    this.size = 48,
    this.hero = false,
    this.heroTag,
  });

  final ContactModel contact;
  final double size;
  final bool hero;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final avatar = Semantics(
      label: '${contact.name} avatar',
      image: true,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: Text(
          contact.initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: size * 0.34,
              ),
        ),
      ),
    );

    if (!hero) return avatar;
    return Hero(tag: heroTag ?? 'contact-avatar-${contact.id}', child: avatar);
  }
}
