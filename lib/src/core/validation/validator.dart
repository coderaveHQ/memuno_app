import 'package:memuno_app/src/core/failures/failure.dart';

/// Input validation helpers (regex-based).
final class Validator {
  /// Creates a validator instance.
  const Validator();

  /// Email validation regex (basic RFC-style format).
  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  /// OTP validation regex (exactly 6 digits).
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');

  /// Password validation regex (minimum 6 characters).
  static final RegExp _passwordRegex = RegExp(r'^.{6,}$');

  /// Name validation regex (2 to 64 characters).
  static final RegExp _nameRegex = RegExp(r'^.{2,64}$');

  /// Friendship-code regex (exactly 8 digits).
  static final RegExp _friendshipCodeRegex = RegExp(r'^\d{8}$');

  /// Validates an email address.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateEmail(String email) {
    if (_emailRegex.hasMatch(email)) {
      return null;
    }
    return const Failure.validation(code: 'invalid_email', field: 'email');
  }

  /// Validates a password with a minimum length of 6 characters.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validatePassword(String password) {
    if (_passwordRegex.hasMatch(password)) {
      return null;
    }
    return const Failure.validation(
      code: 'min_length',
      field: 'password',
      params: {'min': 6},
    );
  }

  /// Validates a one-time password (OTP) consisting of 6 digits.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateOtp(String otp) {
    if (_otpRegex.hasMatch(otp)) {
      return null;
    }
    return const Failure.validation(code: 'invalid_format', field: 'otp');
  }

  /// Validates a display name with length between 2 and 64 characters.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateName(String name) {
    if (_nameRegex.hasMatch(name)) {
      return null;
    }
    if (name.length < 2) {
      return const Failure.validation(
        code: 'min_length',
        field: 'name',
        params: {'min': 2},
      );
    }
    return const Failure.validation(
      code: 'max_length',
      field: 'name',
      params: {'max': 64},
    );
  }

  /// Validates an 8-digit friendship code.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateFriendshipCode(String friendshipCode) {
    if (_friendshipCodeRegex.hasMatch(friendshipCode)) {
      return null;
    }
    return const Failure.validation(
      code: 'invalid_friendship_code',
      field: 'friendship_code',
    );
  }
}
