import '../../../../core/localization/app_strings.dart';

abstract final class AuthValidators {
  static String? required(String? value, AppStrings strings) {
    return (value?.trim().isEmpty ?? true) ? strings.requiredFieldError : null;
  }

  static String? email(String? value, AppStrings strings) {
    final email = value?.trim() ?? '';
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return isValid ? null : strings.invalidEmailError;
  }

  static String? password(String? value, AppStrings strings) {
    return (value?.length ?? 0) < 6 ? strings.shortPasswordError : null;
  }

  static String? confirmation(
    String? value,
    String password,
    AppStrings strings,
  ) {
    return value == password ? null : strings.passwordsDoNotMatchError;
  }
}
