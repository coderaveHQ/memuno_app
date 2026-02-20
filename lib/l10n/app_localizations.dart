import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @toastTitleInfo.
  ///
  /// In en_US, this message translates to:
  /// **'Info'**
  String get toastTitleInfo;

  /// No description provided for @toastTitleSuccess.
  ///
  /// In en_US, this message translates to:
  /// **'Success'**
  String get toastTitleSuccess;

  /// No description provided for @toastTitleWarning.
  ///
  /// In en_US, this message translates to:
  /// **'Warning'**
  String get toastTitleWarning;

  /// No description provided for @toastTitleError.
  ///
  /// In en_US, this message translates to:
  /// **'Error'**
  String get toastTitleError;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get genericErrorMessage;

  /// No description provided for @networkErrorMessage.
  ///
  /// In en_US, this message translates to:
  /// **'No connection. Please check your internet.'**
  String get networkErrorMessage;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverErrorMessage;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validationInvalidEmail;

  /// No description provided for @validationInvalidFormat.
  ///
  /// In en_US, this message translates to:
  /// **'Invalid format.'**
  String get validationInvalidFormat;

  /// No description provided for @validationInvalidFriendshipCode.
  ///
  /// In en_US, this message translates to:
  /// **'Please enter a valid 8-digit friendship code.'**
  String get validationInvalidFriendshipCode;

  /// No description provided for @validationInvalidCredentials.
  ///
  /// In en_US, this message translates to:
  /// **'Email or password is incorrect.'**
  String get validationInvalidCredentials;

  /// No description provided for @validationUnknown.
  ///
  /// In en_US, this message translates to:
  /// **'Invalid input. Please check your details.'**
  String get validationUnknown;

  /// No description provided for @validationMinLength.
  ///
  /// In en_US, this message translates to:
  /// **'Must be at least {min} characters.'**
  String validationMinLength(Object min);

  /// No description provided for @validationMaxLength.
  ///
  /// In en_US, this message translates to:
  /// **'Must be at most {max} characters.'**
  String validationMaxLength(Object max);

  /// No description provided for @signInOtpSentMessage.
  ///
  /// In en_US, this message translates to:
  /// **'We sent you a code.'**
  String get signInOtpSentMessage;

  /// No description provided for @signInConfirmRegistrationMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Please confirm your registration.'**
  String get signInConfirmRegistrationMessage;

  /// No description provided for @signInTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Sign in to continue.'**
  String get signInSubtitle;

  /// No description provided for @signInEmailLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// No description provided for @signInPasswordLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Password'**
  String get signInPasswordLabel;

  /// No description provided for @signInSubmitWithPasswordButton.
  ///
  /// In en_US, this message translates to:
  /// **'Sign in with password'**
  String get signInSubmitWithPasswordButton;

  /// No description provided for @signInUseOtpButton.
  ///
  /// In en_US, this message translates to:
  /// **'Use sign-in code'**
  String get signInUseOtpButton;

  /// No description provided for @signInSendOtpButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send sign-in code'**
  String get signInSendOtpButton;

  /// No description provided for @signInSwitchToPasswordButton.
  ///
  /// In en_US, this message translates to:
  /// **'Sign in with password'**
  String get signInSwitchToPasswordButton;

  /// No description provided for @signInSignUpButton.
  ///
  /// In en_US, this message translates to:
  /// **'Sign up'**
  String get signInSignUpButton;

  /// No description provided for @signOutButton.
  ///
  /// In en_US, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// No description provided for @homePullToRefreshHint.
  ///
  /// In en_US, this message translates to:
  /// **'Pull down to refresh.'**
  String get homePullToRefreshHint;

  /// No description provided for @profileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFriendshipCodeLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Friendship code:'**
  String get profileFriendshipCodeLabel;

  /// No description provided for @profileFriendshipCodeShareText.
  ///
  /// In en_US, this message translates to:
  /// **'Let\'\'s be friends on Memuno: {code}'**
  String profileFriendshipCodeShareText(Object code);

  /// No description provided for @profileJoinedAtLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Joined on:'**
  String get profileJoinedAtLabel;

  /// No description provided for @friendshipsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Friendships'**
  String get friendshipsTitle;

  /// No description provided for @friendshipsTabFriendships.
  ///
  /// In en_US, this message translates to:
  /// **'Friendships'**
  String get friendshipsTabFriendships;

  /// No description provided for @friendshipsTabRequests.
  ///
  /// In en_US, this message translates to:
  /// **'Requests'**
  String get friendshipsTabRequests;

  /// No description provided for @friendshipsAddDialogTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Send friendship request'**
  String get friendshipsAddDialogTitle;

  /// No description provided for @friendshipsAddDialogFieldLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Friendship code'**
  String get friendshipsAddDialogFieldLabel;

  /// No description provided for @friendshipsAddDialogSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send request'**
  String get friendshipsAddDialogSubmitButton;

  /// No description provided for @friendshipsRequestCreateSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Friendship request sent.'**
  String get friendshipsRequestCreateSuccessMessage;

  /// No description provided for @friendshipsListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No friendships yet.'**
  String get friendshipsListEmpty;

  /// No description provided for @friendshipsRequestsListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No pending friendship requests.'**
  String get friendshipsRequestsListEmpty;

  /// No description provided for @friendshipsFriendsSincePrefix.
  ///
  /// In en_US, this message translates to:
  /// **'Friends since'**
  String get friendshipsFriendsSincePrefix;

  /// No description provided for @friendshipsRequestDirectionIncoming.
  ///
  /// In en_US, this message translates to:
  /// **'Incoming'**
  String get friendshipsRequestDirectionIncoming;

  /// No description provided for @friendshipsRequestDirectionOutgoing.
  ///
  /// In en_US, this message translates to:
  /// **'Outgoing'**
  String get friendshipsRequestDirectionOutgoing;

  /// No description provided for @memeTemplatePickerTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Meme templates'**
  String get memeTemplatePickerTitle;

  /// No description provided for @memeTemplatePickerSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search template'**
  String get memeTemplatePickerSearchLabel;

  /// No description provided for @memeTemplatePickerSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'e.g. drake, distracted, doge'**
  String get memeTemplatePickerSearchHint;

  /// No description provided for @memeTemplatePickerEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No meme templates found.'**
  String get memeTemplatePickerEmpty;

  /// No description provided for @memeEditorTitle.
  ///
  /// In en_US, this message translates to:
  /// **'New meme'**
  String get memeEditorTitle;

  /// No description provided for @memeEditorFinalizeButton.
  ///
  /// In en_US, this message translates to:
  /// **'Done'**
  String get memeEditorFinalizeButton;

  /// No description provided for @memeEditorCanvasSelectTemplateHint.
  ///
  /// In en_US, this message translates to:
  /// **'Select a meme template first.'**
  String get memeEditorCanvasSelectTemplateHint;

  /// No description provided for @memeEditorCanvasImageLoadError.
  ///
  /// In en_US, this message translates to:
  /// **'Image could not be loaded.'**
  String get memeEditorCanvasImageLoadError;

  /// No description provided for @memeEditorAddTextButton.
  ///
  /// In en_US, this message translates to:
  /// **'Add text'**
  String get memeEditorAddTextButton;

  /// No description provided for @memeEditorTextLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Text'**
  String get memeEditorTextLabel;

  /// No description provided for @memeEditorTextHint.
  ///
  /// In en_US, this message translates to:
  /// **'Write your meme text'**
  String get memeEditorTextHint;

  /// No description provided for @memeEditorDefaultText.
  ///
  /// In en_US, this message translates to:
  /// **'Text'**
  String get memeEditorDefaultText;

  /// No description provided for @memeEditorRenderError.
  ///
  /// In en_US, this message translates to:
  /// **'Unable to render meme editor output.'**
  String get memeEditorRenderError;

  /// No description provided for @memeEditorPngEncodeError.
  ///
  /// In en_US, this message translates to:
  /// **'Unable to convert meme to PNG bytes.'**
  String get memeEditorPngEncodeError;

  /// No description provided for @sendMemeTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Send meme'**
  String get sendMemeTitle;

  /// No description provided for @sendMemeSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send'**
  String get sendMemeSubmitButton;

  /// No description provided for @sendMemeSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Meme sent successfully.'**
  String get sendMemeSuccessMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Manage your account and app preferences.'**
  String get settingsSubtitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en_US, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionAccountManagement.
  ///
  /// In en_US, this message translates to:
  /// **'Account management'**
  String get settingsSectionAccountManagement;

  /// No description provided for @settingsThemeModeTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeModeTitle;

  /// No description provided for @settingsThemeModeSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Choose how the app looks.'**
  String get settingsThemeModeSubtitle;

  /// No description provided for @settingsThemeModeSystemOption.
  ///
  /// In en_US, this message translates to:
  /// **'System'**
  String get settingsThemeModeSystemOption;

  /// No description provided for @settingsThemeModeLightOption.
  ///
  /// In en_US, this message translates to:
  /// **'Light'**
  String get settingsThemeModeLightOption;

  /// No description provided for @settingsThemeModeDarkOption.
  ///
  /// In en_US, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeDarkOption;

  /// No description provided for @settingsThemeModeSystemDescription.
  ///
  /// In en_US, this message translates to:
  /// **'Follow system ({mode}).'**
  String settingsThemeModeSystemDescription(Object mode);

  /// No description provided for @settingsLanguageModeTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Language mode'**
  String get settingsLanguageModeTitle;

  /// No description provided for @settingsLanguageModeSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Choose your preferred app language.'**
  String get settingsLanguageModeSubtitle;

  /// No description provided for @settingsLanguageModeSystemOption.
  ///
  /// In en_US, this message translates to:
  /// **'System'**
  String get settingsLanguageModeSystemOption;

  /// No description provided for @settingsLanguageModeSystemDescription.
  ///
  /// In en_US, this message translates to:
  /// **'Follow system ({language}).'**
  String settingsLanguageModeSystemDescription(Object language);

  /// No description provided for @settingsChangeEmailListTileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmailListTileTitle;

  /// No description provided for @settingsChangeEmailListTileSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Update your sign-in email address.'**
  String get settingsChangeEmailListTileSubtitle;

  /// No description provided for @settingsChangePasswordListTileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordListTileTitle;

  /// No description provided for @settingsChangePasswordListTileSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Set a new password for your account.'**
  String get settingsChangePasswordListTileSubtitle;

  /// No description provided for @settingsDeleteAccountListTileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountListTileTitle;

  /// No description provided for @settingsDeleteAccountListTileSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Permanently delete your account and data.'**
  String get settingsDeleteAccountListTileSubtitle;

  /// No description provided for @settingsChangeEmailTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmailTitle;

  /// No description provided for @settingsChangeEmailSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Enter your new email and confirm it from your inbox.'**
  String get settingsChangeEmailSubtitle;

  /// No description provided for @settingsChangeEmailCurrentEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Current email: {email}'**
  String settingsChangeEmailCurrentEmail(Object email);

  /// No description provided for @settingsChangeEmailNewEmailLabel.
  ///
  /// In en_US, this message translates to:
  /// **'New email'**
  String get settingsChangeEmailNewEmailLabel;

  /// No description provided for @settingsChangeEmailSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send confirmation email'**
  String get settingsChangeEmailSubmitButton;

  /// No description provided for @settingsChangePasswordTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordTitle;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Set a new password for your account.'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @settingsChangePasswordNewPasswordLabel.
  ///
  /// In en_US, this message translates to:
  /// **'New password'**
  String get settingsChangePasswordNewPasswordLabel;

  /// No description provided for @settingsChangePasswordSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordSubmitButton;

  /// No description provided for @settingsChangePasswordSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Your password was changed successfully.'**
  String get settingsChangePasswordSuccessMessage;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'This action is permanent and cannot be undone.'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsDeleteAccountWarningBody.
  ///
  /// In en_US, this message translates to:
  /// **'Deleting your account permanently removes your profile and access to the app.'**
  String get settingsDeleteAccountWarningBody;

  /// No description provided for @settingsDeleteAccountSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Delete my account'**
  String get settingsDeleteAccountSubmitButton;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmMessage.
  ///
  /// In en_US, this message translates to:
  /// **'This action is permanent. Do you want to continue?'**
  String get settingsDeleteAccountConfirmMessage;

  /// No description provided for @settingsDeleteAccountConfirmCancelButton.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteAccountConfirmCancelButton;

  /// No description provided for @settingsDeleteAccountConfirmDeleteButton.
  ///
  /// In en_US, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAccountConfirmDeleteButton;

  /// No description provided for @settingsDeleteAccountSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Your account was deleted.'**
  String get settingsDeleteAccountSuccessMessage;

  /// No description provided for @signUpConfirmRegistrationMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Please confirm your registration.'**
  String get signUpConfirmRegistrationMessage;

  /// No description provided for @signUpTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Sign up'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Enter your details to get started.'**
  String get signUpSubtitle;

  /// No description provided for @signUpNameLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Full name'**
  String get signUpNameLabel;

  /// No description provided for @signUpEmailLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Email'**
  String get signUpEmailLabel;

  /// No description provided for @signUpPasswordLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Password'**
  String get signUpPasswordLabel;

  /// No description provided for @signUpCreateAccountButton.
  ///
  /// In en_US, this message translates to:
  /// **'Create account'**
  String get signUpCreateAccountButton;

  /// No description provided for @verifySignInResentCodeMessage.
  ///
  /// In en_US, this message translates to:
  /// **'We sent you another code.'**
  String get verifySignInResentCodeMessage;

  /// No description provided for @verifySignInTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Verify sign-in'**
  String get verifySignInTitle;

  /// No description provided for @verifySignInInstruction.
  ///
  /// In en_US, this message translates to:
  /// **'Enter the 6-digit code sent to {email}, or open the link in your email.'**
  String verifySignInInstruction(Object email);

  /// No description provided for @verifySignInCodeLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Verification code'**
  String get verifySignInCodeLabel;

  /// No description provided for @verifySignInConfirmButton.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm'**
  String get verifySignInConfirmButton;

  /// No description provided for @verifySignInNoEmailText.
  ///
  /// In en_US, this message translates to:
  /// **'Did not receive an email?'**
  String get verifySignInNoEmailText;

  /// No description provided for @verifySignInResendCodeButton.
  ///
  /// In en_US, this message translates to:
  /// **'Resend code'**
  String get verifySignInResendCodeButton;

  /// No description provided for @verifySignUpResentCodeMessage.
  ///
  /// In en_US, this message translates to:
  /// **'We sent you another code.'**
  String get verifySignUpResentCodeMessage;

  /// No description provided for @verifySignUpTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Verify sign-up'**
  String get verifySignUpTitle;

  /// No description provided for @verifySignUpInstruction.
  ///
  /// In en_US, this message translates to:
  /// **'Enter the 6-digit code sent to {email}, or open the link in your email.'**
  String verifySignUpInstruction(Object email);

  /// No description provided for @verifySignUpCodeLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Verification code'**
  String get verifySignUpCodeLabel;

  /// No description provided for @verifySignUpConfirmButton.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm'**
  String get verifySignUpConfirmButton;

  /// No description provided for @verifySignUpNoEmailText.
  ///
  /// In en_US, this message translates to:
  /// **'Did not receive an email?'**
  String get verifySignUpNoEmailText;

  /// No description provided for @verifySignUpResendCodeButton.
  ///
  /// In en_US, this message translates to:
  /// **'Resend code'**
  String get verifySignUpResendCodeButton;

  /// No description provided for @authToastEmailChangedTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Email address changed'**
  String get authToastEmailChangedTitle;

  /// No description provided for @authToastEmailChangedMessage.
  ///
  /// In en_US, this message translates to:
  /// **'We successfully changed your email address.'**
  String get authToastEmailChangedMessage;

  /// No description provided for @authToastSignedInTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Sign-in successful'**
  String get authToastSignedInTitle;

  /// No description provided for @authToastSignedInMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You have been signed in successfully.'**
  String get authToastSignedInMessage;

  /// No description provided for @authToastSignedOutTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Sign-out successful'**
  String get authToastSignedOutTitle;

  /// No description provided for @authToastSignedOutMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You have been signed out successfully.'**
  String get authToastSignedOutMessage;

  /// No description provided for @authToastPasswordRecoveryTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Sign-in successful'**
  String get authToastPasswordRecoveryTitle;

  /// No description provided for @authToastPasswordRecoveryMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You can now change your password.'**
  String get authToastPasswordRecoveryMessage;

  /// No description provided for @homeGreetingGeneric.
  ///
  /// In en_US, this message translates to:
  /// **'Hey! 👋'**
  String get homeGreetingGeneric;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In en_US, this message translates to:
  /// **'Hey, {name}! 👋'**
  String homeGreetingWithName(Object name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'de':
      {
        switch (locale.countryCode) {
          case 'DE':
            return AppLocalizationsDeDe();
        }
        break;
      }
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
