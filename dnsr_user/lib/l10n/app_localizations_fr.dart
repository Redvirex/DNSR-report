// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'DNSR Report';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get continueButton => 'Continuer';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get or => 'ou';

  @override
  String get privacyStatement => 'Déclaration de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get bySigningIn => 'En me connectant, j\'accepte les';

  @override
  String get and => 'et';

  @override
  String get accountFound =>
      'Compte trouvé ! Cliquez pour envoyer le lien de connexion';

  @override
  String get newUser => 'Nouvel utilisateur ! Cliquez pour créer un compte';

  @override
  String get checkYourInbox => 'Vérifiez votre boîte de réception';

  @override
  String get signInLinkSent =>
      'Nous avons envoyé un lien de connexion à votre boîte mail.\nVeuillez vérifier votre boîte de réception.\nN\'oubliez pas de vérifier votre dossier spam/courrier indésirable.';

  @override
  String get createAccountLinkSent =>
      'Nous avons envoyé un lien magique pour créer votre compte.\nVeuillez vérifier votre boîte de réception.\nN\'oubliez pas de vérifier votre dossier spam/courrier indésirable.';

  @override
  String get resendLink => 'Renvoyer le lien';

  @override
  String resendLinkCountdown(Object seconds) {
    return 'Renvoyer le lien (${seconds}s)';
  }

  @override
  String get yourEmailAddress => 'votre adresse e-mail';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre adresse e-mail';

  @override
  String get pleaseEnterValidEmail =>
      'Veuillez entrer une adresse e-mail valide';

  @override
  String get profile => 'Profil';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get loggedOutSuccessfully => 'Déconnecté avec succès';

  @override
  String get logoutFailed => 'Échec de la déconnexion';

  @override
  String get cancel => 'Annuler';

  @override
  String get hiWelcomeToDNSR => 'Salut, Bienvenue sur DNSR Report';

  @override
  String get chooseOption => 'Choisissez une option ci-dessous\npour commencer';

  @override
  String get reportIncident => 'Signaler un incident';

  @override
  String get reportIncidentSubtitle =>
      'signaler les incidents et dangers de route';

  @override
  String get routeCodes => 'Codes de route';

  @override
  String get routeCodesSubtitle => 'lire le code de route ou le télécharger';

  @override
  String get routeCodesComingSoon =>
      'Fonctionnalité codes de route bientôt disponible !';

  @override
  String get profileIncomplete => 'Profil incomplet';

  @override
  String get completeProfileMessage =>
      'Veuillez compléter votre profil pour accéder à toutes les fonctionnalités';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get editMyProfile => 'Modifier mon profil';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get fullName => 'Nom complet';

  @override
  String get firstNameLastName => '\'prénom\' \'nom de famille\'';

  @override
  String get pleaseEnterFullName => 'Veuillez entrer votre nom complet';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneNumberAlgeria => 'Numéro de téléphone (Algérie)';

  @override
  String get pleaseEnterPhoneNumber =>
      'Veuillez entrer votre numéro de téléphone';

  @override
  String get pleaseEnterValidAlgerianPhone =>
      'Veuillez entrer un numéro de téléphone algérien valide';

  @override
  String get algerianPhoneOnly =>
      'Seuls les numéros de téléphone algériens sont pris en charge.';

  @override
  String get verified => 'Vérifié ✓';

  @override
  String get email => 'E-mail';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get verifyOTP => 'Vérifier OTP';

  @override
  String verifyOTPCountdown(Object seconds) {
    return 'Vérifier OTP ($seconds)';
  }

  @override
  String get resendOTP => 'Renvoyer OTP';

  @override
  String get sendOTP => 'Envoyer OTP';

  @override
  String get enterOTP => 'Entrer OTP';

  @override
  String get otpSentSuccessfully => 'OTP envoyé avec succès !';

  @override
  String get failedToSendOTP =>
      'Échec de l\'envoi de l\'OTP. Veuillez réessayer.';

  @override
  String get phoneNumberVerified => 'Numéro de téléphone vérifié avec succès !';

  @override
  String get invalidOTP => 'OTP invalide. Veuillez réessayer.';

  @override
  String get phoneVerificationRequired => 'Vérification du téléphone requise';

  @override
  String get phoneVerificationMessage =>
      'Vous avez changé votre numéro de téléphone. Veuillez le vérifier pour continuer.';

  @override
  String get verifyNewPhoneFirst =>
      'Veuillez d\'abord vérifier votre nouveau numéro de téléphone.';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get sendingVerification => 'Envoi de la vérification...';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get updatingProfile => 'Mise à jour du profil...';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès !';

  @override
  String get profileUpdateFailed => 'Échec de la mise à jour du profil';

  @override
  String get reportAnIncident => 'Signaler un incident';

  @override
  String get reportRouteIncident => 'signaler un incident de route';

  @override
  String get provideIncidentDetails =>
      'veuillez fournir des détails sur l\'incident que vous avez rencontré';

  @override
  String get incidentCategory => 'Catégorie d\'incident';

  @override
  String get incidentType => 'Type d\'incident';

  @override
  String get carType => 'Type de voiture';

  @override
  String get vehicleType => 'Type de véhicule';

  @override
  String get descriptionOptional => 'Description (optionnel)';

  @override
  String get photosOfIncident => 'Photos de l\'incident';

  @override
  String get photoRequired =>
      'au moins une photo est requise pour soumettre\nle rapport d\'incident';

  @override
  String get addMorePhotos => 'Ajouter plus de photos';

  @override
  String get locationOfIncident => 'Emplacement de l\'incident';

  @override
  String get locationObtained => 'Emplacement obtenu';

  @override
  String get locationMandatory =>
      'L\'emplacement est obligatoire pour signaler un incident\nveuillez autoriser l\'accès à la localisation pour continuer';

  @override
  String get getLocation => 'Obtenir l\'emplacement';

  @override
  String get updatingLocation => 'Mise à jour de l\'emplacement...';

  @override
  String get reportNow => 'Signaler maintenant';

  @override
  String get uploadingPhotos => 'Téléchargement des photos...';

  @override
  String get pleaseSelectIncidentCategory =>
      'Veuillez sélectionner une catégorie d\'incident';

  @override
  String get pleaseSelectIncidentType =>
      'Veuillez sélectionner un type d\'incident';

  @override
  String get pleaseSelectVehicleType =>
      'Veuillez sélectionner un type de véhicule';

  @override
  String get photoRequiredError => 'Au moins une photo est requise';

  @override
  String get locationMandatoryError =>
      'L\'emplacement est obligatoire pour signaler un incident';

  @override
  String get incidentReportSubmitted =>
      'Rapport d\'incident soumis avec succès !';

  @override
  String get failedToSubmitReport => 'Échec de la soumission du rapport';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get errorTakingPhoto => 'Erreur lors de la prise de photo';

  @override
  String photoAdded(Object count) {
    return 'Photo ajoutée ! Total : $count';
  }

  @override
  String photoRemoved(Object count) {
    return 'Photo supprimée ! Restant : $count';
  }

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés.';

  @override
  String get locationPermissionsDenied =>
      'Les autorisations de localisation sont refusées';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'Les autorisations de localisation sont refusées définitivement';

  @override
  String get failedToGetLocation => 'Échec de l\'obtention de l\'emplacement';

  @override
  String get errorUploadingPhotos => 'Erreur lors du téléchargement des photos';

  @override
  String get loading => 'Chargement...';

  @override
  String get loadingIncidentCategories =>
      'Chargement des catégories d\'incident...';

  @override
  String get gettingLocation => 'Obtention de l\'emplacement...';

  @override
  String get user => 'Utilisateur';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get finalConfirmation => 'Confirmation finale';

  @override
  String get accountDeletionWarning =>
      'Cette action ne peut pas être annulée. Votre compte et toutes les données associées seront supprimés définitivement.\n\nÊtes-vous sûr de vouloir supprimer votre compte ?';

  @override
  String get deletingAccount => 'Suppression du compte...';

  @override
  String get accountDeletedPermanently =>
      'Votre compte a été supprimé définitivement';

  @override
  String get failedToDeleteAccount => 'Échec de la suppression du compte';

  @override
  String get goBackToLogin => 'Retour à la connexion';

  @override
  String get failedToSendMagicLink => 'Échec de l\'envoi du lien magique';

  @override
  String get googleSignInFailed => 'Échec de la connexion avec Google';

  @override
  String get resendLinkFailed => 'Échec du renvoi du lien magique';

  @override
  String get selectIncidentCategory => 'Sélectionner la catégorie d\'incident';

  @override
  String get selectIncidentType => 'Sélectionner le type d\'incident';

  @override
  String get selectVehicleType => 'Sélectionner le type de véhicule';

  @override
  String get describeIncident => 'Décrivez l\'incident en détail';

  @override
  String get later => 'Plus tard';

  @override
  String get allow => 'Autoriser';

  @override
  String get permissionRequired => 'Autorisation requise';

  @override
  String get settings => 'Paramètres';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get language => 'Langue';

  @override
  String get loggingOut => 'Déconnexion en cours...';

  @override
  String get enterPhoneNumber => 'Entrez le numéro de téléphone';

  @override
  String get enterEmailAddress => 'Entrez votre adresse e-mail';

  @override
  String get deleteAccountConfirmation =>
      'Pour des raisons de sécurité, nous enverrons un lien de vérification à votre adresse e-mail.\n\nVeuillez vérifier votre e-mail et cliquer sur le lien pour confirmer la suppression du compte.';

  @override
  String get sendVerificationEmail => 'Envoyer un e-mail de vérification';

  @override
  String get verificationEmailSent =>
      'E-mail de vérification envoyé ! Vérifiez votre boîte de réception et cliquez sur le lien pour confirmer la suppression.';

  @override
  String get failedToSendVerificationEmail =>
      'Échec de l\'envoi de l\'e-mail de vérification';

  @override
  String get phoneNumberChanged =>
      'Vous avez changé votre numéro de téléphone. Veuillez le vérifier pour continuer.';

  @override
  String resendOTPCountdown(Object seconds) {
    return 'Renvoyer OTP ($seconds s)';
  }

  @override
  String get phoneVerifiedSuccessfully =>
      'Numéro de téléphone vérifié avec succès !';

  @override
  String get profileUpdatedAndVerified =>
      'Profil mis à jour et vérifié avec succès !';

  @override
  String get profileUpdatedButVerificationFailed =>
      'Profil mis à jour mais la vérification a échoué. Veuillez réessayer.';

  @override
  String get pleaseEnterValidPhoneNumber =>
      'Veuillez entrer un numéro de téléphone valide';
}
