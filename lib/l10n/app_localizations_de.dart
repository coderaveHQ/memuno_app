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
  String get permissionGalleryDeniedMessage =>
      'Bitte erlaube den Zugriff auf deine Fotos, um ein Bild von deinem Gerät auszuwählen.';

  @override
  String get validationMemePayloadTooLarge =>
      'Bild und Text sind zusammen größer als 5 MB. Bitte verwende ein kleineres Bild.';

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
  String get memeTemplatePickerGalleryButton => 'Aus Galerie';

  @override
  String get memeEditorTitle => 'Neues Meme';

  @override
  String get memeEditorFinalizeButton => 'Fertig';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Wähle eine Meme-Vorlage oder ein Bild aus deiner Galerie aus.';

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
  String get permissionGalleryDeniedMessage =>
      'Bitte erlaube den Zugriff auf deine Fotos, um ein Bild von deinem Gerät auszuwählen.';

  @override
  String get validationMemePayloadTooLarge =>
      'Bild und Text sind zusammen größer als 5 MB. Bitte verwende ein kleineres Bild.';

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
  String get memeTemplatePickerGalleryButton => 'Aus Galerie';

  @override
  String get memeEditorTitle => 'Neues Meme';

  @override
  String get memeEditorFinalizeButton => 'Fertig';

  @override
  String get memeEditorCanvasSelectTemplateHint =>
      'Wähle eine Meme-Vorlage oder ein Bild aus deiner Galerie aus.';

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
