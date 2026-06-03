import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../providers/internet_provider.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/responsive_page.dart';

class AddEditContactScreen extends StatefulWidget {
  const AddEditContactScreen({super.key, this.contact});

  final ContactModel? contact;

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  bool _isFavorite = false;
  bool _isSaving = false;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _nameController = TextEditingController(text: contact?.name ?? '');
    _phoneController = TextEditingController(text: contact?.phoneNumber ?? '');
    _emailController = TextEditingController(text: contact?.email ?? '');
    _companyController = TextEditingController(text: contact?.company ?? '');
    _addressController = TextEditingController(text: contact?.address ?? '');
    _notesController = TextEditingController(text: contact?.notes ?? '');
    _isFavorite = contact?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select<InternetProvider, bool>((value) => value.isOffline);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editContact : AppStrings.addContact),
      ),
      body: SafeArea(
        child: isOffline
            ? const OfflineBanner()
            : ResponsivePage(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _Header(isEditing: _isEditing),
                      const SizedBox(height: 24),
                      _field(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        icon: Icons.person_outline_rounded,
                        validator: Validators.requiredName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _phoneController,
                        label: AppStrings.phoneNumber,
                        icon: Icons.call_outlined,
                        validator: Validators.phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _emailController,
                        label: AppStrings.emailAddress,
                        icon: Icons.mail_outline_rounded,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _companyController,
                        label: AppStrings.company,
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _addressController,
                        label: AppStrings.address,
                        icon: Icons.place_outlined,
                        minLines: 2,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _notesController,
                        label: AppStrings.notes,
                        icon: Icons.notes_outlined,
                        minLines: 3,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(AppStrings.favorite),
                        subtitle: const Text(AppStrings.favoriteSubtitle),
                        secondary: Icon(_isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                        value: _isFavorite,
                        onChanged: (value) => setState(() => _isFavorite = value),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isEditing ? AppStrings.saveChanges : AppStrings.createContact,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int minLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 5,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (context.read<InternetProvider>().isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.offlineSnackbarMessage),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<ContactProvider>();
    final now = DateTime.now();
    final existing = widget.contact;
    final contact = ContactModel(
      id: existing?.id ?? '',
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      company: _companyController.text,
      address: _addressController.text,
      notes: _notesController.text,
      isFavorite: _isFavorite,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await provider.updateContact(contact);
      } else {
        await provider.addContact(contact);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? AppStrings.contactUpdated : AppStrings.contactAdded),
        ),
      );
      navigator.pop();
    } catch (error) {
      final message = error.toString().contains('timed out')
          ? AppStrings.saveTimedOut
          : AppStrings.couldNotSaveContact;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return Flex(
          direction: compact ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(
              isEditing ? Icons.manage_accounts_outlined : Icons.person_add_alt_1_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: compact ? 0 : 20, height: compact ? 12 : 0),
            if (compact)
              _HeaderText(isEditing: isEditing)
            else
              Expanded(
                child: _HeaderText(isEditing: isEditing),
              ),
          ],
        );
      },
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Text(
      isEditing ? AppStrings.editContactHeader : AppStrings.addContactHeader,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
