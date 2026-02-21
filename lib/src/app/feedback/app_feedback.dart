import 'package:flutter/widgets.dart';
import 'package:memuno_app/src/app/widgets/m/m_toast.dart';
import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/failures/failure_message_resolver.dart';

/// Centralized user feedback helpers.
final class AppFeedback {
  /// Creates an AppFeedback instance.
  const AppFeedback({
    required FailureMapper failureMapper,
    required FailureMessageResolver failureMessageResolver,
  }) : _failureMapper = failureMapper,
       _failureMessageResolver = failureMessageResolver;

  final FailureMapper _failureMapper;
  final FailureMessageResolver _failureMessageResolver;

  /// Shows a generic toast.
  void showToast(
    BuildContext context, {
    required MToastVariant variant,
    required String message,
  }) {
    showMToast(context, variant, message);
  }

  /// Shows a success toast.
  void showSuccess(BuildContext context, {required String message}) {
    showToast(context, message: message, variant: MToastVariant.success);
  }

  /// Shows an info toast.
  void showInfo(BuildContext context, {required String message}) {
    showToast(context, message: message, variant: MToastVariant.info);
  }

  /// Shows a warning toast.
  void showWarning(BuildContext context, {required String message}) {
    showToast(context, message: message, variant: MToastVariant.warning);
  }

  /// Shows an error toast.
  void showError(BuildContext context, {required String message}) {
    showToast(context, message: message, variant: MToastVariant.error);
  }

  String resolve(BuildContext context, Object error) {
    final Failure failure = _failureMapper.map(error);
    final String message = _failureMessageResolver.resolve(context, failure);
    return message;
  }

  /// Resolves an [error] and shows it as an error toast.
  void resolveAndShowError(BuildContext context, Object error) {
    final String message = resolve(context, error);
    showError(context, message: message);
  }
}
