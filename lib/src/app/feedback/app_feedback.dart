import 'package:flutter/widgets.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/app_toast.dart';
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
    required String message,
    AppToastVariant variant = AppToastVariant.info,
    String? title,
    AppToastAction? action,
  }) {
    AppToaster.show(
      context,
      message: message,
      variant: variant,
      title: title,
      action: action,
    );
  }

  /// Shows an info toast.
  void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    AppToastAction? action,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showToast(
      context,
      message: message,
      variant: AppToastVariant.info,
      title: title ?? l10n.toastTitleInfo,
      action: action,
    );
  }

  /// Shows a success toast.
  void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    AppToastAction? action,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showToast(
      context,
      message: message,
      variant: AppToastVariant.success,
      title: title ?? l10n.toastTitleSuccess,
      action: action,
    );
  }

  /// Shows a warning toast.
  void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    AppToastAction? action,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showToast(
      context,
      message: message,
      variant: AppToastVariant.warning,
      title: title ?? l10n.toastTitleWarning,
      action: action,
    );
  }

  /// Shows an error toast.
  void showError(
    BuildContext context, {
    required String message,
    String? title,
    AppToastAction? action,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showToast(
      context,
      message: message,
      variant: AppToastVariant.error,
      title: title ?? l10n.toastTitleError,
      action: action,
    );
  }

  /// Resolves an [error] and shows it as an error toast.
  void resolveAndShowError(
    BuildContext context,
    Object error, {
    String? title,
    AppToastAction? action,
  }) {
    final Failure failure = _failureMapper.map(error);
    final String message = _failureMessageResolver.resolve(context, failure);
    showError(context, message: message, title: title, action: action);
  }
}
