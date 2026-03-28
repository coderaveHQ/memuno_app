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
  String get userDetailsTitle => 'User details';

  @override
  String get userDetailsFriendshipCodeLabel => 'Friendship code:';

  @override
  String get userDetailsJoinedAtLabel => 'Joined on:';

  @override
  String get userDetailsUpdateNameDialogTitle => 'Update name';

  @override
  String get userDetailsUpdateNameSubmitButton => 'Save name';

  @override
  String get userDetailsUpdateNameSuccessMessage => 'Your name was updated.';

  @override
  String get userDetailsActionsTitle => 'Profile actions';

  @override
  String get userDetailsActionRemoveFriend => 'Remove friend';

  @override
  String get userDetailsRemoveFriendSuccessMessage => 'Friend removed.';

  @override
  String get userDetailsMemesTabAll => 'All';

  @override
  String get userDetailsMemesTabSent => 'Sent';

  @override
  String get userDetailsMemesTabReceived => 'Received';

  @override
  String get userDetailsOwnAllMemesEmpty => 'No memes yet.';

  @override
  String get userDetailsOwnSentMemesEmpty => 'You haven\'t created memes yet.';

  @override
  String get userDetailsOwnReceivedMemesEmpty => 'No memes received yet.';

  @override
  String get userDetailsOtherAllMemesEmpty => 'No memes exchanged yet.';

  @override
  String get userDetailsOtherSentMemesEmpty =>
      'No memes sent to this user yet.';

  @override
  String get userDetailsOtherReceivedMemesEmpty =>
      'No memes received from this user yet.';

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
  String get friendshipsSearchLabel => 'Search friendships';

  @override
  String get friendshipsSearchHint => 'Search by name';

  @override
  String get friendshipsRequestsSearchLabel => 'Search requests';

  @override
  String get friendshipsRequestsSearchHint => 'Search by name';

  @override
  String get friendshipsFriendsSincePrefix => 'Friends since';

  @override
  String get friendshipsRequestDirectionIncoming => 'Incoming';

  @override
  String get friendshipsRequestDirectionOutgoing => 'Outgoing';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsTabGroups => 'Groups';

  @override
  String get groupsTabInvitations => 'Invitations';

  @override
  String get groupsListEmpty => 'You are not in any groups yet.';

  @override
  String get groupsInvitationsListEmpty => 'No pending group invitations.';

  @override
  String get groupsSearchLabel => 'Search groups';

  @override
  String get groupsSearchHint => 'Search by name';

  @override
  String get groupsInvitationsSearchLabel => 'Search invitations';

  @override
  String get groupsInvitationsSearchHint => 'Search by name';

  @override
  String groupsMemberCount(Object count) {
    return '$count members';
  }

  @override
  String groupsInvitationFrom(
    Object sender_name,
    Object sender_friendship_code,
  ) {
    return 'From $sender_name ($sender_friendship_code)';
  }

  @override
  String get groupsInvitationAcceptSuccessMessage => 'Invitation accepted.';

  @override
  String get groupsInvitationRejectSuccessMessage => 'Invitation rejected.';

  @override
  String get groupsCreateNameTitle => 'Create a group';

  @override
  String get groupsCreateNameSubtitle => 'Choose a name for your group.';

  @override
  String get groupsCreateNameFieldLabel => 'Group name';

  @override
  String get groupsCreateNameFieldHint => 'Weekend Legends';

  @override
  String get groupsCreateNameContinueButton => 'Continue';

  @override
  String get groupsCreateMembersTitle => 'Invite members';

  @override
  String groupsCreateMembersSubtitle(Object count) {
    return '$count selected';
  }

  @override
  String get groupsCreateMembersSearchLabel => 'Search friends';

  @override
  String get groupsCreateMembersSearchHint => 'Search by name';

  @override
  String get groupsCreateMembersSubmitButton => 'Create group';

  @override
  String get groupsCreateSuccessMessage => 'Group created successfully.';

  @override
  String get groupDetailsTabAllMemes => 'All';

  @override
  String get groupDetailsTabSentByMe => 'Sent by me';

  @override
  String get groupDetailsMemesAllEmpty => 'No memes sent to this group yet.';

  @override
  String get groupDetailsMemesSentByMeEmpty =>
      'You have not sent memes to this group yet.';

  @override
  String get groupDetailsInfoTabMembers => 'Members';

  @override
  String get groupDetailsInfoTabInvitations => 'Invitations';

  @override
  String get groupDetailsMembersEmpty => 'No members found.';

  @override
  String get groupDetailsMembersSearchLabel => 'Search members';

  @override
  String get groupDetailsMembersSearchHint => 'Search by name';

  @override
  String get groupDetailsPendingInvitationsEmpty => 'No pending invitations.';

  @override
  String get groupDetailsInvitationsSearchLabel => 'Search invitations';

  @override
  String get groupDetailsInvitationsSearchHint => 'Search by name';

  @override
  String get groupDetailsMemberRoleCreator => 'Creator';

  @override
  String get groupDetailsMemberRoleAdmin => 'Admin';

  @override
  String get groupDetailsMemberRoleMember => 'Member';

  @override
  String get groupDetailsInviteMembersDialogTitle => 'Invite members';

  @override
  String groupDetailsInviteMembersSelected(Object count) {
    return '$count selected';
  }

  @override
  String get groupDetailsInviteMembersSubmitButton => 'Send invitations';

  @override
  String get groupDetailsInviteMembersEmpty =>
      'No friends available to invite.';

  @override
  String get groupDetailsInviteMembersSearchLabel => 'Search friends';

  @override
  String get groupDetailsInviteMembersSearchHint => 'Search by name';

  @override
  String get groupDetailsInviteMembersSuccessMessage => 'Invitations sent.';

  @override
  String get groupDetailsMemberActionsTitle => 'Member actions';

  @override
  String get groupDetailsMemberActionPromoteToAdmin => 'Make admin';

  @override
  String get groupDetailsMemberActionDemoteToMember =>
      'Remove admin privileges';

  @override
  String get groupDetailsMemberActionRemove => 'Remove member';

  @override
  String get groupDetailsGroupActionsTitle => 'Group actions';

  @override
  String get groupDetailsGroupActionLeave => 'Leave group';

  @override
  String get groupDetailsGroupActionDelete => 'Delete group';

  @override
  String get groupDetailsMemberRoleUpdateSuccessMessage =>
      'Member role updated.';

  @override
  String get groupDetailsUpdateNameDialogTitle => 'Update group name';

  @override
  String get groupDetailsUpdateNameSubmitButton => 'Save group name';

  @override
  String get groupDetailsUpdateNameSuccessMessage => 'Group name updated.';

  @override
  String get groupDetailsMemberRemoveSuccessMessage => 'Member removed.';

  @override
  String get groupDetailsInvitationCancelSuccessMessage =>
      'Invitation canceled.';

  @override
  String get groupDetailsLeaveSuccessMessage => 'You left the group.';

  @override
  String get groupDetailsDeleteSuccessMessage => 'Group deleted.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSearchLabel => 'Search notifications';

  @override
  String get notificationsSearchHint => 'Search by name';

  @override
  String get notificationsListEmpty => 'No notifications yet.';

  @override
  String get mainShellTabFeed => 'Feed';

  @override
  String get mainShellTabFriendships => 'Friends';

  @override
  String get mainShellTabGroups => 'Groups';

  @override
  String get feedListEmpty => 'No memes in your feed yet.';

  @override
  String get memeDetailsTitle => 'Meme details';

  @override
  String get memeDetailsLaughsTitle => 'Who laughed?';

  @override
  String get memeDetailsLaughsEmpty => 'No laughs yet.';

  @override
  String get memeDetailsActionsTitle => 'Meme actions';

  @override
  String get memeDetailsActionDelete => 'Delete meme';

  @override
  String get memeDetailsDeleteSuccessMessage => 'Meme deleted.';

  @override
  String get memeDetailsTabDetails => 'Details';

  @override
  String get memeDetailsTabRecipients => 'Recipients';

  @override
  String get memeDetailsRecipientsEmpty => 'No recipients yet.';

  @override
  String get memeDetailsAddRecipientsButton => 'Add recipients';

  @override
  String get memeDetailsRecipientRemoveSuccessMessage => 'Recipient removed.';

  @override
  String get memeDetailsAddRecipientsTitle => 'Add recipients';

  @override
  String memeDetailsAddRecipientsSelected(Object count) {
    return '$count selected';
  }

  @override
  String get memeDetailsAddRecipientsEmpty => 'No addable recipients found.';

  @override
  String get memeDetailsAddRecipientsSubmitButton => 'Add selected';

  @override
  String get memeDetailsRecipientsAddSuccessMessage => 'Recipients added.';

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
  String get notificationsItemGroupInvitationSentTitle =>
      'New group invitation';

  @override
  String notificationsItemGroupInvitationSent(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name invited you to join $group_name.';
  }

  @override
  String get notificationsItemMemeReceivedTitle => 'New meme received';

  @override
  String notificationsItemMemeReceived(Object sender_name) {
    return '$sender_name sent you a meme.';
  }

  @override
  String notificationsItemMemeReceivedDirect(Object sender_name) {
    return '$sender_name sent a meme to you.';
  }

  @override
  String notificationsItemMemeReceivedGroup(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name sent a meme to $group_name.';
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
  String get memeEditorTitle => 'New meme';

  @override
  String get memeEditorCanvasSelectTemplateHint => 'Select a meme template.';

  @override
  String get memeEditorTextBackgroundEnable => 'Enable text outline';

  @override
  String get memeEditorTextBackgroundDisable => 'Disable text outline';

  @override
  String get memeEditorDeleteTargetSemanticsLabel => 'Delete text';

  @override
  String get memeEditorRenderError => 'Unable to render meme editor output.';

  @override
  String get memeEditorPngEncodeError => 'Unable to convert meme to PNG bytes.';

  @override
  String get sendMemeTitle => 'Send meme';

  @override
  String get sendMemeSubmitButton => 'Send';

  @override
  String get sendMemeRecipientsListEmpty => 'No recipients available.';

  @override
  String get sendMemeRecipientsSearchLabel => 'Search recipients';

  @override
  String get sendMemeRecipientsSearchHint => 'Search by name';

  @override
  String get sendMemeSuccessMessage => 'Meme sent successfully.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAccountManagement => 'Account management';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsBlockedUsersTitle => 'Blocked users';

  @override
  String get settingsBlockedUsersSubtitle => 'Manage users you have blocked.';

  @override
  String get settingsBlockedUsersSearchLabel => 'Search blocked users';

  @override
  String get settingsBlockedUsersSearchHint =>
      'Search by name or friendship code';

  @override
  String get settingsBlockedUsersEmpty => 'You have not blocked any users.';

  @override
  String get settingsBlockedUsersActionsTitle => 'Blocked user actions';

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
  String get settingsLegalPrivacyTitle => 'Privacy';

  @override
  String get settingsLegalPrivacySubtitle => 'Read the privacy policy.';

  @override
  String get settingsLegalTermsTitle => 'Terms of Use';

  @override
  String get settingsLegalTermsSubtitle => 'Read the terms of use.';

  @override
  String get settingsLegalCommunityTitle => 'Community Guidelines';

  @override
  String get settingsLegalCommunitySubtitle => 'Read community behavior rules.';

  @override
  String get settingsLegalAccountDeletionHelpSubtitle =>
      'Open account deletion instructions.';

  @override
  String get settingsLegalImpressumTitle => 'Impressum / Legal notice';

  @override
  String get settingsLegalImpressumSubtitle =>
      'View provider and legal notice details.';

  @override
  String get settingsLegalSupportTitle => 'Support';

  @override
  String get settingsLegalSupportSubtitle =>
      'Open support and moderation contact details.';

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
  String get signUpLegalConsentPrefix => 'I agree to the';

  @override
  String get signUpLegalConsentAnd => 'and';

  @override
  String get signUpLegalTermsLink => 'Terms of Use';

  @override
  String get signUpLegalPrivacyLink => 'Privacy Policy';

  @override
  String get signUpCreateAccountButton => 'Create account';

  @override
  String get moderationActionReportUser => 'Report user';

  @override
  String get moderationActionReportMeme => 'Report meme';

  @override
  String get moderationActionReportGroup => 'Report group';

  @override
  String get moderationActionBlockUser => 'Block user';

  @override
  String get moderationActionUnblockUser => 'Unblock user';

  @override
  String get moderationReportDialogTitleUser => 'Report this user';

  @override
  String get moderationReportDialogTitleMeme => 'Report this meme';

  @override
  String get moderationReportDialogTitleGroup => 'Report this group';

  @override
  String get moderationReportReasonLabel => 'Reason';

  @override
  String get moderationReportReasonSpam => 'Spam';

  @override
  String get moderationReportReasonHarassment => 'Harassment';

  @override
  String get moderationReportReasonHateSpeech => 'Hate speech';

  @override
  String get moderationReportReasonSexualContent => 'Sexual content';

  @override
  String get moderationReportReasonViolence => 'Violence';

  @override
  String get moderationReportReasonScam => 'Scam';

  @override
  String get moderationReportReasonOther => 'Other';

  @override
  String get moderationReportReasonRequiredMessage =>
      'Please provide a report reason.';

  @override
  String get moderationReportCancelButton => 'Cancel';

  @override
  String get moderationReportSubmitButton => 'Send report';

  @override
  String get moderationReportSuccessMessage => 'Report submitted.';

  @override
  String get moderationBlockSuccessMessage => 'User blocked.';

  @override
  String get moderationUnblockSuccessMessage => 'User unblocked.';

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
  String get pushNotificationChannelName => 'Memuno notifications';

  @override
  String get pushNotificationChannelDescription =>
      'General notifications for the Memuno app.';

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
  String get userDetailsTitle => 'User details';

  @override
  String get userDetailsFriendshipCodeLabel => 'Friendship code:';

  @override
  String get userDetailsJoinedAtLabel => 'Joined on:';

  @override
  String get userDetailsUpdateNameDialogTitle => 'Update name';

  @override
  String get userDetailsUpdateNameSubmitButton => 'Save name';

  @override
  String get userDetailsUpdateNameSuccessMessage => 'Your name was updated.';

  @override
  String get userDetailsActionsTitle => 'Profile actions';

  @override
  String get userDetailsActionRemoveFriend => 'Remove friend';

  @override
  String get userDetailsRemoveFriendSuccessMessage => 'Friend removed.';

  @override
  String get userDetailsMemesTabAll => 'All';

  @override
  String get userDetailsMemesTabSent => 'Sent';

  @override
  String get userDetailsMemesTabReceived => 'Received';

  @override
  String get userDetailsOwnAllMemesEmpty => 'No memes yet.';

  @override
  String get userDetailsOwnSentMemesEmpty => 'You haven\'t created memes yet.';

  @override
  String get userDetailsOwnReceivedMemesEmpty => 'No memes received yet.';

  @override
  String get userDetailsOtherAllMemesEmpty => 'No memes exchanged yet.';

  @override
  String get userDetailsOtherSentMemesEmpty =>
      'No memes sent to this user yet.';

  @override
  String get userDetailsOtherReceivedMemesEmpty =>
      'No memes received from this user yet.';

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
  String get friendshipsSearchLabel => 'Search friendships';

  @override
  String get friendshipsSearchHint => 'Search by name';

  @override
  String get friendshipsRequestsSearchLabel => 'Search requests';

  @override
  String get friendshipsRequestsSearchHint => 'Search by name';

  @override
  String get friendshipsFriendsSincePrefix => 'Friends since';

  @override
  String get friendshipsRequestDirectionIncoming => 'Incoming';

  @override
  String get friendshipsRequestDirectionOutgoing => 'Outgoing';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsTabGroups => 'Groups';

  @override
  String get groupsTabInvitations => 'Invitations';

  @override
  String get groupsListEmpty => 'You are not in any groups yet.';

  @override
  String get groupsInvitationsListEmpty => 'No pending group invitations.';

  @override
  String get groupsSearchLabel => 'Search groups';

  @override
  String get groupsSearchHint => 'Search by name';

  @override
  String get groupsInvitationsSearchLabel => 'Search invitations';

  @override
  String get groupsInvitationsSearchHint => 'Search by name';

  @override
  String groupsMemberCount(Object count) {
    return '$count members';
  }

  @override
  String groupsInvitationFrom(
    Object sender_name,
    Object sender_friendship_code,
  ) {
    return 'From $sender_name ($sender_friendship_code)';
  }

  @override
  String get groupsInvitationAcceptSuccessMessage => 'Invitation accepted.';

  @override
  String get groupsInvitationRejectSuccessMessage => 'Invitation rejected.';

  @override
  String get groupsCreateNameTitle => 'Create a group';

  @override
  String get groupsCreateNameSubtitle => 'Choose a name for your group.';

  @override
  String get groupsCreateNameFieldLabel => 'Group name';

  @override
  String get groupsCreateNameFieldHint => 'Weekend Legends';

  @override
  String get groupsCreateNameContinueButton => 'Continue';

  @override
  String get groupsCreateMembersTitle => 'Invite members';

  @override
  String groupsCreateMembersSubtitle(Object count) {
    return '$count selected';
  }

  @override
  String get groupsCreateMembersSearchLabel => 'Search friends';

  @override
  String get groupsCreateMembersSearchHint => 'Search by name';

  @override
  String get groupsCreateMembersSubmitButton => 'Create group';

  @override
  String get groupsCreateSuccessMessage => 'Group created successfully.';

  @override
  String get groupDetailsTabAllMemes => 'All';

  @override
  String get groupDetailsTabSentByMe => 'Sent by me';

  @override
  String get groupDetailsMemesAllEmpty => 'No memes sent to this group yet.';

  @override
  String get groupDetailsMemesSentByMeEmpty =>
      'You have not sent memes to this group yet.';

  @override
  String get groupDetailsInfoTabMembers => 'Members';

  @override
  String get groupDetailsInfoTabInvitations => 'Invitations';

  @override
  String get groupDetailsMembersEmpty => 'No members found.';

  @override
  String get groupDetailsMembersSearchLabel => 'Search members';

  @override
  String get groupDetailsMembersSearchHint => 'Search by name';

  @override
  String get groupDetailsPendingInvitationsEmpty => 'No pending invitations.';

  @override
  String get groupDetailsInvitationsSearchLabel => 'Search invitations';

  @override
  String get groupDetailsInvitationsSearchHint => 'Search by name';

  @override
  String get groupDetailsMemberRoleCreator => 'Creator';

  @override
  String get groupDetailsMemberRoleAdmin => 'Admin';

  @override
  String get groupDetailsMemberRoleMember => 'Member';

  @override
  String get groupDetailsInviteMembersDialogTitle => 'Invite members';

  @override
  String groupDetailsInviteMembersSelected(Object count) {
    return '$count selected';
  }

  @override
  String get groupDetailsInviteMembersSubmitButton => 'Send invitations';

  @override
  String get groupDetailsInviteMembersEmpty =>
      'No friends available to invite.';

  @override
  String get groupDetailsInviteMembersSearchLabel => 'Search friends';

  @override
  String get groupDetailsInviteMembersSearchHint => 'Search by name';

  @override
  String get groupDetailsInviteMembersSuccessMessage => 'Invitations sent.';

  @override
  String get groupDetailsMemberActionsTitle => 'Member actions';

  @override
  String get groupDetailsMemberActionPromoteToAdmin => 'Make admin';

  @override
  String get groupDetailsMemberActionDemoteToMember =>
      'Remove admin privileges';

  @override
  String get groupDetailsMemberActionRemove => 'Remove member';

  @override
  String get groupDetailsGroupActionsTitle => 'Group actions';

  @override
  String get groupDetailsGroupActionLeave => 'Leave group';

  @override
  String get groupDetailsGroupActionDelete => 'Delete group';

  @override
  String get groupDetailsMemberRoleUpdateSuccessMessage =>
      'Member role updated.';

  @override
  String get groupDetailsUpdateNameDialogTitle => 'Update group name';

  @override
  String get groupDetailsUpdateNameSubmitButton => 'Save group name';

  @override
  String get groupDetailsUpdateNameSuccessMessage => 'Group name updated.';

  @override
  String get groupDetailsMemberRemoveSuccessMessage => 'Member removed.';

  @override
  String get groupDetailsInvitationCancelSuccessMessage =>
      'Invitation canceled.';

  @override
  String get groupDetailsLeaveSuccessMessage => 'You left the group.';

  @override
  String get groupDetailsDeleteSuccessMessage => 'Group deleted.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSearchLabel => 'Search notifications';

  @override
  String get notificationsSearchHint => 'Search by name';

  @override
  String get notificationsListEmpty => 'No notifications yet.';

  @override
  String get mainShellTabFeed => 'Feed';

  @override
  String get mainShellTabFriendships => 'Friends';

  @override
  String get mainShellTabGroups => 'Groups';

  @override
  String get feedListEmpty => 'No memes in your feed yet.';

  @override
  String get memeDetailsTitle => 'Meme details';

  @override
  String get memeDetailsLaughsTitle => 'Who laughed?';

  @override
  String get memeDetailsLaughsEmpty => 'No laughs yet.';

  @override
  String get memeDetailsActionsTitle => 'Meme actions';

  @override
  String get memeDetailsActionDelete => 'Delete meme';

  @override
  String get memeDetailsDeleteSuccessMessage => 'Meme deleted.';

  @override
  String get memeDetailsTabDetails => 'Details';

  @override
  String get memeDetailsTabRecipients => 'Recipients';

  @override
  String get memeDetailsRecipientsEmpty => 'No recipients yet.';

  @override
  String get memeDetailsAddRecipientsButton => 'Add recipients';

  @override
  String get memeDetailsRecipientRemoveSuccessMessage => 'Recipient removed.';

  @override
  String get memeDetailsAddRecipientsTitle => 'Add recipients';

  @override
  String memeDetailsAddRecipientsSelected(Object count) {
    return '$count selected';
  }

  @override
  String get memeDetailsAddRecipientsEmpty => 'No addable recipients found.';

  @override
  String get memeDetailsAddRecipientsSubmitButton => 'Add selected';

  @override
  String get memeDetailsRecipientsAddSuccessMessage => 'Recipients added.';

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
  String get notificationsItemGroupInvitationSentTitle =>
      'New group invitation';

  @override
  String notificationsItemGroupInvitationSent(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name invited you to join $group_name.';
  }

  @override
  String get notificationsItemMemeReceivedTitle => 'New meme received';

  @override
  String notificationsItemMemeReceived(Object sender_name) {
    return '$sender_name sent you a meme.';
  }

  @override
  String notificationsItemMemeReceivedDirect(Object sender_name) {
    return '$sender_name sent a meme to you.';
  }

  @override
  String notificationsItemMemeReceivedGroup(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name sent a meme to $group_name.';
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
  String get memeEditorTitle => 'New meme';

  @override
  String get memeEditorCanvasSelectTemplateHint => 'Select a meme template.';

  @override
  String get memeEditorTextBackgroundEnable => 'Enable text outline';

  @override
  String get memeEditorTextBackgroundDisable => 'Disable text outline';

  @override
  String get memeEditorDeleteTargetSemanticsLabel => 'Delete text';

  @override
  String get memeEditorRenderError => 'Unable to render meme editor output.';

  @override
  String get memeEditorPngEncodeError => 'Unable to convert meme to PNG bytes.';

  @override
  String get sendMemeTitle => 'Send meme';

  @override
  String get sendMemeSubmitButton => 'Send';

  @override
  String get sendMemeRecipientsListEmpty => 'No recipients available.';

  @override
  String get sendMemeRecipientsSearchLabel => 'Search recipients';

  @override
  String get sendMemeRecipientsSearchHint => 'Search by name';

  @override
  String get sendMemeSuccessMessage => 'Meme sent successfully.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionAccountManagement => 'Account management';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsBlockedUsersTitle => 'Blocked users';

  @override
  String get settingsBlockedUsersSubtitle => 'Manage users you have blocked.';

  @override
  String get settingsBlockedUsersSearchLabel => 'Search blocked users';

  @override
  String get settingsBlockedUsersSearchHint =>
      'Search by name or friendship code';

  @override
  String get settingsBlockedUsersEmpty => 'You have not blocked any users.';

  @override
  String get settingsBlockedUsersActionsTitle => 'Blocked user actions';

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
  String get settingsLegalPrivacyTitle => 'Privacy';

  @override
  String get settingsLegalPrivacySubtitle => 'Read the privacy policy.';

  @override
  String get settingsLegalTermsTitle => 'Terms of Use';

  @override
  String get settingsLegalTermsSubtitle => 'Read the terms of use.';

  @override
  String get settingsLegalCommunityTitle => 'Community Guidelines';

  @override
  String get settingsLegalCommunitySubtitle => 'Read community behavior rules.';

  @override
  String get settingsLegalAccountDeletionHelpSubtitle =>
      'Open account deletion instructions.';

  @override
  String get settingsLegalImpressumTitle => 'Impressum / Legal notice';

  @override
  String get settingsLegalImpressumSubtitle =>
      'View provider and legal notice details.';

  @override
  String get settingsLegalSupportTitle => 'Support';

  @override
  String get settingsLegalSupportSubtitle =>
      'Open support and moderation contact details.';

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
  String get signUpLegalConsentPrefix => 'I agree to the';

  @override
  String get signUpLegalConsentAnd => 'and';

  @override
  String get signUpLegalTermsLink => 'Terms of Use';

  @override
  String get signUpLegalPrivacyLink => 'Privacy Policy';

  @override
  String get signUpCreateAccountButton => 'Create account';

  @override
  String get moderationActionReportUser => 'Report user';

  @override
  String get moderationActionReportMeme => 'Report meme';

  @override
  String get moderationActionReportGroup => 'Report group';

  @override
  String get moderationActionBlockUser => 'Block user';

  @override
  String get moderationActionUnblockUser => 'Unblock user';

  @override
  String get moderationReportDialogTitleUser => 'Report this user';

  @override
  String get moderationReportDialogTitleMeme => 'Report this meme';

  @override
  String get moderationReportDialogTitleGroup => 'Report this group';

  @override
  String get moderationReportReasonLabel => 'Reason';

  @override
  String get moderationReportReasonSpam => 'Spam';

  @override
  String get moderationReportReasonHarassment => 'Harassment';

  @override
  String get moderationReportReasonHateSpeech => 'Hate speech';

  @override
  String get moderationReportReasonSexualContent => 'Sexual content';

  @override
  String get moderationReportReasonViolence => 'Violence';

  @override
  String get moderationReportReasonScam => 'Scam';

  @override
  String get moderationReportReasonOther => 'Other';

  @override
  String get moderationReportReasonRequiredMessage =>
      'Please provide a report reason.';

  @override
  String get moderationReportCancelButton => 'Cancel';

  @override
  String get moderationReportSubmitButton => 'Send report';

  @override
  String get moderationReportSuccessMessage => 'Report submitted.';

  @override
  String get moderationBlockSuccessMessage => 'User blocked.';

  @override
  String get moderationUnblockSuccessMessage => 'User unblocked.';

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
  String get pushNotificationChannelName => 'Memuno notifications';

  @override
  String get pushNotificationChannelDescription =>
      'General notifications for the Memuno app.';

  @override
  String get homeGreetingGeneric => 'Hey! 👋';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hey, $name! 👋';
  }
}
