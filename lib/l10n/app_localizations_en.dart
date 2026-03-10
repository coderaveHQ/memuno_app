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
  String get permissionGalleryDeniedMessage =>
      'Please allow photo-library access to choose an image from your device.';

  @override
  String get validationMemePayloadTooLarge =>
      'Image and text exceed 5 MB together. Please use a smaller image.';

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
  String get userDetailsTitle => 'User details';

  @override
  String get userDetailsFriendshipCodeLabel => 'Friendship code:';

  @override
  String userDetailsFriendshipCodeShareText(Object code) {
    return 'Let\'s be friends on Memuno: $code';
  }

  @override
  String get userDetailsJoinedAtLabel => 'Joined on:';

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
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSearchLabel => 'Search notifications';

  @override
  String get notificationsSearchHint => 'Search by name or friendship code';

  @override
  String get notificationsListEmpty => 'No notifications yet.';

  @override
  String get feedListEmpty => 'No memes in your feed yet.';

  @override
  String get memeDetailsTitle => 'Meme details';

  @override
  String get memeDetailsLaughsTitle => 'Who laughed?';

  @override
  String get memeDetailsLaughsEmpty => 'No laughs yet.';

  @override
  String get notificationsItemFriendshipRequestSentTitle =>
      'New friendship request';

  @override
  String notificationsItemFriendshipRequestSent(Object sender_name) {
    return '$sender_name sent you a friendship request.';
  }

  @override
  String get notificationsItemFriendshipRequestAcceptedTitle =>
      'Friendship request accepted';

  @override
  String notificationsItemFriendshipRequestAccepted(Object sender_name) {
    return '$sender_name accepted your friendship request.';
  }

  @override
  String get notificationsItemMemeReceivedTitle => 'New meme received';

  @override
  String notificationsItemMemeReceived(Object sender_name) {
    return '$sender_name sent you a meme.';
  }

  @override
  String get notificationsItemMemeLaughedTitle => 'Your meme got a laugh';

  @override
  String notificationsItemMemeLaughed(Object sender_name) {
    return '$sender_name laughed at your meme.';
  }

  @override
  String get memeTemplatePickerTitle => 'Meme templates';

  @override
  String get memeTemplatePickerSearchLabel => 'Search template';

  @override
  String get memeTemplatePickerSearchHint => 'e.g. drake, distracted, doge';

  @override
  String get memeTemplatePickerEmpty => 'No meme templates found.';

  @override
  String get memeTemplatePickerGalleryButton => 'From gallery';

  @override
  String get memeEditorTitle => 'New meme';

  @override
  String get memeEditorFinalizeButton => 'Done';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Select a meme template or choose an image from your gallery.';

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
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAccountManagement => 'Account management';

  @override
  String get languageModeTitle => 'Language mode';

  @override
  String get languageModeSystemOption => 'System';

  @override
  String languageModeSystemDescription(Object language) {
    return 'Follow system ($language).';
  }

  @override
  String get changeEmailListTileTitle => 'Change email';

  @override
  String get changeEmailListTileSubtitle =>
      'Update your sign-in email address.';

  @override
  String get changePasswordListTileTitle => 'Change password';

  @override
  String get changePasswordListTileSubtitle =>
      'Set a new password for your account.';

  @override
  String get deleteAccountListTileTitle => 'Delete account';

  @override
  String get deleteAccountListTileSubtitle =>
      'Permanently delete your account and data.';

  @override
  String get changeEmailTitle => 'Change email';

  @override
  String changeEmailCurrentEmail(Object email) {
    return 'Current email: $email';
  }

  @override
  String get changeEmailNewEmailLabel => 'New email';

  @override
  String get changeEmailSubmitButton => 'Send confirmation email';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordNewPasswordLabel => 'New password';

  @override
  String get changePasswordSubmitButton => 'Change password';

  @override
  String get changePasswordSuccessMessage =>
      'Your password was changed successfully.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarningBody =>
      'Deleting your account permanently removes your profile and access to the app.';

  @override
  String get deleteAccountSubmitButton => 'Delete my account';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage =>
      'This action is permanent. Do you want to continue?';

  @override
  String get deleteAccountConfirmCancelButton => 'Cancel';

  @override
  String get deleteAccountConfirmDeleteButton => 'Delete';

  @override
  String get deleteAccountSuccessMessage => 'Your account was deleted.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Please confirm your registration.';

  @override
  String get signUpTitle => 'Sign up';

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
  String get verifySignInConfirmButton => 'Confirm';

  @override
  String get verifySignInResendCodeButton => 'Resend code';

  @override
  String get verifySignUpResentCodeMessage => 'We sent you another code.';

  @override
  String get verifySignUpTitle => 'Verify sign-up';

  @override
  String get verifySignUpConfirmButton => 'Confirm';

  @override
  String get verifySignUpResendCodeButton => 'Resend code';

  @override
  String get authToastEmailChangedMessage =>
      'We successfully changed your email address.';

  @override
  String get authToastSignedInMessage =>
      'You have been signed in successfully.';

  @override
  String get authToastSignedOutMessage =>
      'You have been signed out successfully.';

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
  String get permissionGalleryDeniedMessage =>
      'Please allow photo-library access to choose an image from your device.';

  @override
  String get validationMemePayloadTooLarge =>
      'Image and text exceed 5 MB together. Please use a smaller image.';

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
  String get userDetailsTitle => 'User details';

  @override
  String get userDetailsFriendshipCodeLabel => 'Friendship code:';

  @override
  String userDetailsFriendshipCodeShareText(Object code) {
    return 'Let\'s be friends on Memuno: $code';
  }

  @override
  String get userDetailsJoinedAtLabel => 'Joined on:';

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
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSearchLabel => 'Search notifications';

  @override
  String get notificationsSearchHint => 'Search by name or friendship code';

  @override
  String get notificationsListEmpty => 'No notifications yet.';

  @override
  String get feedListEmpty => 'No memes in your feed yet.';

  @override
  String get memeDetailsTitle => 'Meme details';

  @override
  String get memeDetailsLaughsTitle => 'Who laughed?';

  @override
  String get memeDetailsLaughsEmpty => 'No laughs yet.';

  @override
  String get notificationsItemFriendshipRequestSentTitle =>
      'New friendship request';

  @override
  String notificationsItemFriendshipRequestSent(Object sender_name) {
    return '$sender_name sent you a friendship request.';
  }

  @override
  String get notificationsItemFriendshipRequestAcceptedTitle =>
      'Friendship request accepted';

  @override
  String notificationsItemFriendshipRequestAccepted(Object sender_name) {
    return '$sender_name accepted your friendship request.';
  }

  @override
  String get notificationsItemMemeReceivedTitle => 'New meme received';

  @override
  String notificationsItemMemeReceived(Object sender_name) {
    return '$sender_name sent you a meme.';
  }

  @override
  String get notificationsItemMemeLaughedTitle => 'Your meme got a laugh';

  @override
  String notificationsItemMemeLaughed(Object sender_name) {
    return '$sender_name laughed at your meme.';
  }

  @override
  String get memeTemplatePickerTitle => 'Meme templates';

  @override
  String get memeTemplatePickerSearchLabel => 'Search template';

  @override
  String get memeTemplatePickerSearchHint => 'e.g. drake, distracted, doge';

  @override
  String get memeTemplatePickerEmpty => 'No meme templates found.';

  @override
  String get memeTemplatePickerGalleryButton => 'From gallery';

  @override
  String get memeEditorTitle => 'New meme';

  @override
  String get memeEditorFinalizeButton => 'Done';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Select a meme template or choose an image from your gallery.';

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
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAccountManagement => 'Account management';

  @override
  String get languageModeTitle => 'Language mode';

  @override
  String get languageModeSystemOption => 'System';

  @override
  String languageModeSystemDescription(Object language) {
    return 'Follow system ($language).';
  }

  @override
  String get changeEmailListTileTitle => 'Change email';

  @override
  String get changeEmailListTileSubtitle =>
      'Update your sign-in email address.';

  @override
  String get changePasswordListTileTitle => 'Change password';

  @override
  String get changePasswordListTileSubtitle =>
      'Set a new password for your account.';

  @override
  String get deleteAccountListTileTitle => 'Delete account';

  @override
  String get deleteAccountListTileSubtitle =>
      'Permanently delete your account and data.';

  @override
  String get changeEmailTitle => 'Change email';

  @override
  String changeEmailCurrentEmail(Object email) {
    return 'Current email: $email';
  }

  @override
  String get changeEmailNewEmailLabel => 'New email';

  @override
  String get changeEmailSubmitButton => 'Send confirmation email';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordNewPasswordLabel => 'New password';

  @override
  String get changePasswordSubmitButton => 'Change password';

  @override
  String get changePasswordSuccessMessage =>
      'Your password was changed successfully.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarningBody =>
      'Deleting your account permanently removes your profile and access to the app.';

  @override
  String get deleteAccountSubmitButton => 'Delete my account';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage =>
      'This action is permanent. Do you want to continue?';

  @override
  String get deleteAccountConfirmCancelButton => 'Cancel';

  @override
  String get deleteAccountConfirmDeleteButton => 'Delete';

  @override
  String get deleteAccountSuccessMessage => 'Your account was deleted.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Please confirm your registration.';

  @override
  String get signUpTitle => 'Sign up';

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
  String get verifySignInConfirmButton => 'Confirm';

  @override
  String get verifySignInResendCodeButton => 'Resend code';

  @override
  String get verifySignUpResentCodeMessage => 'We sent you another code.';

  @override
  String get verifySignUpTitle => 'Verify sign-up';

  @override
  String get verifySignUpConfirmButton => 'Confirm';

  @override
  String get verifySignUpResendCodeButton => 'Resend code';

  @override
  String get authToastEmailChangedMessage =>
      'We successfully changed your email address.';

  @override
  String get authToastSignedInMessage =>
      'You have been signed in successfully.';

  @override
  String get authToastSignedOutMessage =>
      'You have been signed out successfully.';

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
