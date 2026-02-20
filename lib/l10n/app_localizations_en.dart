// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get toastTitleInfo => 'Info';

  @override
  String get toastTitleSuccess => 'Success';

  @override
  String get toastTitleWarning => 'Warning';

  @override
  String get toastTitleError => 'Error';

  @override
  String get genericErrorMessage =>
      'Something went wrong. Please try again later.';

  @override
  String get networkErrorMessage =>
      'No connection. Please check your internet.';

  @override
  String get serverErrorMessage => 'Server error. Please try again later.';

  @override
  String get validationInvalidEmail => 'Please enter a valid email address.';

  @override
  String get validationInvalidFormat => 'Invalid format.';

  @override
  String get validationInvalidFriendshipCode =>
      'Please enter a valid 8-digit friendship code.';

  @override
  String get validationInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get validationUnknown => 'Invalid input. Please check your details.';

  @override
  String validationMinLength(Object min) {
    return 'Must be at least $min characters.';
  }

  @override
  String validationMaxLength(Object max) {
    return 'Must be at most $max characters.';
  }

  @override
  String get signInOtpSentMessage => 'We sent you a code.';

  @override
  String get signInConfirmRegistrationMessage =>
      'Please confirm your registration.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Sign in to continue.';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInSubmitWithPasswordButton => 'Sign in with password';

  @override
  String get signInUseOtpButton => 'Use sign-in code';

  @override
  String get signInSendOtpButton => 'Send sign-in code';

  @override
  String get signInSwitchToPasswordButton => 'Sign in with password';

  @override
  String get signInSignUpButton => 'Sign up';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get homePullToRefreshHint => 'Pull down to refresh.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFriendshipCodeLabel => 'Friendship code:';

  @override
  String profileFriendshipCodeShareText(Object code) {
    return 'Let\'s be friends on Memuno: $code';
  }

  @override
  String get profileJoinedAtLabel => 'Joined on:';

  @override
  String get friendshipsTitle => 'Friendships';

  @override
  String get friendshipsTabFriendships => 'Friendships';

  @override
  String get friendshipsTabRequests => 'Requests';

  @override
  String get friendshipsAddDialogTitle => 'Send friendship request';

  @override
  String get friendshipsAddDialogFieldLabel => 'Friendship code';

  @override
  String get friendshipsAddDialogSubmitButton => 'Send request';

  @override
  String get friendshipsRequestCreateSuccessMessage =>
      'Friendship request sent.';

  @override
  String get friendshipsListEmpty => 'No friendships yet.';

  @override
  String get friendshipsRequestsListEmpty => 'No pending friendship requests.';

  @override
  String get friendshipsFriendsSincePrefix => 'Friends since';

  @override
  String get friendshipsRequestDirectionIncoming => 'Incoming';

  @override
  String get friendshipsRequestDirectionOutgoing => 'Outgoing';

  @override
  String get memeEditorTitle => 'New meme';

  @override
  String get memeEditorFinalizeButton => 'Done';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Select a meme template first.';

  @override
  String get memeEditorCanvasImageLoadError => 'Image could not be loaded.';

  @override
  String get memeEditorAddTextButton => 'Add text';

  @override
  String get memeEditorTextLabel => 'Text';

  @override
  String get memeEditorTextHint => 'Write your meme text';

  @override
  String get memeEditorDefaultText => 'Text';

  @override
  String get memeEditorRenderError => 'Unable to render meme editor output.';

  @override
  String get memeEditorPngEncodeError => 'Unable to convert meme to PNG bytes.';

  @override
  String get sendMemeTitle => 'Send meme';

  @override
  String get sendMemeSubmitButton => 'Send';

  @override
  String get sendMemeSuccessMessage => 'Meme sent successfully.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Manage your account and app preferences.';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAccountManagement => 'Account management';

  @override
  String get settingsThemeModeTitle => 'Theme mode';

  @override
  String get settingsThemeModeSubtitle => 'Choose how the app looks.';

  @override
  String get settingsThemeModeSystemOption => 'System';

  @override
  String get settingsThemeModeLightOption => 'Light';

  @override
  String get settingsThemeModeDarkOption => 'Dark';

  @override
  String settingsThemeModeSystemDescription(Object mode) {
    return 'Follow system ($mode).';
  }

  @override
  String get settingsLanguageModeTitle => 'Language mode';

  @override
  String get settingsLanguageModeSubtitle =>
      'Choose your preferred app language.';

  @override
  String get settingsLanguageModeSystemOption => 'System';

  @override
  String settingsLanguageModeSystemDescription(Object language) {
    return 'Follow system ($language).';
  }

  @override
  String get settingsChangeEmailListTileTitle => 'Change email';

  @override
  String get settingsChangeEmailListTileSubtitle =>
      'Update your sign-in email address.';

  @override
  String get settingsChangePasswordListTileTitle => 'Change password';

  @override
  String get settingsChangePasswordListTileSubtitle =>
      'Set a new password for your account.';

  @override
  String get settingsDeleteAccountListTileTitle => 'Delete account';

  @override
  String get settingsDeleteAccountListTileSubtitle =>
      'Permanently delete your account and data.';

  @override
  String get settingsChangeEmailTitle => 'Change email';

  @override
  String get settingsChangeEmailSubtitle =>
      'Enter your new email and confirm it from your inbox.';

  @override
  String settingsChangeEmailCurrentEmail(Object email) {
    return 'Current email: $email';
  }

  @override
  String get settingsChangeEmailNewEmailLabel => 'New email';

  @override
  String get settingsChangeEmailSubmitButton => 'Send confirmation email';

  @override
  String get settingsChangePasswordTitle => 'Change password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Set a new password for your account.';

  @override
  String get settingsChangePasswordNewPasswordLabel => 'New password';

  @override
  String get settingsChangePasswordSubmitButton => 'Change password';

  @override
  String get settingsChangePasswordSuccessMessage =>
      'Your password was changed successfully.';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsDeleteAccountSubtitle =>
      'This action is permanent and cannot be undone.';

  @override
  String get settingsDeleteAccountWarningBody =>
      'Deleting your account permanently removes your profile and access to the app.';

  @override
  String get settingsDeleteAccountSubmitButton => 'Delete my account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Delete account?';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'This action is permanent. Do you want to continue?';

  @override
  String get settingsDeleteAccountConfirmCancelButton => 'Cancel';

  @override
  String get settingsDeleteAccountConfirmDeleteButton => 'Delete';

  @override
  String get settingsDeleteAccountSuccessMessage => 'Your account was deleted.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Please confirm your registration.';

  @override
  String get signUpTitle => 'Sign up';

  @override
  String get signUpSubtitle => 'Enter your details to get started.';

  @override
  String get signUpNameLabel => 'Full name';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpPasswordLabel => 'Password';

  @override
  String get signUpCreateAccountButton => 'Create account';

  @override
  String get verifySignInResentCodeMessage => 'We sent you another code.';

  @override
  String get verifySignInTitle => 'Verify sign-in';

  @override
  String verifySignInInstruction(Object email) {
    return 'Enter the 6-digit code sent to $email, or open the link in your email.';
  }

  @override
  String get verifySignInCodeLabel => 'Verification code';

  @override
  String get verifySignInConfirmButton => 'Confirm';

  @override
  String get verifySignInNoEmailText => 'Did not receive an email?';

  @override
  String get verifySignInResendCodeButton => 'Resend code';

  @override
  String get verifySignUpResentCodeMessage => 'We sent you another code.';

  @override
  String get verifySignUpTitle => 'Verify sign-up';

  @override
  String verifySignUpInstruction(Object email) {
    return 'Enter the 6-digit code sent to $email, or open the link in your email.';
  }

  @override
  String get verifySignUpCodeLabel => 'Verification code';

  @override
  String get verifySignUpConfirmButton => 'Confirm';

  @override
  String get verifySignUpNoEmailText => 'Did not receive an email?';

  @override
  String get verifySignUpResendCodeButton => 'Resend code';

  @override
  String get authToastEmailChangedTitle => 'Email address changed';

  @override
  String get authToastEmailChangedMessage =>
      'We successfully changed your email address.';

  @override
  String get authToastSignedInTitle => 'Sign-in successful';

  @override
  String get authToastSignedInMessage =>
      'You have been signed in successfully.';

  @override
  String get authToastSignedOutTitle => 'Sign-out successful';

  @override
  String get authToastSignedOutMessage =>
      'You have been signed out successfully.';

  @override
  String get authToastPasswordRecoveryTitle => 'Sign-in successful';

  @override
  String get authToastPasswordRecoveryMessage =>
      'You can now change your password.';

  @override
  String get homeGreetingGeneric => 'Hey! 👋';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hey, $name! 👋';
  }
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get toastTitleInfo => 'Info';

  @override
  String get toastTitleSuccess => 'Success';

  @override
  String get toastTitleWarning => 'Warning';

  @override
  String get toastTitleError => 'Error';

  @override
  String get genericErrorMessage =>
      'Something went wrong. Please try again later.';

  @override
  String get networkErrorMessage =>
      'No connection. Please check your internet.';

  @override
  String get serverErrorMessage => 'Server error. Please try again later.';

  @override
  String get validationInvalidEmail => 'Please enter a valid email address.';

  @override
  String get validationInvalidFormat => 'Invalid format.';

  @override
  String get validationInvalidFriendshipCode =>
      'Please enter a valid 8-digit friendship code.';

  @override
  String get validationInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get validationUnknown => 'Invalid input. Please check your details.';

  @override
  String validationMinLength(Object min) {
    return 'Must be at least $min characters.';
  }

  @override
  String validationMaxLength(Object max) {
    return 'Must be at most $max characters.';
  }

  @override
  String get signInOtpSentMessage => 'We sent you a code.';

  @override
  String get signInConfirmRegistrationMessage =>
      'Please confirm your registration.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Sign in to continue.';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInSubmitWithPasswordButton => 'Sign in with password';

  @override
  String get signInUseOtpButton => 'Use sign-in code';

  @override
  String get signInSendOtpButton => 'Send sign-in code';

  @override
  String get signInSwitchToPasswordButton => 'Sign in with password';

  @override
  String get signInSignUpButton => 'Sign up';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get homePullToRefreshHint => 'Pull down to refresh.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFriendshipCodeLabel => 'Friendship code:';

  @override
  String profileFriendshipCodeShareText(Object code) {
    return 'Let\'s be friends on Memuno: $code';
  }

  @override
  String get profileJoinedAtLabel => 'Joined on:';

  @override
  String get friendshipsTitle => 'Friendships';

  @override
  String get friendshipsTabFriendships => 'Friendships';

  @override
  String get friendshipsTabRequests => 'Requests';

  @override
  String get friendshipsAddDialogTitle => 'Send friendship request';

  @override
  String get friendshipsAddDialogFieldLabel => 'Friendship code';

  @override
  String get friendshipsAddDialogSubmitButton => 'Send request';

  @override
  String get friendshipsRequestCreateSuccessMessage =>
      'Friendship request sent.';

  @override
  String get friendshipsListEmpty => 'No friendships yet.';

  @override
  String get friendshipsRequestsListEmpty => 'No pending friendship requests.';

  @override
  String get friendshipsFriendsSincePrefix => 'Friends since';

  @override
  String get friendshipsRequestDirectionIncoming => 'Incoming';

  @override
  String get friendshipsRequestDirectionOutgoing => 'Outgoing';

  @override
  String get memeEditorTitle => 'New meme';

  @override
  String get memeEditorFinalizeButton => 'Done';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Select a meme template first.';

  @override
  String get memeEditorCanvasImageLoadError => 'Image could not be loaded.';

  @override
  String get memeEditorAddTextButton => 'Add text';

  @override
  String get memeEditorTextLabel => 'Text';

  @override
  String get memeEditorTextHint => 'Write your meme text';

  @override
  String get memeEditorDefaultText => 'Text';

  @override
  String get memeEditorRenderError => 'Unable to render meme editor output.';

  @override
  String get memeEditorPngEncodeError => 'Unable to convert meme to PNG bytes.';

  @override
  String get sendMemeTitle => 'Send meme';

  @override
  String get sendMemeSubmitButton => 'Send';

  @override
  String get sendMemeSuccessMessage => 'Meme sent successfully.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Manage your account and app preferences.';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAccountManagement => 'Account management';

  @override
  String get settingsThemeModeTitle => 'Theme mode';

  @override
  String get settingsThemeModeSubtitle => 'Choose how the app looks.';

  @override
  String get settingsThemeModeSystemOption => 'System';

  @override
  String get settingsThemeModeLightOption => 'Light';

  @override
  String get settingsThemeModeDarkOption => 'Dark';

  @override
  String settingsThemeModeSystemDescription(Object mode) {
    return 'Follow system ($mode).';
  }

  @override
  String get settingsLanguageModeTitle => 'Language mode';

  @override
  String get settingsLanguageModeSubtitle =>
      'Choose your preferred app language.';

  @override
  String get settingsLanguageModeSystemOption => 'System';

  @override
  String settingsLanguageModeSystemDescription(Object language) {
    return 'Follow system ($language).';
  }

  @override
  String get settingsChangeEmailListTileTitle => 'Change email';

  @override
  String get settingsChangeEmailListTileSubtitle =>
      'Update your sign-in email address.';

  @override
  String get settingsChangePasswordListTileTitle => 'Change password';

  @override
  String get settingsChangePasswordListTileSubtitle =>
      'Set a new password for your account.';

  @override
  String get settingsDeleteAccountListTileTitle => 'Delete account';

  @override
  String get settingsDeleteAccountListTileSubtitle =>
      'Permanently delete your account and data.';

  @override
  String get settingsChangeEmailTitle => 'Change email';

  @override
  String get settingsChangeEmailSubtitle =>
      'Enter your new email and confirm it from your inbox.';

  @override
  String settingsChangeEmailCurrentEmail(Object email) {
    return 'Current email: $email';
  }

  @override
  String get settingsChangeEmailNewEmailLabel => 'New email';

  @override
  String get settingsChangeEmailSubmitButton => 'Send confirmation email';

  @override
  String get settingsChangePasswordTitle => 'Change password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Set a new password for your account.';

  @override
  String get settingsChangePasswordNewPasswordLabel => 'New password';

  @override
  String get settingsChangePasswordSubmitButton => 'Change password';

  @override
  String get settingsChangePasswordSuccessMessage =>
      'Your password was changed successfully.';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsDeleteAccountSubtitle =>
      'This action is permanent and cannot be undone.';

  @override
  String get settingsDeleteAccountWarningBody =>
      'Deleting your account permanently removes your profile and access to the app.';

  @override
  String get settingsDeleteAccountSubmitButton => 'Delete my account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Delete account?';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'This action is permanent. Do you want to continue?';

  @override
  String get settingsDeleteAccountConfirmCancelButton => 'Cancel';

  @override
  String get settingsDeleteAccountConfirmDeleteButton => 'Delete';

  @override
  String get settingsDeleteAccountSuccessMessage => 'Your account was deleted.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Please confirm your registration.';

  @override
  String get signUpTitle => 'Sign up';

  @override
  String get signUpSubtitle => 'Enter your details to get started.';

  @override
  String get signUpNameLabel => 'Full name';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpPasswordLabel => 'Password';

  @override
  String get signUpCreateAccountButton => 'Create account';

  @override
  String get verifySignInResentCodeMessage => 'We sent you another code.';

  @override
  String get verifySignInTitle => 'Verify sign-in';

  @override
  String verifySignInInstruction(Object email) {
    return 'Enter the 6-digit code sent to $email, or open the link in your email.';
  }

  @override
  String get verifySignInCodeLabel => 'Verification code';

  @override
  String get verifySignInConfirmButton => 'Confirm';

  @override
  String get verifySignInNoEmailText => 'Did not receive an email?';

  @override
  String get verifySignInResendCodeButton => 'Resend code';

  @override
  String get verifySignUpResentCodeMessage => 'We sent you another code.';

  @override
  String get verifySignUpTitle => 'Verify sign-up';

  @override
  String verifySignUpInstruction(Object email) {
    return 'Enter the 6-digit code sent to $email, or open the link in your email.';
  }

  @override
  String get verifySignUpCodeLabel => 'Verification code';

  @override
  String get verifySignUpConfirmButton => 'Confirm';

  @override
  String get verifySignUpNoEmailText => 'Did not receive an email?';

  @override
  String get verifySignUpResendCodeButton => 'Resend code';

  @override
  String get authToastEmailChangedTitle => 'Email address changed';

  @override
  String get authToastEmailChangedMessage =>
      'We successfully changed your email address.';

  @override
  String get authToastSignedInTitle => 'Sign-in successful';

  @override
  String get authToastSignedInMessage =>
      'You have been signed in successfully.';

  @override
  String get authToastSignedOutTitle => 'Sign-out successful';

  @override
  String get authToastSignedOutMessage =>
      'You have been signed out successfully.';

  @override
  String get authToastPasswordRecoveryTitle => 'Sign-in successful';

  @override
  String get authToastPasswordRecoveryMessage =>
      'You can now change your password.';

  @override
  String get homeGreetingGeneric => 'Hey! 👋';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hey, $name! 👋';
  }
}
