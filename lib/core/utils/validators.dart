import '../constants/app_strings.dart';

class Validators {
  const Validators._();

  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    return null;
  }

  static String? phone(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return AppStrings.phoneRequired;
    final phoneRegex = RegExp(r'^\+?[0-9\s().-]{7,20}$');
    if (!phoneRegex.hasMatch(input)) return AppStrings.validPhoneRequired;
    return null;
  }

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return null;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(input)) return AppStrings.validEmailRequired;
    return null;
  }
}
