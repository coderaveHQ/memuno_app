// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get toastTitleInfo => 'Hinweis';

  @override
  String get toastTitleSuccess => 'Erfolg';

  @override
  String get toastTitleWarning => 'Warnung';

  @override
  String get toastTitleError => 'Fehler';

  @override
  String get genericErrorMessage =>
      'Etwas ist schiefgelaufen. Bitte versuche es später.';

  @override
  String get networkErrorMessage =>
      'Keine Verbindung. Bitte prüfe dein Internet.';

  @override
  String get serverErrorMessage => 'Serverfehler. Bitte versuche es später.';

  @override
  String get validationInvalidEmail =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get validationInvalidFormat => 'Ungültiges Format.';

  @override
  String get validationInvalidFriendshipCode =>
      'Bitte gib einen gültigen 8-stelligen Freundschaftscode ein.';

  @override
  String get validationInvalidCredentials => 'E-Mail oder Passwort ist falsch.';

  @override
  String get validationUnknown =>
      'Eingabe ungültig. Bitte prüfe deine Angaben.';

  @override
  String validationMinLength(Object min) {
    return 'Muss mindestens $min Zeichen haben.';
  }

  @override
  String validationMaxLength(Object max) {
    return 'Darf maximal $max Zeichen haben.';
  }

  @override
  String get signInOtpSentMessage => 'Wir haben dir einen Code gesendet.';

  @override
  String get signInConfirmRegistrationMessage =>
      'Bitte bestätige deine Registrierung.';

  @override
  String get signInTitle => 'Anmeldung';

  @override
  String get signInEmailLabel => 'E-Mail';

  @override
  String get signInPasswordLabel => 'Passwort';

  @override
  String get signInSubmitWithPasswordButton => 'Mit Passwort anmelden';

  @override
  String get signInUseOtpButton => 'Anmeldecode nutzen';

  @override
  String get signInSendOtpButton => 'Anmeldecode senden';

  @override
  String get signInSwitchToPasswordButton => 'Mit Passwort anmelden';

  @override
  String get signInSignUpButton => 'Registrieren';

  @override
  String get signOutButton => 'Abmelden';

  @override
  String get userDetailsTitle => 'Nutzer-Details';

  @override
  String get userDetailsFriendshipCodeLabel => 'Freundschaftscode:';

  @override
  String get userDetailsJoinedAtLabel => 'Beigetreten am:';

  @override
  String get userDetailsUpdateNameDialogTitle => 'Namen aktualisieren';

  @override
  String get userDetailsUpdateNameSubmitButton => 'Namen speichern';

  @override
  String get userDetailsUpdateNameSuccessMessage =>
      'Dein Name wurde aktualisiert.';

  @override
  String get userDetailsActionsTitle => 'Profilaktionen';

  @override
  String get userDetailsActionRemoveFriend => 'Freund entfernen';

  @override
  String get userDetailsRemoveFriendSuccessMessage => 'Freund entfernt.';

  @override
  String get userDetailsMemesTabAll => 'Alle';

  @override
  String get userDetailsMemesTabSent => 'Gesendet';

  @override
  String get userDetailsMemesTabReceived => 'Empfangen';

  @override
  String get userDetailsOwnAllMemesEmpty => 'Noch keine Memes.';

  @override
  String get userDetailsOwnSentMemesEmpty =>
      'Du hast noch keine Memes erstellt.';

  @override
  String get userDetailsOwnReceivedMemesEmpty =>
      'Du hast noch keine Memes erhalten.';

  @override
  String get userDetailsOtherAllMemesEmpty =>
      'Noch keine ausgetauschten Memes.';

  @override
  String get userDetailsOtherSentMemesEmpty =>
      'Du hast dieser Person noch keine Memes gesendet.';

  @override
  String get userDetailsOtherReceivedMemesEmpty =>
      'Du hast von dieser Person noch keine Memes erhalten.';

  @override
  String get friendshipsTitle => 'Freundschaften';

  @override
  String get friendshipsTabFriendships => 'Freunde';

  @override
  String get friendshipsTabRequests => 'Anfragen';

  @override
  String get friendshipsAddDialogTitle => 'Freundschaftsanfrage senden';

  @override
  String get friendshipsAddDialogFieldLabel => 'Freundschaftscode';

  @override
  String get friendshipsAddDialogSubmitButton => 'Anfrage senden';

  @override
  String get friendshipsRequestCreateSuccessMessage =>
      'Freundschaftsanfrage gesendet.';

  @override
  String get friendshipsListEmpty => 'Noch keine Freundschaften vorhanden.';

  @override
  String get friendshipsRequestsListEmpty =>
      'Keine ausstehenden Freundschaftsanfragen.';

  @override
  String get friendshipsFriendsSincePrefix => 'Befreundet seit';

  @override
  String get friendshipsRequestDirectionIncoming => 'Eingehend';

  @override
  String get friendshipsRequestDirectionOutgoing => 'Ausgehend';

  @override
  String get groupsTitle => 'Gruppen';

  @override
  String get groupsTabGroups => 'Gruppen';

  @override
  String get groupsTabInvitations => 'Einladungen';

  @override
  String get groupsListEmpty => 'Du bist noch in keiner Gruppe.';

  @override
  String get groupsInvitationsListEmpty =>
      'Keine ausstehenden Gruppeneinladungen.';

  @override
  String groupsMemberCount(Object count) {
    return '$count Mitglieder';
  }

  @override
  String groupsInvitationFrom(
    Object sender_name,
    Object sender_friendship_code,
  ) {
    return 'Von $sender_name ($sender_friendship_code)';
  }

  @override
  String get groupsInvitationAcceptSuccessMessage => 'Einladung angenommen.';

  @override
  String get groupsInvitationRejectSuccessMessage => 'Einladung abgelehnt.';

  @override
  String get groupsCreateNameTitle => 'Gruppe erstellen';

  @override
  String get groupsCreateNameSubtitle => 'Gib deiner Gruppe einen Namen.';

  @override
  String get groupsCreateNameFieldLabel => 'Gruppenname';

  @override
  String get groupsCreateNameFieldHint => 'Wochenend-Legenden';

  @override
  String get groupsCreateNameContinueButton => 'Weiter';

  @override
  String get groupsCreateMembersTitle => 'Mitglieder einladen';

  @override
  String groupsCreateMembersSubtitle(Object count) {
    return '$count ausgewählt';
  }

  @override
  String get groupsCreateMembersSubmitButton => 'Gruppe erstellen';

  @override
  String get groupsCreateSuccessMessage => 'Gruppe erfolgreich erstellt.';

  @override
  String get groupDetailsTabAllMemes => 'Alle';

  @override
  String get groupDetailsTabSentByMe => 'Von mir gesendet';

  @override
  String get groupDetailsMemesAllEmpty => 'Noch keine Memes in dieser Gruppe.';

  @override
  String get groupDetailsMemesSentByMeEmpty =>
      'Du hast in diese Gruppe noch keine Memes gesendet.';

  @override
  String get groupDetailsInfoTabMembers => 'Mitglieder';

  @override
  String get groupDetailsInfoTabInvitations => 'Einladungen';

  @override
  String get groupDetailsMembersEmpty => 'Keine Mitglieder gefunden.';

  @override
  String get groupDetailsPendingInvitationsEmpty =>
      'Keine ausstehenden Einladungen.';

  @override
  String get groupDetailsMemberRoleCreator => 'Ersteller';

  @override
  String get groupDetailsMemberRoleAdmin => 'Admin';

  @override
  String get groupDetailsMemberRoleMember => 'Mitglied';

  @override
  String get groupDetailsInviteMembersDialogTitle => 'Mitglieder einladen';

  @override
  String groupDetailsInviteMembersSelected(Object count) {
    return '$count ausgewählt';
  }

  @override
  String get groupDetailsInviteMembersSubmitButton => 'Einladungen senden';

  @override
  String get groupDetailsInviteMembersEmpty =>
      'Keine Freunde zum Einladen verfügbar.';

  @override
  String get groupDetailsInviteMembersSuccessMessage => 'Einladungen gesendet.';

  @override
  String get groupDetailsMemberActionsTitle => 'Mitgliedsaktionen';

  @override
  String get groupDetailsMemberActionPromoteToAdmin => 'Zum Admin machen';

  @override
  String get groupDetailsMemberActionDemoteToMember => 'Admin-Rechte entziehen';

  @override
  String get groupDetailsMemberActionRemove => 'Mitglied entfernen';

  @override
  String get groupDetailsGroupActionsTitle => 'Gruppenaktionen';

  @override
  String get groupDetailsGroupActionLeave => 'Gruppe verlassen';

  @override
  String get groupDetailsGroupActionDelete => 'Gruppe löschen';

  @override
  String get groupDetailsMemberRoleUpdateSuccessMessage =>
      'Mitgliedsrolle aktualisiert.';

  @override
  String get groupDetailsUpdateNameDialogTitle => 'Gruppennamen bearbeiten';

  @override
  String get groupDetailsUpdateNameSubmitButton => 'Gruppennamen speichern';

  @override
  String get groupDetailsUpdateNameSuccessMessage =>
      'Gruppenname aktualisiert.';

  @override
  String get groupDetailsMemberRemoveSuccessMessage => 'Mitglied entfernt.';

  @override
  String get groupDetailsInvitationCancelSuccessMessage =>
      'Einladung abgebrochen.';

  @override
  String get groupDetailsLeaveSuccessMessage => 'Du hast die Gruppe verlassen.';

  @override
  String get groupDetailsDeleteSuccessMessage => 'Gruppe gelöscht.';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsSearchLabel => 'Benachrichtigungen suchen';

  @override
  String get notificationsSearchHint =>
      'Nach Name oder Freundschaftscode suchen';

  @override
  String get notificationsListEmpty => 'Noch keine Benachrichtigungen.';

  @override
  String get mainShellTabFeed => 'Feed';

  @override
  String get mainShellTabFriendships => 'Freunde';

  @override
  String get mainShellTabGroups => 'Gruppen';

  @override
  String get feedListEmpty => 'Noch keine Memes in deinem Feed.';

  @override
  String get memeDetailsTitle => 'Meme-Details';

  @override
  String get memeDetailsLaughsTitle => 'Wer hat gelacht?';

  @override
  String get memeDetailsLaughsEmpty => 'Noch keine Lacher.';

  @override
  String get memeDetailsActionsTitle => 'Meme-Aktionen';

  @override
  String get memeDetailsActionDelete => 'Meme löschen';

  @override
  String get memeDetailsDeleteSuccessMessage => 'Meme gelöscht.';

  @override
  String get notificationsItemFriendshipRequestSentTitle =>
      'Neue Freundschaftsanfrage';

  @override
  String notificationsItemFriendshipRequestSent(Object sender_name) {
    return '$sender_name hat dir eine Freundschaftsanfrage gesendet.';
  }

  @override
  String get notificationsItemFriendshipRequestAcceptedTitle =>
      'Freundschaftsanfrage angenommen';

  @override
  String notificationsItemFriendshipRequestAccepted(Object sender_name) {
    return '$sender_name hat deine Freundschaftsanfrage angenommen.';
  }

  @override
  String get notificationsItemGroupInvitationSentTitle =>
      'Neue Gruppeneinladung';

  @override
  String notificationsItemGroupInvitationSent(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name hat dich zu $group_name eingeladen.';
  }

  @override
  String get notificationsItemMemeReceivedTitle => 'Neues Meme erhalten';

  @override
  String notificationsItemMemeReceived(Object sender_name) {
    return '$sender_name hat dir ein Meme gesendet.';
  }

  @override
  String notificationsItemMemeReceivedDirect(Object sender_name) {
    return '$sender_name hat ein Meme an dich gesendet.';
  }

  @override
  String notificationsItemMemeReceivedGroup(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name hat ein Meme an $group_name gesendet.';
  }

  @override
  String get notificationsItemMemeLaughedTitle =>
      'Dein Meme brachte jemanden zum Lachen';

  @override
  String notificationsItemMemeLaughed(Object sender_name) {
    return '$sender_name hat über dein Meme gelacht.';
  }

  @override
  String get memeTemplatePickerTitle => 'Meme-Vorlagen';

  @override
  String get memeTemplatePickerSearchLabel => 'Vorlage suchen';

  @override
  String get memeTemplatePickerSearchHint => 'z. B. drake, distracted, doge';

  @override
  String get memeTemplatePickerEmpty => 'Keine Meme-Vorlagen gefunden.';

  @override
  String get memeEditorTitle => 'Neues Meme';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Wähle eine Meme-Vorlage aus.';

  @override
  String get memeEditorTextBackgroundEnable => 'Textkontur aktivieren';

  @override
  String get memeEditorTextBackgroundDisable => 'Textkontur deaktivieren';

  @override
  String get memeEditorDeleteTargetSemanticsLabel => 'Text löschen';

  @override
  String get memeEditorRenderError =>
      'Meme-Editor-Ausgabe konnte nicht gerendert werden.';

  @override
  String get memeEditorPngEncodeError =>
      'Meme konnte nicht in PNG-Bytes konvertiert werden.';

  @override
  String get sendMemeTitle => 'Meme senden';

  @override
  String get sendMemeSubmitButton => 'Senden';

  @override
  String get sendMemeRecipientsListEmpty => 'Keine Empfänger verfügbar.';

  @override
  String get sendMemeSuccessMessage => 'Meme erfolgreich gesendet.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get settingsSectionAccountManagement => 'Kontoverwaltung';

  @override
  String get languageModeTitle => 'Sprache';

  @override
  String get languageModeSystemOption => 'System';

  @override
  String languageModeSystemDescription(Object language) {
    return 'System folgen ($language).';
  }

  @override
  String get changeEmailListTileTitle => 'E-Mail-Adresse ändern';

  @override
  String get changeEmailListTileSubtitle =>
      'Aktualisiere deine Anmelde-E-Mail-Adresse.';

  @override
  String get changePasswordListTileTitle => 'Passwort ändern';

  @override
  String get changePasswordListTileSubtitle =>
      'Setze ein neues Passwort für dein Konto.';

  @override
  String get deleteAccountListTileTitle => 'Konto löschen';

  @override
  String get deleteAccountListTileSubtitle =>
      'Löscht dein Konto und deine Daten dauerhaft.';

  @override
  String get changeEmailTitle => 'E-Mail-Adresse ändern';

  @override
  String changeEmailCurrentEmail(Object email) {
    return 'Aktuelle E-Mail-Adresse: $email';
  }

  @override
  String get changeEmailNewEmailLabel => 'Neue E-Mail-Adresse';

  @override
  String get changeEmailSubmitButton => 'Bestätigungs-E-Mail senden';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get changePasswordNewPasswordLabel => 'Neues Passwort';

  @override
  String get changePasswordSubmitButton => 'Passwort ändern';

  @override
  String get changePasswordSuccessMessage =>
      'Dein Passwort wurde erfolgreich geändert.';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get deleteAccountWarningBody =>
      'Durch das Löschen deines Kontos werden dein Profil und dein Zugriff auf die App dauerhaft entfernt.';

  @override
  String get deleteAccountSubmitButton => 'Mein Konto löschen';

  @override
  String get deleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get deleteAccountConfirmMessage =>
      'Diese Aktion ist endgültig. Möchtest du fortfahren?';

  @override
  String get deleteAccountConfirmCancelButton => 'Abbrechen';

  @override
  String get deleteAccountConfirmDeleteButton => 'Löschen';

  @override
  String get deleteAccountSuccessMessage => 'Dein Konto wurde gelöscht.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Bitte bestätige deine Registrierung.';

  @override
  String get signUpTitle => 'Registrierung';

  @override
  String get signUpNameLabel => 'Vollständiger Name';

  @override
  String get signUpEmailLabel => 'E-Mail';

  @override
  String get signUpPasswordLabel => 'Passwort';

  @override
  String get signUpCreateAccountButton => 'Konto erstellen';

  @override
  String get verifySignInResentCodeMessage =>
      'Wir haben dir erneut einen Code gesendet.';

  @override
  String get verifySignInTitle => 'Anmeldung verifizieren';

  @override
  String get verifySignInConfirmButton => 'Bestätigen';

  @override
  String get verifySignInResendCodeButton => 'Code erneut senden';

  @override
  String get verifySignUpResentCodeMessage =>
      'Wir haben dir erneut einen Code gesendet.';

  @override
  String get verifySignUpTitle => 'Anmeldung verifizieren';

  @override
  String get verifySignUpConfirmButton => 'Bestätigen';

  @override
  String get verifySignUpResendCodeButton => 'Code erneut senden';

  @override
  String get authToastEmailChangedMessage =>
      'Wir haben deine E-Mail-Adresse erfolgreich geändert.';

  @override
  String get authToastSignedInMessage => 'Du wurdest erfolgreich angemeldet.';

  @override
  String get authToastSignedOutMessage => 'Du wurdest erfolgreich abgemeldet.';

  @override
  String get authToastPasswordRecoveryMessage =>
      'Du kannst nun dein Passwort ändern.';

  @override
  String get homeGreetingGeneric => 'Hey! 👋';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hey, $name! 👋';
  }
}

/// The translations for German, as used in Germany (`de_DE`).
class AppLocalizationsDeDe extends AppLocalizationsDe {
  AppLocalizationsDeDe() : super('de_DE');

  @override
  String get toastTitleInfo => 'Hinweis';

  @override
  String get toastTitleSuccess => 'Erfolg';

  @override
  String get toastTitleWarning => 'Warnung';

  @override
  String get toastTitleError => 'Fehler';

  @override
  String get genericErrorMessage =>
      'Etwas ist schiefgelaufen. Bitte versuche es später.';

  @override
  String get networkErrorMessage =>
      'Keine Verbindung. Bitte prüfe dein Internet.';

  @override
  String get serverErrorMessage => 'Serverfehler. Bitte versuche es später.';

  @override
  String get validationInvalidEmail =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get validationInvalidFormat => 'Ungültiges Format.';

  @override
  String get validationInvalidFriendshipCode =>
      'Bitte gib einen gültigen 8-stelligen Freundschaftscode ein.';

  @override
  String get validationInvalidCredentials => 'E-Mail oder Passwort ist falsch.';

  @override
  String get validationUnknown =>
      'Eingabe ungültig. Bitte prüfe deine Angaben.';

  @override
  String validationMinLength(Object min) {
    return 'Muss mindestens $min Zeichen haben.';
  }

  @override
  String validationMaxLength(Object max) {
    return 'Darf maximal $max Zeichen haben.';
  }

  @override
  String get signInOtpSentMessage => 'Wir haben dir einen Code gesendet.';

  @override
  String get signInConfirmRegistrationMessage =>
      'Bitte bestätige deine Registrierung.';

  @override
  String get signInTitle => 'Anmeldung';

  @override
  String get signInEmailLabel => 'E-Mail';

  @override
  String get signInPasswordLabel => 'Passwort';

  @override
  String get signInSubmitWithPasswordButton => 'Mit Passwort anmelden';

  @override
  String get signInUseOtpButton => 'Anmeldecode nutzen';

  @override
  String get signInSendOtpButton => 'Anmeldecode senden';

  @override
  String get signInSwitchToPasswordButton => 'Mit Passwort anmelden';

  @override
  String get signInSignUpButton => 'Registrieren';

  @override
  String get signOutButton => 'Abmelden';

  @override
  String get userDetailsTitle => 'Nutzer-Details';

  @override
  String get userDetailsFriendshipCodeLabel => 'Freundschaftscode:';

  @override
  String get userDetailsJoinedAtLabel => 'Beigetreten am:';

  @override
  String get userDetailsUpdateNameDialogTitle => 'Namen aktualisieren';

  @override
  String get userDetailsUpdateNameSubmitButton => 'Namen speichern';

  @override
  String get userDetailsUpdateNameSuccessMessage =>
      'Dein Name wurde aktualisiert.';

  @override
  String get userDetailsActionsTitle => 'Profilaktionen';

  @override
  String get userDetailsActionRemoveFriend => 'Freund entfernen';

  @override
  String get userDetailsRemoveFriendSuccessMessage => 'Freund entfernt.';

  @override
  String get userDetailsMemesTabAll => 'Alle';

  @override
  String get userDetailsMemesTabSent => 'Gesendet';

  @override
  String get userDetailsMemesTabReceived => 'Empfangen';

  @override
  String get userDetailsOwnAllMemesEmpty => 'Noch keine Memes.';

  @override
  String get userDetailsOwnSentMemesEmpty =>
      'Du hast noch keine Memes erstellt.';

  @override
  String get userDetailsOwnReceivedMemesEmpty =>
      'Du hast noch keine Memes erhalten.';

  @override
  String get userDetailsOtherAllMemesEmpty =>
      'Noch keine ausgetauschten Memes.';

  @override
  String get userDetailsOtherSentMemesEmpty =>
      'Du hast dieser Person noch keine Memes gesendet.';

  @override
  String get userDetailsOtherReceivedMemesEmpty =>
      'Du hast von dieser Person noch keine Memes erhalten.';

  @override
  String get friendshipsTitle => 'Freundschaften';

  @override
  String get friendshipsTabFriendships => 'Freunde';

  @override
  String get friendshipsTabRequests => 'Anfragen';

  @override
  String get friendshipsAddDialogTitle => 'Freundschaftsanfrage senden';

  @override
  String get friendshipsAddDialogFieldLabel => 'Freundschaftscode';

  @override
  String get friendshipsAddDialogSubmitButton => 'Anfrage senden';

  @override
  String get friendshipsRequestCreateSuccessMessage =>
      'Freundschaftsanfrage gesendet.';

  @override
  String get friendshipsListEmpty => 'Noch keine Freundschaften vorhanden.';

  @override
  String get friendshipsRequestsListEmpty =>
      'Keine ausstehenden Freundschaftsanfragen.';

  @override
  String get friendshipsFriendsSincePrefix => 'Befreundet seit';

  @override
  String get friendshipsRequestDirectionIncoming => 'Eingehend';

  @override
  String get friendshipsRequestDirectionOutgoing => 'Ausgehend';

  @override
  String get groupsTitle => 'Gruppen';

  @override
  String get groupsTabGroups => 'Gruppen';

  @override
  String get groupsTabInvitations => 'Einladungen';

  @override
  String get groupsListEmpty => 'Du bist noch in keiner Gruppe.';

  @override
  String get groupsInvitationsListEmpty =>
      'Keine ausstehenden Gruppeneinladungen.';

  @override
  String groupsMemberCount(Object count) {
    return '$count Mitglieder';
  }

  @override
  String groupsInvitationFrom(
    Object sender_name,
    Object sender_friendship_code,
  ) {
    return 'Von $sender_name ($sender_friendship_code)';
  }

  @override
  String get groupsInvitationAcceptSuccessMessage => 'Einladung angenommen.';

  @override
  String get groupsInvitationRejectSuccessMessage => 'Einladung abgelehnt.';

  @override
  String get groupsCreateNameTitle => 'Gruppe erstellen';

  @override
  String get groupsCreateNameSubtitle => 'Gib deiner Gruppe einen Namen.';

  @override
  String get groupsCreateNameFieldLabel => 'Gruppenname';

  @override
  String get groupsCreateNameFieldHint => 'Wochenend-Legenden';

  @override
  String get groupsCreateNameContinueButton => 'Weiter';

  @override
  String get groupsCreateMembersTitle => 'Mitglieder einladen';

  @override
  String groupsCreateMembersSubtitle(Object count) {
    return '$count ausgewählt';
  }

  @override
  String get groupsCreateMembersSubmitButton => 'Gruppe erstellen';

  @override
  String get groupsCreateSuccessMessage => 'Gruppe erfolgreich erstellt.';

  @override
  String get groupDetailsTabAllMemes => 'Alle';

  @override
  String get groupDetailsTabSentByMe => 'Von mir gesendet';

  @override
  String get groupDetailsMemesAllEmpty => 'Noch keine Memes in dieser Gruppe.';

  @override
  String get groupDetailsMemesSentByMeEmpty =>
      'Du hast in diese Gruppe noch keine Memes gesendet.';

  @override
  String get groupDetailsInfoTabMembers => 'Mitglieder';

  @override
  String get groupDetailsInfoTabInvitations => 'Einladungen';

  @override
  String get groupDetailsMembersEmpty => 'Keine Mitglieder gefunden.';

  @override
  String get groupDetailsPendingInvitationsEmpty =>
      'Keine ausstehenden Einladungen.';

  @override
  String get groupDetailsMemberRoleCreator => 'Ersteller';

  @override
  String get groupDetailsMemberRoleAdmin => 'Admin';

  @override
  String get groupDetailsMemberRoleMember => 'Mitglied';

  @override
  String get groupDetailsInviteMembersDialogTitle => 'Mitglieder einladen';

  @override
  String groupDetailsInviteMembersSelected(Object count) {
    return '$count ausgewählt';
  }

  @override
  String get groupDetailsInviteMembersSubmitButton => 'Einladungen senden';

  @override
  String get groupDetailsInviteMembersEmpty =>
      'Keine Freunde zum Einladen verfügbar.';

  @override
  String get groupDetailsInviteMembersSuccessMessage => 'Einladungen gesendet.';

  @override
  String get groupDetailsMemberActionsTitle => 'Mitgliedsaktionen';

  @override
  String get groupDetailsMemberActionPromoteToAdmin => 'Zum Admin machen';

  @override
  String get groupDetailsMemberActionDemoteToMember => 'Admin-Rechte entziehen';

  @override
  String get groupDetailsMemberActionRemove => 'Mitglied entfernen';

  @override
  String get groupDetailsGroupActionsTitle => 'Gruppenaktionen';

  @override
  String get groupDetailsGroupActionLeave => 'Gruppe verlassen';

  @override
  String get groupDetailsGroupActionDelete => 'Gruppe löschen';

  @override
  String get groupDetailsMemberRoleUpdateSuccessMessage =>
      'Mitgliedsrolle aktualisiert.';

  @override
  String get groupDetailsUpdateNameDialogTitle => 'Gruppennamen bearbeiten';

  @override
  String get groupDetailsUpdateNameSubmitButton => 'Gruppennamen speichern';

  @override
  String get groupDetailsUpdateNameSuccessMessage =>
      'Gruppenname aktualisiert.';

  @override
  String get groupDetailsMemberRemoveSuccessMessage => 'Mitglied entfernt.';

  @override
  String get groupDetailsInvitationCancelSuccessMessage =>
      'Einladung abgebrochen.';

  @override
  String get groupDetailsLeaveSuccessMessage => 'Du hast die Gruppe verlassen.';

  @override
  String get groupDetailsDeleteSuccessMessage => 'Gruppe gelöscht.';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsSearchLabel => 'Benachrichtigungen suchen';

  @override
  String get notificationsSearchHint =>
      'Nach Name oder Freundschaftscode suchen';

  @override
  String get notificationsListEmpty => 'Noch keine Benachrichtigungen.';

  @override
  String get mainShellTabFeed => 'Feed';

  @override
  String get mainShellTabFriendships => 'Freunde';

  @override
  String get mainShellTabGroups => 'Gruppen';

  @override
  String get feedListEmpty => 'Noch keine Memes in deinem Feed.';

  @override
  String get memeDetailsTitle => 'Meme-Details';

  @override
  String get memeDetailsLaughsTitle => 'Wer hat gelacht?';

  @override
  String get memeDetailsLaughsEmpty => 'Noch keine Lacher.';

  @override
  String get memeDetailsActionsTitle => 'Meme-Aktionen';

  @override
  String get memeDetailsActionDelete => 'Meme löschen';

  @override
  String get memeDetailsDeleteSuccessMessage => 'Meme gelöscht.';

  @override
  String get notificationsItemFriendshipRequestSentTitle =>
      'Neue Freundschaftsanfrage';

  @override
  String notificationsItemFriendshipRequestSent(Object sender_name) {
    return '$sender_name hat dir eine Freundschaftsanfrage gesendet.';
  }

  @override
  String get notificationsItemFriendshipRequestAcceptedTitle =>
      'Freundschaftsanfrage angenommen';

  @override
  String notificationsItemFriendshipRequestAccepted(Object sender_name) {
    return '$sender_name hat deine Freundschaftsanfrage angenommen.';
  }

  @override
  String get notificationsItemGroupInvitationSentTitle =>
      'Neue Gruppeneinladung';

  @override
  String notificationsItemGroupInvitationSent(
    Object sender_name,
    Object group_name,
  ) {
    return '$sender_name hat dich zu $group_name eingeladen.';
  }

  @override
  String get notificationsItemMemeReceivedTitle => 'Neues Meme erhalten';

  @override
  String notificationsItemMemeReceived(Object sender_name) {
    return '$sender_name hat dir ein Meme gesendet.';
  }

  @override
  String get notificationsItemMemeLaughedTitle =>
      'Dein Meme brachte jemanden zum Lachen';

  @override
  String notificationsItemMemeLaughed(Object sender_name) {
    return '$sender_name hat über dein Meme gelacht.';
  }

  @override
  String get memeTemplatePickerTitle => 'Meme-Vorlagen';

  @override
  String get memeTemplatePickerSearchLabel => 'Vorlage suchen';

  @override
  String get memeTemplatePickerSearchHint => 'z. B. drake, distracted, doge';

  @override
  String get memeTemplatePickerEmpty => 'Keine Meme-Vorlagen gefunden.';

  @override
  String get memeEditorTitle => 'Neues Meme';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Wähle eine Meme-Vorlage aus.';

  @override
  String get memeEditorTextBackgroundEnable => 'Textkontur aktivieren';

  @override
  String get memeEditorTextBackgroundDisable => 'Textkontur deaktivieren';

  @override
  String get memeEditorDeleteTargetSemanticsLabel => 'Text löschen';

  @override
  String get memeEditorRenderError =>
      'Meme-Editor-Ausgabe konnte nicht gerendert werden.';

  @override
  String get memeEditorPngEncodeError =>
      'Meme konnte nicht in PNG-Bytes konvertiert werden.';

  @override
  String get sendMemeTitle => 'Meme senden';

  @override
  String get sendMemeSubmitButton => 'Senden';

  @override
  String get sendMemeRecipientsListEmpty => 'Keine Empfänger verfügbar.';

  @override
  String get sendMemeSuccessMessage => 'Meme erfolgreich gesendet.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get settingsSectionAccountManagement => 'Kontoverwaltung';

  @override
  String get languageModeTitle => 'Sprache';

  @override
  String get languageModeSystemOption => 'System';

  @override
  String languageModeSystemDescription(Object language) {
    return 'System folgen ($language).';
  }

  @override
  String get changeEmailListTileTitle => 'E-Mail-Adresse ändern';

  @override
  String get changeEmailListTileSubtitle =>
      'Aktualisiere deine Anmelde-E-Mail-Adresse.';

  @override
  String get changePasswordListTileTitle => 'Passwort ändern';

  @override
  String get changePasswordListTileSubtitle =>
      'Setze ein neues Passwort für dein Konto.';

  @override
  String get deleteAccountListTileTitle => 'Konto löschen';

  @override
  String get deleteAccountListTileSubtitle =>
      'Löscht dein Konto und deine Daten dauerhaft.';

  @override
  String get changeEmailTitle => 'E-Mail-Adresse ändern';

  @override
  String changeEmailCurrentEmail(Object email) {
    return 'Aktuelle E-Mail-Adresse: $email';
  }

  @override
  String get changeEmailNewEmailLabel => 'Neue E-Mail-Adresse';

  @override
  String get changeEmailSubmitButton => 'Bestätigungs-E-Mail senden';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get changePasswordNewPasswordLabel => 'Neues Passwort';

  @override
  String get changePasswordSubmitButton => 'Passwort ändern';

  @override
  String get changePasswordSuccessMessage =>
      'Dein Passwort wurde erfolgreich geändert.';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get deleteAccountWarningBody =>
      'Durch das Löschen deines Kontos werden dein Profil und dein Zugriff auf die App dauerhaft entfernt.';

  @override
  String get deleteAccountSubmitButton => 'Mein Konto löschen';

  @override
  String get deleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get deleteAccountConfirmMessage =>
      'Diese Aktion ist endgültig. Möchtest du fortfahren?';

  @override
  String get deleteAccountConfirmCancelButton => 'Abbrechen';

  @override
  String get deleteAccountConfirmDeleteButton => 'Löschen';

  @override
  String get deleteAccountSuccessMessage => 'Dein Konto wurde gelöscht.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Bitte bestätige deine Registrierung.';

  @override
  String get signUpTitle => 'Registrierung';

  @override
  String get signUpNameLabel => 'Vollständiger Name';

  @override
  String get signUpEmailLabel => 'E-Mail';

  @override
  String get signUpPasswordLabel => 'Passwort';

  @override
  String get signUpCreateAccountButton => 'Konto erstellen';

  @override
  String get verifySignInResentCodeMessage =>
      'Wir haben dir erneut einen Code gesendet.';

  @override
  String get verifySignInTitle => 'Anmeldung verifizieren';

  @override
  String get verifySignInConfirmButton => 'Bestätigen';

  @override
  String get verifySignInResendCodeButton => 'Code erneut senden';

  @override
  String get verifySignUpResentCodeMessage =>
      'Wir haben dir erneut einen Code gesendet.';

  @override
  String get verifySignUpTitle => 'Anmeldung verifizieren';

  @override
  String get verifySignUpConfirmButton => 'Bestätigen';

  @override
  String get verifySignUpResendCodeButton => 'Code erneut senden';

  @override
  String get authToastEmailChangedMessage =>
      'Wir haben deine E-Mail-Adresse erfolgreich geändert.';

  @override
  String get authToastSignedInMessage => 'Du wurdest erfolgreich angemeldet.';

  @override
  String get authToastSignedOutMessage => 'Du wurdest erfolgreich abgemeldet.';

  @override
  String get authToastPasswordRecoveryMessage =>
      'Du kannst nun dein Passwort ändern.';

  @override
  String get homeGreetingGeneric => 'Hey! 👋';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hey, $name! 👋';
  }
}
