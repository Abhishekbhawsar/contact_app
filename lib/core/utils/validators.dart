class Validators {
  const Validators._();

  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  static String? phone(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[0-9\s().-]{7,20}$');
    if (!phoneRegex.hasMatch(input)) return 'Enter a valid phone number';
    return null;
  }

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return null;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(input)) return 'Enter a valid email address';
    return null;
  }
}
