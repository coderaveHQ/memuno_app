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
  String get signInSubtitle => 'Melde dich an, um fortzufahren.';

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
  String get homePullToRefreshHint => 'Zum Aktualisieren nach unten ziehen.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileFriendshipCodeLabel => 'Freundschaftscode:';

  @override
  String profileFriendshipCodeShareText(Object code) {
    return 'Lass uns bei Memuno befreundet sein: $code';
  }

  @override
  String get profileJoinedAtLabel => 'Beigetreten am:';

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
  String get memeEditorFinalizeButton => 'Fertig';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Wähle zuerst eine Meme-Vorlage aus.';

  @override
  String get memeEditorCanvasImageLoadError =>
      'Bild konnte nicht geladen werden.';

  @override
  String get memeEditorAddTextButton => 'Text hinzufügen';

  @override
  String get memeEditorTextLabel => 'Text';

  @override
  String get memeEditorTextHint => 'Schreibe deinen Meme-Text';

  @override
  String get memeEditorDefaultText => 'Text';

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
  String get sendMemeSuccessMessage => 'Meme erfolgreich gesendet.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSubtitle =>
      'Verwalte dein Konto und deine App-Einstellungen.';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get settingsSectionAccountManagement => 'Kontoverwaltung';

  @override
  String get settingsThemeModeTitle => 'Designmodus';

  @override
  String get settingsThemeModeSubtitle =>
      'Wähle aus, wie die App aussehen soll.';

  @override
  String get settingsThemeModeSystemOption => 'System';

  @override
  String get settingsThemeModeLightOption => 'Hell';

  @override
  String get settingsThemeModeDarkOption => 'Dunkel';

  @override
  String settingsThemeModeSystemDescription(Object mode) {
    return 'System folgen ($mode).';
  }

  @override
  String get settingsLanguageModeTitle => 'Sprache';

  @override
  String get settingsLanguageModeSubtitle =>
      'Wähle deine bevorzugte App-Sprache.';

  @override
  String get settingsLanguageModeSystemOption => 'System';

  @override
  String settingsLanguageModeSystemDescription(Object language) {
    return 'System folgen ($language).';
  }

  @override
  String get settingsChangeEmailListTileTitle => 'E-Mail-Adresse ändern';

  @override
  String get settingsChangeEmailListTileSubtitle =>
      'Aktualisiere deine Anmelde-E-Mail-Adresse.';

  @override
  String get settingsChangePasswordListTileTitle => 'Passwort ändern';

  @override
  String get settingsChangePasswordListTileSubtitle =>
      'Setze ein neues Passwort für dein Konto.';

  @override
  String get settingsDeleteAccountListTileTitle => 'Konto löschen';

  @override
  String get settingsDeleteAccountListTileSubtitle =>
      'Löscht dein Konto und deine Daten dauerhaft.';

  @override
  String get settingsChangeEmailTitle => 'E-Mail-Adresse ändern';

  @override
  String get settingsChangeEmailSubtitle =>
      'Gib deine neue E-Mail-Adresse ein und bestätige sie über deinen Posteingang.';

  @override
  String settingsChangeEmailCurrentEmail(Object email) {
    return 'Aktuelle E-Mail-Adresse: $email';
  }

  @override
  String get settingsChangeEmailNewEmailLabel => 'Neue E-Mail-Adresse';

  @override
  String get settingsChangeEmailSubmitButton => 'Bestätigungs-E-Mail senden';

  @override
  String get settingsChangePasswordTitle => 'Passwort ändern';

  @override
  String get settingsChangePasswordSubtitle =>
      'Setze ein neues Passwort für dein Konto.';

  @override
  String get settingsChangePasswordNewPasswordLabel => 'Neues Passwort';

  @override
  String get settingsChangePasswordSubmitButton => 'Passwort ändern';

  @override
  String get settingsChangePasswordSuccessMessage =>
      'Dein Passwort wurde erfolgreich geändert.';

  @override
  String get settingsDeleteAccountTitle => 'Konto löschen';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Diese Aktion ist endgültig und kann nicht rückgängig gemacht werden.';

  @override
  String get settingsDeleteAccountWarningBody =>
      'Durch das Löschen deines Kontos werden dein Profil und dein Zugriff auf die App dauerhaft entfernt.';

  @override
  String get settingsDeleteAccountSubmitButton => 'Mein Konto löschen';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'Diese Aktion ist endgültig. Möchtest du fortfahren?';

  @override
  String get settingsDeleteAccountConfirmCancelButton => 'Abbrechen';

  @override
  String get settingsDeleteAccountConfirmDeleteButton => 'Löschen';

  @override
  String get settingsDeleteAccountSuccessMessage =>
      'Dein Konto wurde gelöscht.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Bitte bestätige deine Registrierung.';

  @override
  String get signUpTitle => 'Registrierung';

  @override
  String get signUpSubtitle => 'Gib deine Daten ein, um zu starten.';

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
  String verifySignInInstruction(Object email) {
    return 'Gib den 6-stelligen Code ein, der an $email gesendet wurde, oder öffne den Link in deiner E-Mail.';
  }

  @override
  String get verifySignInCodeLabel => 'Bestätigungscode';

  @override
  String get verifySignInConfirmButton => 'Bestätigen';

  @override
  String get verifySignInNoEmailText => 'Keine E-Mail erhalten?';

  @override
  String get verifySignInResendCodeButton => 'Code erneut senden';

  @override
  String get verifySignUpResentCodeMessage =>
      'Wir haben dir erneut einen Code gesendet.';

  @override
  String get verifySignUpTitle => 'Anmeldung verifizieren';

  @override
  String verifySignUpInstruction(Object email) {
    return 'Gib den 6-stelligen Code ein, der an $email gesendet wurde, oder öffne den Link in deiner E-Mail.';
  }

  @override
  String get verifySignUpCodeLabel => 'Bestätigungscode';

  @override
  String get verifySignUpConfirmButton => 'Bestätigen';

  @override
  String get verifySignUpNoEmailText => 'Keine E-Mail erhalten?';

  @override
  String get verifySignUpResendCodeButton => 'Code erneut senden';

  @override
  String get authToastEmailChangedTitle => 'E-Mail-Adresse geändert';

  @override
  String get authToastEmailChangedMessage =>
      'Wir haben deine E-Mail-Adresse erfolgreich geändert.';

  @override
  String get authToastSignedInTitle => 'Anmeldung erfolgreich';

  @override
  String get authToastSignedInMessage => 'Du wurdest erfolgreich angemeldet.';

  @override
  String get authToastSignedOutTitle => 'Abmeldung erfolgreich';

  @override
  String get authToastSignedOutMessage => 'Du wurdest erfolgreich abgemeldet.';

  @override
  String get authToastPasswordRecoveryTitle => 'Anmeldung erfolgreich';

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
  String get signInSubtitle => 'Melde dich an, um fortzufahren.';

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
  String get homePullToRefreshHint => 'Zum Aktualisieren nach unten ziehen.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileFriendshipCodeLabel => 'Freundschaftscode:';

  @override
  String profileFriendshipCodeShareText(Object code) {
    return 'Lass uns bei Memuno befreundet sein: $code';
  }

  @override
  String get profileJoinedAtLabel => 'Beigetreten am:';

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
  String get memeEditorFinalizeButton => 'Fertig';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Wähle zuerst eine Meme-Vorlage aus.';

  @override
  String get memeEditorCanvasImageLoadError =>
      'Bild konnte nicht geladen werden.';

  @override
  String get memeEditorAddTextButton => 'Text hinzufügen';

  @override
  String get memeEditorTextLabel => 'Text';

  @override
  String get memeEditorTextHint => 'Schreibe deinen Meme-Text';

  @override
  String get memeEditorDefaultText => 'Text';

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
  String get sendMemeSuccessMessage => 'Meme erfolgreich gesendet.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSubtitle =>
      'Verwalte dein Konto und deine App-Einstellungen.';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get settingsSectionAccountManagement => 'Kontoverwaltung';

  @override
  String get settingsThemeModeTitle => 'Designmodus';

  @override
  String get settingsThemeModeSubtitle =>
      'Wähle aus, wie die App aussehen soll.';

  @override
  String get settingsThemeModeSystemOption => 'System';

  @override
  String get settingsThemeModeLightOption => 'Hell';

  @override
  String get settingsThemeModeDarkOption => 'Dunkel';

  @override
  String settingsThemeModeSystemDescription(Object mode) {
    return 'System folgen ($mode).';
  }

  @override
  String get settingsLanguageModeTitle => 'Sprache';

  @override
  String get settingsLanguageModeSubtitle =>
      'Wähle deine bevorzugte App-Sprache.';

  @override
  String get settingsLanguageModeSystemOption => 'System';

  @override
  String settingsLanguageModeSystemDescription(Object language) {
    return 'System folgen ($language).';
  }

  @override
  String get settingsChangeEmailListTileTitle => 'E-Mail-Adresse ändern';

  @override
  String get settingsChangeEmailListTileSubtitle =>
      'Aktualisiere deine Anmelde-E-Mail-Adresse.';

  @override
  String get settingsChangePasswordListTileTitle => 'Passwort ändern';

  @override
  String get settingsChangePasswordListTileSubtitle =>
      'Setze ein neues Passwort für dein Konto.';

  @override
  String get settingsDeleteAccountListTileTitle => 'Konto löschen';

  @override
  String get settingsDeleteAccountListTileSubtitle =>
      'Löscht dein Konto und deine Daten dauerhaft.';

  @override
  String get settingsChangeEmailTitle => 'E-Mail-Adresse ändern';

  @override
  String get settingsChangeEmailSubtitle =>
      'Gib deine neue E-Mail-Adresse ein und bestätige sie über deinen Posteingang.';

  @override
  String settingsChangeEmailCurrentEmail(Object email) {
    return 'Aktuelle E-Mail-Adresse: $email';
  }

  @override
  String get settingsChangeEmailNewEmailLabel => 'Neue E-Mail-Adresse';

  @override
  String get settingsChangeEmailSubmitButton => 'Bestätigungs-E-Mail senden';

  @override
  String get settingsChangePasswordTitle => 'Passwort ändern';

  @override
  String get settingsChangePasswordSubtitle =>
      'Setze ein neues Passwort für dein Konto.';

  @override
  String get settingsChangePasswordNewPasswordLabel => 'Neues Passwort';

  @override
  String get settingsChangePasswordSubmitButton => 'Passwort ändern';

  @override
  String get settingsChangePasswordSuccessMessage =>
      'Dein Passwort wurde erfolgreich geändert.';

  @override
  String get settingsDeleteAccountTitle => 'Konto löschen';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Diese Aktion ist endgültig und kann nicht rückgängig gemacht werden.';

  @override
  String get settingsDeleteAccountWarningBody =>
      'Durch das Löschen deines Kontos werden dein Profil und dein Zugriff auf die App dauerhaft entfernt.';

  @override
  String get settingsDeleteAccountSubmitButton => 'Mein Konto löschen';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'Diese Aktion ist endgültig. Möchtest du fortfahren?';

  @override
  String get settingsDeleteAccountConfirmCancelButton => 'Abbrechen';

  @override
  String get settingsDeleteAccountConfirmDeleteButton => 'Löschen';

  @override
  String get settingsDeleteAccountSuccessMessage =>
      'Dein Konto wurde gelöscht.';

  @override
  String get signUpConfirmRegistrationMessage =>
      'Bitte bestätige deine Registrierung.';

  @override
  String get signUpTitle => 'Registrierung';

  @override
  String get signUpSubtitle => 'Gib deine Daten ein, um zu starten.';

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
  String verifySignInInstruction(Object email) {
    return 'Gib den 6-stelligen Code ein, der an $email gesendet wurde, oder öffne den Link in deiner E-Mail.';
  }

  @override
  String get verifySignInCodeLabel => 'Bestätigungscode';

  @override
  String get verifySignInConfirmButton => 'Bestätigen';

  @override
  String get verifySignInNoEmailText => 'Keine E-Mail erhalten?';

  @override
  String get verifySignInResendCodeButton => 'Code erneut senden';

  @override
  String get verifySignUpResentCodeMessage =>
      'Wir haben dir erneut einen Code gesendet.';

  @override
  String get verifySignUpTitle => 'Anmeldung verifizieren';

  @override
  String verifySignUpInstruction(Object email) {
    return 'Gib den 6-stelligen Code ein, der an $email gesendet wurde, oder öffne den Link in deiner E-Mail.';
  }

  @override
  String get verifySignUpCodeLabel => 'Bestätigungscode';

  @override
  String get verifySignUpConfirmButton => 'Bestätigen';

  @override
  String get verifySignUpNoEmailText => 'Keine E-Mail erhalten?';

  @override
  String get verifySignUpResendCodeButton => 'Code erneut senden';

  @override
  String get authToastEmailChangedTitle => 'E-Mail-Adresse geändert';

  @override
  String get authToastEmailChangedMessage =>
      'Wir haben deine E-Mail-Adresse erfolgreich geändert.';

  @override
  String get authToastSignedInTitle => 'Anmeldung erfolgreich';

  @override
  String get authToastSignedInMessage => 'Du wurdest erfolgreich angemeldet.';

  @override
  String get authToastSignedOutTitle => 'Abmeldung erfolgreich';

  @override
  String get authToastSignedOutMessage => 'Du wurdest erfolgreich abgemeldet.';

  @override
  String get authToastPasswordRecoveryTitle => 'Anmeldung erfolgreich';

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
