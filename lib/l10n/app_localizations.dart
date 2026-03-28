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

  /// No description provided for @userDetailsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'User details'**
  String get userDetailsTitle;

  /// No description provided for @userDetailsFriendshipCodeLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Friendship code:'**
  String get userDetailsFriendshipCodeLabel;

  /// No description provided for @userDetailsJoinedAtLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Joined on:'**
  String get userDetailsJoinedAtLabel;

  /// No description provided for @userDetailsUpdateNameDialogTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Update name'**
  String get userDetailsUpdateNameDialogTitle;

  /// No description provided for @userDetailsUpdateNameSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Save name'**
  String get userDetailsUpdateNameSubmitButton;

  /// No description provided for @userDetailsUpdateNameSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Your name was updated.'**
  String get userDetailsUpdateNameSuccessMessage;

  /// No description provided for @userDetailsActionsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Profile actions'**
  String get userDetailsActionsTitle;

  /// No description provided for @userDetailsActionRemoveFriend.
  ///
  /// In en_US, this message translates to:
  /// **'Remove friend'**
  String get userDetailsActionRemoveFriend;

  /// No description provided for @userDetailsRemoveFriendSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Friend removed.'**
  String get userDetailsRemoveFriendSuccessMessage;

  /// No description provided for @userDetailsMemesTabAll.
  ///
  /// In en_US, this message translates to:
  /// **'All'**
  String get userDetailsMemesTabAll;

  /// No description provided for @userDetailsMemesTabSent.
  ///
  /// In en_US, this message translates to:
  /// **'Sent'**
  String get userDetailsMemesTabSent;

  /// No description provided for @userDetailsMemesTabReceived.
  ///
  /// In en_US, this message translates to:
  /// **'Received'**
  String get userDetailsMemesTabReceived;

  /// No description provided for @userDetailsOwnAllMemesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes yet.'**
  String get userDetailsOwnAllMemesEmpty;

  /// No description provided for @userDetailsOwnSentMemesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'You haven\'\'t created memes yet.'**
  String get userDetailsOwnSentMemesEmpty;

  /// No description provided for @userDetailsOwnReceivedMemesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes received yet.'**
  String get userDetailsOwnReceivedMemesEmpty;

  /// No description provided for @userDetailsOtherAllMemesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes exchanged yet.'**
  String get userDetailsOtherAllMemesEmpty;

  /// No description provided for @userDetailsOtherSentMemesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes sent to this user yet.'**
  String get userDetailsOtherSentMemesEmpty;

  /// No description provided for @userDetailsOtherReceivedMemesEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes received from this user yet.'**
  String get userDetailsOtherReceivedMemesEmpty;

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

  /// No description provided for @friendshipsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search friendships'**
  String get friendshipsSearchLabel;

  /// No description provided for @friendshipsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get friendshipsSearchHint;

  /// No description provided for @friendshipsRequestsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search requests'**
  String get friendshipsRequestsSearchLabel;

  /// No description provided for @friendshipsRequestsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get friendshipsRequestsSearchHint;

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

  /// No description provided for @groupsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @groupsTabGroups.
  ///
  /// In en_US, this message translates to:
  /// **'Groups'**
  String get groupsTabGroups;

  /// No description provided for @groupsTabInvitations.
  ///
  /// In en_US, this message translates to:
  /// **'Invitations'**
  String get groupsTabInvitations;

  /// No description provided for @groupsListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'You are not in any groups yet.'**
  String get groupsListEmpty;

  /// No description provided for @groupsInvitationsListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No pending group invitations.'**
  String get groupsInvitationsListEmpty;

  /// No description provided for @groupsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search groups'**
  String get groupsSearchLabel;

  /// No description provided for @groupsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get groupsSearchHint;

  /// No description provided for @groupsInvitationsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search invitations'**
  String get groupsInvitationsSearchLabel;

  /// No description provided for @groupsInvitationsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get groupsInvitationsSearchHint;

  /// No description provided for @groupsMemberCount.
  ///
  /// In en_US, this message translates to:
  /// **'{count} members'**
  String groupsMemberCount(Object count);

  /// No description provided for @groupsInvitationFrom.
  ///
  /// In en_US, this message translates to:
  /// **'From {sender_name} ({sender_friendship_code})'**
  String groupsInvitationFrom(
    Object sender_name,
    Object sender_friendship_code,
  );

  /// No description provided for @groupsInvitationAcceptSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Invitation accepted.'**
  String get groupsInvitationAcceptSuccessMessage;

  /// No description provided for @groupsInvitationRejectSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Invitation rejected.'**
  String get groupsInvitationRejectSuccessMessage;

  /// No description provided for @groupsCreateNameTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Create a group'**
  String get groupsCreateNameTitle;

  /// No description provided for @groupsCreateNameSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Choose a name for your group.'**
  String get groupsCreateNameSubtitle;

  /// No description provided for @groupsCreateNameFieldLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Group name'**
  String get groupsCreateNameFieldLabel;

  /// No description provided for @groupsCreateNameFieldHint.
  ///
  /// In en_US, this message translates to:
  /// **'Weekend Legends'**
  String get groupsCreateNameFieldHint;

  /// No description provided for @groupsCreateNameContinueButton.
  ///
  /// In en_US, this message translates to:
  /// **'Continue'**
  String get groupsCreateNameContinueButton;

  /// No description provided for @groupsCreateMembersTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Invite members'**
  String get groupsCreateMembersTitle;

  /// No description provided for @groupsCreateMembersSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'{count} selected'**
  String groupsCreateMembersSubtitle(Object count);

  /// No description provided for @groupsCreateMembersSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search friends'**
  String get groupsCreateMembersSearchLabel;

  /// No description provided for @groupsCreateMembersSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get groupsCreateMembersSearchHint;

  /// No description provided for @groupsCreateMembersSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Create group'**
  String get groupsCreateMembersSubmitButton;

  /// No description provided for @groupsCreateSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Group created successfully.'**
  String get groupsCreateSuccessMessage;

  /// No description provided for @groupDetailsTabAllMemes.
  ///
  /// In en_US, this message translates to:
  /// **'All'**
  String get groupDetailsTabAllMemes;

  /// No description provided for @groupDetailsTabSentByMe.
  ///
  /// In en_US, this message translates to:
  /// **'Sent by me'**
  String get groupDetailsTabSentByMe;

  /// No description provided for @groupDetailsMemesAllEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes sent to this group yet.'**
  String get groupDetailsMemesAllEmpty;

  /// No description provided for @groupDetailsMemesSentByMeEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'You have not sent memes to this group yet.'**
  String get groupDetailsMemesSentByMeEmpty;

  /// No description provided for @groupDetailsInfoTabMembers.
  ///
  /// In en_US, this message translates to:
  /// **'Members'**
  String get groupDetailsInfoTabMembers;

  /// No description provided for @groupDetailsInfoTabInvitations.
  ///
  /// In en_US, this message translates to:
  /// **'Invitations'**
  String get groupDetailsInfoTabInvitations;

  /// No description provided for @groupDetailsMembersEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No members found.'**
  String get groupDetailsMembersEmpty;

  /// No description provided for @groupDetailsMembersSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search members'**
  String get groupDetailsMembersSearchLabel;

  /// No description provided for @groupDetailsMembersSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get groupDetailsMembersSearchHint;

  /// No description provided for @groupDetailsPendingInvitationsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No pending invitations.'**
  String get groupDetailsPendingInvitationsEmpty;

  /// No description provided for @groupDetailsInvitationsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search invitations'**
  String get groupDetailsInvitationsSearchLabel;

  /// No description provided for @groupDetailsInvitationsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get groupDetailsInvitationsSearchHint;

  /// No description provided for @groupDetailsMemberRoleCreator.
  ///
  /// In en_US, this message translates to:
  /// **'Creator'**
  String get groupDetailsMemberRoleCreator;

  /// No description provided for @groupDetailsMemberRoleAdmin.
  ///
  /// In en_US, this message translates to:
  /// **'Admin'**
  String get groupDetailsMemberRoleAdmin;

  /// No description provided for @groupDetailsMemberRoleMember.
  ///
  /// In en_US, this message translates to:
  /// **'Member'**
  String get groupDetailsMemberRoleMember;

  /// No description provided for @groupDetailsInviteMembersDialogTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Invite members'**
  String get groupDetailsInviteMembersDialogTitle;

  /// No description provided for @groupDetailsInviteMembersSelected.
  ///
  /// In en_US, this message translates to:
  /// **'{count} selected'**
  String groupDetailsInviteMembersSelected(Object count);

  /// No description provided for @groupDetailsInviteMembersSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send invitations'**
  String get groupDetailsInviteMembersSubmitButton;

  /// No description provided for @groupDetailsInviteMembersEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No friends available to invite.'**
  String get groupDetailsInviteMembersEmpty;

  /// No description provided for @groupDetailsInviteMembersSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search friends'**
  String get groupDetailsInviteMembersSearchLabel;

  /// No description provided for @groupDetailsInviteMembersSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get groupDetailsInviteMembersSearchHint;

  /// No description provided for @groupDetailsInviteMembersSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Invitations sent.'**
  String get groupDetailsInviteMembersSuccessMessage;

  /// No description provided for @groupDetailsMemberActionsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Member actions'**
  String get groupDetailsMemberActionsTitle;

  /// No description provided for @groupDetailsMemberActionPromoteToAdmin.
  ///
  /// In en_US, this message translates to:
  /// **'Make admin'**
  String get groupDetailsMemberActionPromoteToAdmin;

  /// No description provided for @groupDetailsMemberActionDemoteToMember.
  ///
  /// In en_US, this message translates to:
  /// **'Remove admin privileges'**
  String get groupDetailsMemberActionDemoteToMember;

  /// No description provided for @groupDetailsMemberActionRemove.
  ///
  /// In en_US, this message translates to:
  /// **'Remove member'**
  String get groupDetailsMemberActionRemove;

  /// No description provided for @groupDetailsGroupActionsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Group actions'**
  String get groupDetailsGroupActionsTitle;

  /// No description provided for @groupDetailsGroupActionLeave.
  ///
  /// In en_US, this message translates to:
  /// **'Leave group'**
  String get groupDetailsGroupActionLeave;

  /// No description provided for @groupDetailsGroupActionDelete.
  ///
  /// In en_US, this message translates to:
  /// **'Delete group'**
  String get groupDetailsGroupActionDelete;

  /// No description provided for @groupDetailsMemberRoleUpdateSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Member role updated.'**
  String get groupDetailsMemberRoleUpdateSuccessMessage;

  /// No description provided for @groupDetailsUpdateNameDialogTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Update group name'**
  String get groupDetailsUpdateNameDialogTitle;

  /// No description provided for @groupDetailsUpdateNameSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Save group name'**
  String get groupDetailsUpdateNameSubmitButton;

  /// No description provided for @groupDetailsUpdateNameSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Group name updated.'**
  String get groupDetailsUpdateNameSuccessMessage;

  /// No description provided for @groupDetailsMemberRemoveSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Member removed.'**
  String get groupDetailsMemberRemoveSuccessMessage;

  /// No description provided for @groupDetailsInvitationCancelSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Invitation canceled.'**
  String get groupDetailsInvitationCancelSuccessMessage;

  /// No description provided for @groupDetailsLeaveSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You left the group.'**
  String get groupDetailsLeaveSuccessMessage;

  /// No description provided for @groupDetailsDeleteSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Group deleted.'**
  String get groupDetailsDeleteSuccessMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search notifications'**
  String get notificationsSearchLabel;

  /// No description provided for @notificationsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get notificationsSearchHint;

  /// No description provided for @notificationsListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsListEmpty;

  /// No description provided for @mainShellTabFeed.
  ///
  /// In en_US, this message translates to:
  /// **'Feed'**
  String get mainShellTabFeed;

  /// No description provided for @mainShellTabFriendships.
  ///
  /// In en_US, this message translates to:
  /// **'Friends'**
  String get mainShellTabFriendships;

  /// No description provided for @mainShellTabGroups.
  ///
  /// In en_US, this message translates to:
  /// **'Groups'**
  String get mainShellTabGroups;

  /// No description provided for @feedListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No memes in your feed yet.'**
  String get feedListEmpty;

  /// No description provided for @memeDetailsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Meme details'**
  String get memeDetailsTitle;

  /// No description provided for @memeDetailsLaughsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Who laughed?'**
  String get memeDetailsLaughsTitle;

  /// No description provided for @memeDetailsLaughsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No laughs yet.'**
  String get memeDetailsLaughsEmpty;

  /// No description provided for @memeDetailsActionsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Meme actions'**
  String get memeDetailsActionsTitle;

  /// No description provided for @memeDetailsActionDelete.
  ///
  /// In en_US, this message translates to:
  /// **'Delete meme'**
  String get memeDetailsActionDelete;

  /// No description provided for @memeDetailsDeleteSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Meme deleted.'**
  String get memeDetailsDeleteSuccessMessage;

  /// No description provided for @memeDetailsTabDetails.
  ///
  /// In en_US, this message translates to:
  /// **'Details'**
  String get memeDetailsTabDetails;

  /// No description provided for @memeDetailsTabRecipients.
  ///
  /// In en_US, this message translates to:
  /// **'Recipients'**
  String get memeDetailsTabRecipients;

  /// No description provided for @memeDetailsRecipientsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No recipients yet.'**
  String get memeDetailsRecipientsEmpty;

  /// No description provided for @memeDetailsAddRecipientsButton.
  ///
  /// In en_US, this message translates to:
  /// **'Add recipients'**
  String get memeDetailsAddRecipientsButton;

  /// No description provided for @memeDetailsRecipientRemoveSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Recipient removed.'**
  String get memeDetailsRecipientRemoveSuccessMessage;

  /// No description provided for @memeDetailsAddRecipientsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Add recipients'**
  String get memeDetailsAddRecipientsTitle;

  /// No description provided for @memeDetailsAddRecipientsSelected.
  ///
  /// In en_US, this message translates to:
  /// **'{count} selected'**
  String memeDetailsAddRecipientsSelected(Object count);

  /// No description provided for @memeDetailsAddRecipientsEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No addable recipients found.'**
  String get memeDetailsAddRecipientsEmpty;

  /// No description provided for @memeDetailsAddRecipientsSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Add selected'**
  String get memeDetailsAddRecipientsSubmitButton;

  /// No description provided for @memeDetailsRecipientsAddSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Recipients added.'**
  String get memeDetailsRecipientsAddSuccessMessage;

  /// No description provided for @notificationsItemFriendshipRequestSentTitle.
  ///
  /// In en_US, this message translates to:
  /// **'New friendship request'**
  String get notificationsItemFriendshipRequestSentTitle;

  /// No description provided for @notificationsItemFriendshipRequestSent.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} sent you a friendship request.'**
  String notificationsItemFriendshipRequestSent(Object sender_name);

  /// No description provided for @notificationsItemFriendshipRequestAcceptedTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Friendship request accepted'**
  String get notificationsItemFriendshipRequestAcceptedTitle;

  /// No description provided for @notificationsItemFriendshipRequestAccepted.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} accepted your friendship request.'**
  String notificationsItemFriendshipRequestAccepted(Object sender_name);

  /// No description provided for @notificationsItemGroupInvitationSentTitle.
  ///
  /// In en_US, this message translates to:
  /// **'New group invitation'**
  String get notificationsItemGroupInvitationSentTitle;

  /// No description provided for @notificationsItemGroupInvitationSent.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} invited you to join {group_name}.'**
  String notificationsItemGroupInvitationSent(
    Object sender_name,
    Object group_name,
  );

  /// No description provided for @notificationsItemMemeReceivedTitle.
  ///
  /// In en_US, this message translates to:
  /// **'New meme received'**
  String get notificationsItemMemeReceivedTitle;

  /// No description provided for @notificationsItemMemeReceived.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} sent you a meme.'**
  String notificationsItemMemeReceived(Object sender_name);

  /// No description provided for @notificationsItemMemeReceivedDirect.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} sent a meme to you.'**
  String notificationsItemMemeReceivedDirect(Object sender_name);

  /// No description provided for @notificationsItemMemeReceivedGroup.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} sent a meme to {group_name}.'**
  String notificationsItemMemeReceivedGroup(
    Object sender_name,
    Object group_name,
  );

  /// No description provided for @notificationsItemMemeLaughedTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Your meme got a laugh'**
  String get notificationsItemMemeLaughedTitle;

  /// No description provided for @notificationsItemMemeLaughed.
  ///
  /// In en_US, this message translates to:
  /// **'{sender_name} laughed at your meme.'**
  String notificationsItemMemeLaughed(Object sender_name);

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

  /// No description provided for @memeEditorCanvasSelectTemplateHint.
  ///
  /// In en_US, this message translates to:
  /// **'Select a meme template.'**
  String get memeEditorCanvasSelectTemplateHint;

  /// No description provided for @memeEditorTextBackgroundEnable.
  ///
  /// In en_US, this message translates to:
  /// **'Enable text outline'**
  String get memeEditorTextBackgroundEnable;

  /// No description provided for @memeEditorTextBackgroundDisable.
  ///
  /// In en_US, this message translates to:
  /// **'Disable text outline'**
  String get memeEditorTextBackgroundDisable;

  /// No description provided for @memeEditorDeleteTargetSemanticsLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Delete text'**
  String get memeEditorDeleteTargetSemanticsLabel;

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

  /// No description provided for @sendMemeRecipientsListEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'No recipients available.'**
  String get sendMemeRecipientsListEmpty;

  /// No description provided for @sendMemeRecipientsSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search recipients'**
  String get sendMemeRecipientsSearchLabel;

  /// No description provided for @sendMemeRecipientsSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name'**
  String get sendMemeRecipientsSearchHint;

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

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en_US, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// No description provided for @settingsBlockedUsersTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Blocked users'**
  String get settingsBlockedUsersTitle;

  /// No description provided for @settingsBlockedUsersSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Manage users you have blocked.'**
  String get settingsBlockedUsersSubtitle;

  /// No description provided for @settingsBlockedUsersSearchLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Search blocked users'**
  String get settingsBlockedUsersSearchLabel;

  /// No description provided for @settingsBlockedUsersSearchHint.
  ///
  /// In en_US, this message translates to:
  /// **'Search by name or friendship code'**
  String get settingsBlockedUsersSearchHint;

  /// No description provided for @settingsBlockedUsersEmpty.
  ///
  /// In en_US, this message translates to:
  /// **'You have not blocked any users.'**
  String get settingsBlockedUsersEmpty;

  /// No description provided for @settingsBlockedUsersActionsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Blocked user actions'**
  String get settingsBlockedUsersActionsTitle;

  /// No description provided for @languageModeTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Language mode'**
  String get languageModeTitle;

  /// No description provided for @languageModeSystemOption.
  ///
  /// In en_US, this message translates to:
  /// **'System'**
  String get languageModeSystemOption;

  /// No description provided for @languageModeSystemDescription.
  ///
  /// In en_US, this message translates to:
  /// **'Follow system ({language}).'**
  String languageModeSystemDescription(Object language);

  /// No description provided for @changeEmailListTileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change email'**
  String get changeEmailListTileTitle;

  /// No description provided for @changeEmailListTileSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Update your sign-in email address.'**
  String get changeEmailListTileSubtitle;

  /// No description provided for @changePasswordListTileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change password'**
  String get changePasswordListTileTitle;

  /// No description provided for @changePasswordListTileSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Set a new password for your account.'**
  String get changePasswordListTileSubtitle;

  /// No description provided for @deleteAccountListTileTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account'**
  String get deleteAccountListTileTitle;

  /// No description provided for @deleteAccountListTileSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Permanently delete your account and data.'**
  String get deleteAccountListTileSubtitle;

  /// No description provided for @settingsLegalPrivacyTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Privacy'**
  String get settingsLegalPrivacyTitle;

  /// No description provided for @settingsLegalPrivacySubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Read the privacy policy.'**
  String get settingsLegalPrivacySubtitle;

  /// No description provided for @settingsLegalTermsTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Terms of Use'**
  String get settingsLegalTermsTitle;

  /// No description provided for @settingsLegalTermsSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Read the terms of use.'**
  String get settingsLegalTermsSubtitle;

  /// No description provided for @settingsLegalCommunityTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Community Guidelines'**
  String get settingsLegalCommunityTitle;

  /// No description provided for @settingsLegalCommunitySubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Read community behavior rules.'**
  String get settingsLegalCommunitySubtitle;

  /// No description provided for @settingsLegalAccountDeletionHelpSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Open account deletion instructions.'**
  String get settingsLegalAccountDeletionHelpSubtitle;

  /// No description provided for @settingsLegalImpressumTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Impressum / Legal notice'**
  String get settingsLegalImpressumTitle;

  /// No description provided for @settingsLegalImpressumSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'View provider and legal notice details.'**
  String get settingsLegalImpressumSubtitle;

  /// No description provided for @settingsLegalSupportTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Support'**
  String get settingsLegalSupportTitle;

  /// No description provided for @settingsLegalSupportSubtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Open support and moderation contact details.'**
  String get settingsLegalSupportSubtitle;

  /// No description provided for @changeEmailTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change email'**
  String get changeEmailTitle;

  /// No description provided for @changeEmailCurrentEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Current email: {email}'**
  String changeEmailCurrentEmail(Object email);

  /// No description provided for @changeEmailNewEmailLabel.
  ///
  /// In en_US, this message translates to:
  /// **'New email'**
  String get changeEmailNewEmailLabel;

  /// No description provided for @changeEmailSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send confirmation email'**
  String get changeEmailSubmitButton;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordNewPasswordLabel.
  ///
  /// In en_US, this message translates to:
  /// **'New password'**
  String get changePasswordNewPasswordLabel;

  /// No description provided for @changePasswordSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Change password'**
  String get changePasswordSubmitButton;

  /// No description provided for @changePasswordSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Your password was changed successfully.'**
  String get changePasswordSuccessMessage;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarningBody.
  ///
  /// In en_US, this message translates to:
  /// **'Deleting your account permanently removes your profile and access to the app.'**
  String get deleteAccountWarningBody;

  /// No description provided for @deleteAccountSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountSubmitButton;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en_US, this message translates to:
  /// **'This action is permanent. Do you want to continue?'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteAccountConfirmCancelButton.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel'**
  String get deleteAccountConfirmCancelButton;

  /// No description provided for @deleteAccountConfirmDeleteButton.
  ///
  /// In en_US, this message translates to:
  /// **'Delete'**
  String get deleteAccountConfirmDeleteButton;

  /// No description provided for @deleteAccountSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Your account was deleted.'**
  String get deleteAccountSuccessMessage;

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

  /// No description provided for @signUpLegalConsentPrefix.
  ///
  /// In en_US, this message translates to:
  /// **'I agree to the'**
  String get signUpLegalConsentPrefix;

  /// No description provided for @signUpLegalConsentAnd.
  ///
  /// In en_US, this message translates to:
  /// **'and'**
  String get signUpLegalConsentAnd;

  /// No description provided for @signUpLegalTermsLink.
  ///
  /// In en_US, this message translates to:
  /// **'Terms of Use'**
  String get signUpLegalTermsLink;

  /// No description provided for @signUpLegalPrivacyLink.
  ///
  /// In en_US, this message translates to:
  /// **'Privacy Policy'**
  String get signUpLegalPrivacyLink;

  /// No description provided for @signUpCreateAccountButton.
  ///
  /// In en_US, this message translates to:
  /// **'Create account'**
  String get signUpCreateAccountButton;

  /// No description provided for @moderationActionReportUser.
  ///
  /// In en_US, this message translates to:
  /// **'Report user'**
  String get moderationActionReportUser;

  /// No description provided for @moderationActionReportMeme.
  ///
  /// In en_US, this message translates to:
  /// **'Report meme'**
  String get moderationActionReportMeme;

  /// No description provided for @moderationActionReportGroup.
  ///
  /// In en_US, this message translates to:
  /// **'Report group'**
  String get moderationActionReportGroup;

  /// No description provided for @moderationActionBlockUser.
  ///
  /// In en_US, this message translates to:
  /// **'Block user'**
  String get moderationActionBlockUser;

  /// No description provided for @moderationActionUnblockUser.
  ///
  /// In en_US, this message translates to:
  /// **'Unblock user'**
  String get moderationActionUnblockUser;

  /// No description provided for @moderationReportDialogTitleUser.
  ///
  /// In en_US, this message translates to:
  /// **'Report this user'**
  String get moderationReportDialogTitleUser;

  /// No description provided for @moderationReportDialogTitleMeme.
  ///
  /// In en_US, this message translates to:
  /// **'Report this meme'**
  String get moderationReportDialogTitleMeme;

  /// No description provided for @moderationReportDialogTitleGroup.
  ///
  /// In en_US, this message translates to:
  /// **'Report this group'**
  String get moderationReportDialogTitleGroup;

  /// No description provided for @moderationReportReasonLabel.
  ///
  /// In en_US, this message translates to:
  /// **'Reason'**
  String get moderationReportReasonLabel;

  /// No description provided for @moderationReportReasonSpam.
  ///
  /// In en_US, this message translates to:
  /// **'Spam'**
  String get moderationReportReasonSpam;

  /// No description provided for @moderationReportReasonHarassment.
  ///
  /// In en_US, this message translates to:
  /// **'Harassment'**
  String get moderationReportReasonHarassment;

  /// No description provided for @moderationReportReasonHateSpeech.
  ///
  /// In en_US, this message translates to:
  /// **'Hate speech'**
  String get moderationReportReasonHateSpeech;

  /// No description provided for @moderationReportReasonSexualContent.
  ///
  /// In en_US, this message translates to:
  /// **'Sexual content'**
  String get moderationReportReasonSexualContent;

  /// No description provided for @moderationReportReasonViolence.
  ///
  /// In en_US, this message translates to:
  /// **'Violence'**
  String get moderationReportReasonViolence;

  /// No description provided for @moderationReportReasonScam.
  ///
  /// In en_US, this message translates to:
  /// **'Scam'**
  String get moderationReportReasonScam;

  /// No description provided for @moderationReportReasonOther.
  ///
  /// In en_US, this message translates to:
  /// **'Other'**
  String get moderationReportReasonOther;

  /// No description provided for @moderationReportReasonRequiredMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Please provide a report reason.'**
  String get moderationReportReasonRequiredMessage;

  /// No description provided for @moderationReportCancelButton.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel'**
  String get moderationReportCancelButton;

  /// No description provided for @moderationReportSubmitButton.
  ///
  /// In en_US, this message translates to:
  /// **'Send report'**
  String get moderationReportSubmitButton;

  /// No description provided for @moderationReportSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Report submitted.'**
  String get moderationReportSuccessMessage;

  /// No description provided for @moderationBlockSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'User blocked.'**
  String get moderationBlockSuccessMessage;

  /// No description provided for @moderationUnblockSuccessMessage.
  ///
  /// In en_US, this message translates to:
  /// **'User unblocked.'**
  String get moderationUnblockSuccessMessage;

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

  /// No description provided for @verifySignInConfirmButton.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm'**
  String get verifySignInConfirmButton;

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

  /// No description provided for @verifySignUpConfirmButton.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm'**
  String get verifySignUpConfirmButton;

  /// No description provided for @verifySignUpResendCodeButton.
  ///
  /// In en_US, this message translates to:
  /// **'Resend code'**
  String get verifySignUpResendCodeButton;

  /// No description provided for @authToastEmailChangedMessage.
  ///
  /// In en_US, this message translates to:
  /// **'We successfully changed your email address.'**
  String get authToastEmailChangedMessage;

  /// No description provided for @authToastSignedInMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You have been signed in successfully.'**
  String get authToastSignedInMessage;

  /// No description provided for @authToastSignedOutMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You have been signed out successfully.'**
  String get authToastSignedOutMessage;

  /// No description provided for @authToastPasswordRecoveryMessage.
  ///
  /// In en_US, this message translates to:
  /// **'You can now change your password.'**
  String get authToastPasswordRecoveryMessage;

  /// Android notification channel title shown in system settings.
  ///
  /// In en_US, this message translates to:
  /// **'Memuno notifications'**
  String get pushNotificationChannelName;

  /// Android notification channel description shown in system settings.
  ///
  /// In en_US, this message translates to:
  /// **'General notifications for the Memuno app.'**
  String get pushNotificationChannelDescription;

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
