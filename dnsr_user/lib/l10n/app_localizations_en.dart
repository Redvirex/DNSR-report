// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DNSR Report';

  @override
  String get welcome => 'Welcome';

  @override
  String get continueButton => 'Continue';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'or';

  @override
  String get privacyStatement => 'Privacy statement';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get bySigningIn => 'By signing in, I agree to the company\'s';

  @override
  String get and => 'and';

  @override
  String get accountFound => 'Account found! Click to send sign-in link';

  @override
  String get newUser => 'New user! Click to create account';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String get signInLinkSent =>
      'We\'ve sent a sign-in link to your mailbox.\nPlease check your inbox for the message.\nBe sure to check your spam/junk folder as well.';

  @override
  String get createAccountLinkSent =>
      'We\'ve sent a magic link to create your account.\nPlease check your inbox for the message.\nBe sure to check your spam/junk folder as well.';

  @override
  String get resendLink => 'Re-send link';

  @override
  String resendLinkCountdown(Object seconds) {
    return 'Re-send link (${seconds}s)';
  }

  @override
  String get yourEmailAddress => 'your email address';

  @override
  String get pleaseEnterEmail => 'Please enter your email address';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get profile => 'Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get loggedOutSuccessfully => 'Logged out successfully';

  @override
  String get logoutFailed => 'Logout failed';

  @override
  String get cancel => 'Cancel';

  @override
  String get hiWelcomeToDNSR => 'Hi, Welcome to DNSR Report';

  @override
  String get chooseOption => 'Choose an option below to\nget started';

  @override
  String get reportIncident => 'Report An Incident';

  @override
  String get reportIncidentSubtitle => 'report route incidents and hazards';

  @override
  String get routeCodes => 'Route Codes';

  @override
  String get routeCodesSubtitle => 'read the route code or download it';

  @override
  String get routeCodesComingSoon => 'Route Codes feature coming soon!';

  @override
  String get profileIncomplete => 'Profile Incomplete';

  @override
  String get completeProfileMessage =>
      'Please complete your profile to access all features';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editMyProfile => 'Edit My Profile';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get fullName => 'Full Name';

  @override
  String get firstNameLastName => '\'first name\' \'last name\'';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberAlgeria => 'Phone Number (Algeria)';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterValidAlgerianPhone =>
      'Please enter a valid Algerian phone number';

  @override
  String get algerianPhoneOnly => 'Only Algerian phone numbers are supported.';

  @override
  String get verified => 'Verified ✓';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get verifyOTP => 'Verify OTP';

  @override
  String verifyOTPCountdown(Object seconds) {
    return 'Verify OTP ($seconds)';
  }

  @override
  String get resendOTP => 'Resend OTP';

  @override
  String get sendOTP => 'Send OTP';

  @override
  String get enterOTP => 'Enter OTP';

  @override
  String get otpSentSuccessfully => 'OTP sent successfully!';

  @override
  String get failedToSendOTP => 'Failed to send OTP. Please try again.';

  @override
  String get phoneNumberVerified => 'Phone number verified successfully!';

  @override
  String get invalidOTP => 'Invalid OTP. Please try again.';

  @override
  String get phoneVerificationRequired => 'Phone Verification Required';

  @override
  String get phoneVerificationMessage =>
      'You have changed your phone number. Please verify it to continue.';

  @override
  String get verifyNewPhoneFirst =>
      'Please verify your new phone number first.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get sendingVerification => 'Sending verification...';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get updatingProfile => 'Updating Profile...';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get reportAnIncident => 'Report An Incident';

  @override
  String get reportRouteIncident => 'report a route incident';

  @override
  String get provideIncidentDetails =>
      'please provide details about the incident you encounterd';

  @override
  String get incidentCategory => 'Incident Category';

  @override
  String get incidentType => 'Incident Type';

  @override
  String get carType => 'Car Type';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get photosOfIncident => 'Photos of the incident';

  @override
  String get photoRequired =>
      'at least one photo is required to submit\nthe incident report';

  @override
  String get addMorePhotos => 'Add More Photos';

  @override
  String get locationOfIncident => 'Location of the incident';

  @override
  String get locationObtained => 'Location obtained';

  @override
  String get locationMandatory =>
      'Location is mandatory for incident reporting\nallow location access to continue';

  @override
  String get getLocation => 'Get Location';

  @override
  String get updatingLocation => 'Updating location...';

  @override
  String get reportNow => 'Report Now';

  @override
  String get uploadingPhotos => 'Uploading Photos...';

  @override
  String get pleaseSelectIncidentCategory =>
      'Please select an incident category';

  @override
  String get pleaseSelectIncidentType => 'Please select an incident type';

  @override
  String get pleaseSelectVehicleType => 'Please select a vehicle type';

  @override
  String get photoRequiredError => 'At least one photo is required';

  @override
  String get locationMandatoryError =>
      'Location is mandatory for incident reporting';

  @override
  String get incidentReportSubmitted =>
      'Incident report submitted successfully!';

  @override
  String get failedToSubmitReport => 'Failed to submit report';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get errorTakingPhoto => 'Error taking photo';

  @override
  String photoAdded(Object count) {
    return 'Photo added! Total: $count';
  }

  @override
  String photoRemoved(Object count) {
    return 'Photo removed! Remaining: $count';
  }

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionsDenied => 'Location permissions are denied';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'Location permissions are permanently denied';

  @override
  String get failedToGetLocation => 'Failed to get location';

  @override
  String get errorUploadingPhotos => 'Error uploading photos';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingIncidentCategories => 'Loading incident categories...';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get user => 'User';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get accountDeletionWarning =>
      'This action cannot be undone. Your account and all associated data will be permanently deleted.\n\nAre you sure you want to delete your account?';

  @override
  String get deletingAccount => 'Deleting Account...';

  @override
  String get accountDeletedPermanently =>
      'Your account has been permanently deleted';

  @override
  String get failedToDeleteAccount => 'Failed to delete account';

  @override
  String get goBackToLogin => 'Go back to login';

  @override
  String get failedToSendMagicLink => 'Failed to send magic link';

  @override
  String get googleSignInFailed => 'Google sign-in failed';

  @override
  String get resendLinkFailed => 'Failed to resend magic link';

  @override
  String get selectIncidentCategory => 'Select incident category';

  @override
  String get selectIncidentType => 'Select incident type';

  @override
  String get selectVehicleType => 'Select vehicle type';

  @override
  String get describeIncident => 'Describe the incident in detail';

  @override
  String get later => 'Later';

  @override
  String get allow => 'Allow';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get settings => 'Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get language => 'Language';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get deleteAccountConfirmation =>
      'For security, we\'ll send a verification link to your email address.\n\nPlease check your email and click the link to confirm account deletion.';

  @override
  String get sendVerificationEmail => 'Send Verification Email';

  @override
  String get verificationEmailSent =>
      'Verification email sent! Check your inbox and click the link to confirm deletion.';

  @override
  String get failedToSendVerificationEmail =>
      'Failed to send verification email';

  @override
  String get phoneNumberChanged =>
      'You have changed your phone number. Please verify it to continue.';

  @override
  String resendOTPCountdown(Object seconds) {
    return 'Resend OTP ($seconds s)';
  }

  @override
  String get phoneVerifiedSuccessfully => 'Phone number verified successfully!';

  @override
  String get profileUpdatedAndVerified =>
      'Profile updated and verified successfully!';

  @override
  String get profileUpdatedButVerificationFailed =>
      'Profile updated but verification failed. Please try again.';

  @override
  String get pleaseEnterValidPhoneNumber => 'Please enter a valid phone number';
}
