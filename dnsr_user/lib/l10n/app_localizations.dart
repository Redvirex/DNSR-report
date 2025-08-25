import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DNSR Report'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @privacyStatement.
  ///
  /// In en, this message translates to:
  /// **'Privacy statement'**
  String get privacyStatement;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @bySigningIn.
  ///
  /// In en, this message translates to:
  /// **'By signing in, I agree to the company\'s'**
  String get bySigningIn;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @accountFound.
  ///
  /// In en, this message translates to:
  /// **'Account found! Click to send sign-in link'**
  String get accountFound;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New user! Click to create account'**
  String get newUser;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @signInLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a sign-in link to your mailbox.\nPlease check your inbox for the message.\nBe sure to check your spam/junk folder as well.'**
  String get signInLinkSent;

  /// No description provided for @createAccountLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a magic link to create your account.\nPlease check your inbox for the message.\nBe sure to check your spam/junk folder as well.'**
  String get createAccountLinkSent;

  /// No description provided for @resendLink.
  ///
  /// In en, this message translates to:
  /// **'Re-send link'**
  String get resendLink;

  /// No description provided for @resendLinkCountdown.
  ///
  /// In en, this message translates to:
  /// **'Re-send link ({seconds}s)'**
  String resendLinkCountdown(Object seconds);

  /// No description provided for @yourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'your email address'**
  String get yourEmailAddress;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logoutFailed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @hiWelcomeToDNSR.
  ///
  /// In en, this message translates to:
  /// **'Hi, Welcome to DNSR Report'**
  String get hiWelcomeToDNSR;

  /// No description provided for @chooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option below to\nget started'**
  String get chooseOption;

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report An Incident'**
  String get reportIncident;

  /// No description provided for @reportIncidentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'report route incidents and hazards'**
  String get reportIncidentSubtitle;

  /// No description provided for @routeCodes.
  ///
  /// In en, this message translates to:
  /// **'Route Codes'**
  String get routeCodes;

  /// No description provided for @routeCodesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'read the route code or download it'**
  String get routeCodesSubtitle;

  /// No description provided for @routeCodesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Route Codes feature coming soon!'**
  String get routeCodesComingSoon;

  /// No description provided for @profileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Profile Incomplete'**
  String get profileIncomplete;

  /// No description provided for @completeProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to access all features'**
  String get completeProfileMessage;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit My Profile'**
  String get editMyProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @firstNameLastName.
  ///
  /// In en, this message translates to:
  /// **'\'first name\' \'last name\''**
  String get firstNameLastName;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberAlgeria.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Algeria)'**
  String get phoneNumberAlgeria;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterValidAlgerianPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Algerian phone number'**
  String get pleaseEnterValidAlgerianPhone;

  /// No description provided for @algerianPhoneOnly.
  ///
  /// In en, this message translates to:
  /// **'Only Algerian phone numbers are supported.'**
  String get algerianPhoneOnly;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified ✓'**
  String get verified;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @verifyOTPCountdown.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP ({seconds})'**
  String verifyOTPCountdown(Object seconds);

  /// No description provided for @resendOTP.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOTP;

  /// No description provided for @sendOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOTP;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTP;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully!'**
  String get otpSentSuccessfully;

  /// No description provided for @failedToSendOTP.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get failedToSendOTP;

  /// No description provided for @phoneNumberVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified successfully!'**
  String get phoneNumberVerified;

  /// No description provided for @invalidOTP.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOTP;

  /// No description provided for @phoneVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification Required'**
  String get phoneVerificationRequired;

  /// No description provided for @phoneVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have changed your phone number. Please verify it to continue.'**
  String get phoneVerificationMessage;

  /// No description provided for @verifyNewPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your new phone number first.'**
  String get verifyNewPhoneFirst;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @sendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Sending verification...'**
  String get sendingVerification;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @updatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Updating Profile...'**
  String get updatingProfile;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @reportAnIncident.
  ///
  /// In en, this message translates to:
  /// **'Report An Incident'**
  String get reportAnIncident;

  /// No description provided for @reportRouteIncident.
  ///
  /// In en, this message translates to:
  /// **'report a route incident'**
  String get reportRouteIncident;

  /// No description provided for @provideIncidentDetails.
  ///
  /// In en, this message translates to:
  /// **'please provide details about the incident you encounterd'**
  String get provideIncidentDetails;

  /// No description provided for @incidentCategory.
  ///
  /// In en, this message translates to:
  /// **'Incident Category'**
  String get incidentCategory;

  /// No description provided for @incidentType.
  ///
  /// In en, this message translates to:
  /// **'Incident Type'**
  String get incidentType;

  /// No description provided for @carType.
  ///
  /// In en, this message translates to:
  /// **'Car Type'**
  String get carType;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @photosOfIncident.
  ///
  /// In en, this message translates to:
  /// **'Photos of the incident'**
  String get photosOfIncident;

  /// No description provided for @photoRequired.
  ///
  /// In en, this message translates to:
  /// **'at least one photo is required to submit\nthe incident report'**
  String get photoRequired;

  /// No description provided for @addMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add More Photos'**
  String get addMorePhotos;

  /// No description provided for @locationOfIncident.
  ///
  /// In en, this message translates to:
  /// **'Location of the incident'**
  String get locationOfIncident;

  /// No description provided for @locationObtained.
  ///
  /// In en, this message translates to:
  /// **'Location obtained'**
  String get locationObtained;

  /// No description provided for @locationMandatory.
  ///
  /// In en, this message translates to:
  /// **'Location is mandatory for incident reporting\nallow location access to continue'**
  String get locationMandatory;

  /// No description provided for @getLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Location'**
  String get getLocation;

  /// No description provided for @updatingLocation.
  ///
  /// In en, this message translates to:
  /// **'Updating location...'**
  String get updatingLocation;

  /// No description provided for @reportNow.
  ///
  /// In en, this message translates to:
  /// **'Report Now'**
  String get reportNow;

  /// No description provided for @uploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Uploading Photos...'**
  String get uploadingPhotos;

  /// No description provided for @pleaseSelectIncidentCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select an incident category'**
  String get pleaseSelectIncidentCategory;

  /// No description provided for @pleaseSelectIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Please select an incident type'**
  String get pleaseSelectIncidentType;

  /// No description provided for @pleaseSelectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle type'**
  String get pleaseSelectVehicleType;

  /// No description provided for @photoRequiredError.
  ///
  /// In en, this message translates to:
  /// **'At least one photo is required'**
  String get photoRequiredError;

  /// No description provided for @locationMandatoryError.
  ///
  /// In en, this message translates to:
  /// **'Location is mandatory for incident reporting'**
  String get locationMandatoryError;

  /// No description provided for @incidentReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Incident report submitted successfully!'**
  String get incidentReportSubmitted;

  /// No description provided for @failedToSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report'**
  String get failedToSubmitReport;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @errorTakingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo'**
  String get errorTakingPhoto;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added! Total: {count}'**
  String photoAdded(Object count);

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed! Remaining: {count}'**
  String photoRemoved(Object count);

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @failedToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location'**
  String get failedToGetLocation;

  /// No description provided for @errorUploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Error uploading photos'**
  String get errorUploadingPhotos;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingIncidentCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading incident categories...'**
  String get loadingIncidentCategories;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @finalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// No description provided for @accountDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Your account and all associated data will be permanently deleted.\n\nAre you sure you want to delete your account?'**
  String get accountDeletionWarning;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting Account...'**
  String get deletingAccount;

  /// No description provided for @accountDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Your account has been permanently deleted'**
  String get accountDeletedPermanently;

  /// No description provided for @failedToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get failedToDeleteAccount;

  /// No description provided for @goBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go back to login'**
  String get goBackToLogin;

  /// No description provided for @failedToSendMagicLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to send magic link'**
  String get failedToSendMagicLink;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleSignInFailed;

  /// No description provided for @resendLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend magic link'**
  String get resendLinkFailed;

  /// No description provided for @selectIncidentCategory.
  ///
  /// In en, this message translates to:
  /// **'Select incident category'**
  String get selectIncidentCategory;

  /// No description provided for @selectIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Select incident type'**
  String get selectIncidentType;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle type'**
  String get selectVehicleType;

  /// No description provided for @describeIncident.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident in detail'**
  String get describeIncident;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'For security, we\'ll send a verification link to your email address.\n\nPlease check your email and click the link to confirm account deletion.'**
  String get deleteAccountConfirmation;

  /// No description provided for @sendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Email'**
  String get sendVerificationEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox and click the link to confirm deletion.'**
  String get verificationEmailSent;

  /// No description provided for @failedToSendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email'**
  String get failedToSendVerificationEmail;

  /// No description provided for @phoneNumberChanged.
  ///
  /// In en, this message translates to:
  /// **'You have changed your phone number. Please verify it to continue.'**
  String get phoneNumberChanged;

  /// No description provided for @resendOTPCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP ({seconds} s)'**
  String resendOTPCountdown(Object seconds);

  /// No description provided for @phoneVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified successfully!'**
  String get phoneVerifiedSuccessfully;

  /// No description provided for @profileUpdatedAndVerified.
  ///
  /// In en, this message translates to:
  /// **'Profile updated and verified successfully!'**
  String get profileUpdatedAndVerified;

  /// No description provided for @profileUpdatedButVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile updated but verification failed. Please try again.'**
  String get profileUpdatedButVerificationFailed;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
