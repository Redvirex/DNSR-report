// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تقرير DNSR';

  @override
  String get welcome => 'مرحباً';

  @override
  String get continueButton => 'متابعة';

  @override
  String get continueWithGoogle => 'متابعة مع جوجل';

  @override
  String get or => 'أو';

  @override
  String get privacyStatement => 'بيان الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get bySigningIn => 'بتسجيل الدخول، أوافق على';

  @override
  String get and => 'و';

  @override
  String get accountFound =>
      'تم العثور على الحساب! انقر لإرسال رابط تسجيل الدخول';

  @override
  String get newUser => 'مستخدم جديد! انقر لإنشاء حساب';

  @override
  String get checkYourInbox => 'تحقق من صندوق الوارد';

  @override
  String get signInLinkSent =>
      'لقد أرسلنا رابط تسجيل الدخول إلى بريدك الإلكتروني.\nيرجى التحقق من صندوق الوارد.\nتأكد من فحص مجلد الرسائل غير المرغوب فيها أيضاً.';

  @override
  String get createAccountLinkSent =>
      'لقد أرسلنا رابطاً سحرياً لإنشاء حسابك.\nيرجى التحقق من صندوق الوارد.\nتأكد من فحص مجلد الرسائل غير المرغوب فيها أيضاً.';

  @override
  String get resendLink => 'إعادة إرسال الرابط';

  @override
  String resendLinkCountdown(Object seconds) {
    return 'إعادة إرسال الرابط ($secondsث)';
  }

  @override
  String get yourEmailAddress => 'عنوان بريدك الإلكتروني';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال عنوان بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال عنوان بريد إلكتروني صالح';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من أنك تريد تسجيل الخروج؟';

  @override
  String get loggedOutSuccessfully => 'تم تسجيل الخروج بنجاح';

  @override
  String get logoutFailed => 'فشل في تسجيل الخروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get hiWelcomeToDNSR => 'مرحباً، أهلاً بك في DNSR Report';

  @override
  String get chooseOption => 'اختر خياراً أدناه\nللبدء';

  @override
  String get reportIncident => 'الإبلاغ عن حادثة';

  @override
  String get reportIncidentSubtitle => 'الإبلاغ عن حوادث ومخاطر الطريق';

  @override
  String get routeCodes => 'رموز الطريق';

  @override
  String get routeCodesSubtitle => 'قراءة رمز الطريق أو تحميله';

  @override
  String get routeCodesComingSoon => 'ميزة رموز الطريق قريباً!';

  @override
  String get profileIncomplete => 'الملف الشخصي غير مكتمل';

  @override
  String get completeProfileMessage =>
      'يرجى إكمال ملفك الشخصي للوصول إلى جميع الميزات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get editMyProfile => 'تعديل ملفي الشخصي';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get firstNameLastName => '\'الاسم الأول\' \'اسم العائلة\'';

  @override
  String get pleaseEnterFullName => 'يرجى إدخال اسمك الكامل';

  @override
  String get phone => 'الهاتف';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneNumberAlgeria => 'رقم الهاتف (الجزائر)';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم هاتفك';

  @override
  String get pleaseEnterValidAlgerianPhone => 'يرجى إدخال رقم هاتف جزائري صحيح';

  @override
  String get algerianPhoneOnly => 'فقط أرقام الهاتف الجزائرية مدعومة.';

  @override
  String get verified => 'تم التحقق ✓';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get verifyOTP => 'تأكيد الرمز';

  @override
  String verifyOTPCountdown(Object seconds) {
    return 'تحقق من OTP ($seconds)';
  }

  @override
  String get resendOTP => 'إعادة إرسال الرمز';

  @override
  String get sendOTP => 'إرسال رمز التأكيد';

  @override
  String get enterOTP => 'أدخل OTP';

  @override
  String get otpSentSuccessfully => 'تم إرسال رمز التأكيد بنجاح!';

  @override
  String get failedToSendOTP =>
      'فشل في إرسال رمز التأكيد. يرجى المحاولة مرة أخرى.';

  @override
  String get phoneNumberVerified => 'تم التحقق من رقم الهاتف بنجاح!';

  @override
  String get invalidOTP => 'رمز التأكيد غير صحيح. يرجى المحاولة مرة أخرى.';

  @override
  String get phoneVerificationRequired => 'مطلوب تأكيد رقم الهاتف';

  @override
  String get phoneVerificationMessage =>
      'لقد غيرت رقم هاتفك. يرجى التحقق منه للمتابعة.';

  @override
  String get verifyNewPhoneFirst => 'يرجى التحقق من رقم هاتفك الجديد أولاً.';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get sendingVerification => 'جاري إرسال التأكيد...';

  @override
  String get updateProfile => 'تحديث الملف الشخصي';

  @override
  String get updatingProfile => 'تحديث الملف الشخصي...';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String get profileUpdateFailed => 'فشل في تحديث الملف الشخصي';

  @override
  String get reportAnIncident => 'الإبلاغ عن حادثة';

  @override
  String get reportRouteIncident => 'الإبلاغ عن حادثة طريق';

  @override
  String get provideIncidentDetails =>
      'يرجى تقديم تفاصيل حول الحادثة التي واجهتها';

  @override
  String get incidentCategory => 'فئة الحادثة';

  @override
  String get incidentType => 'نوع الحادثة';

  @override
  String get carType => 'نوع السيارة';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get photosOfIncident => 'صور الحادثة';

  @override
  String get photoRequired =>
      'مطلوب صورة واحدة على الأقل لتقديم\nتقرير الحادثة';

  @override
  String get addMorePhotos => 'إضافة المزيد من الصور';

  @override
  String get locationOfIncident => 'موقع الحادثة';

  @override
  String get locationObtained => 'تم الحصول على الموقع';

  @override
  String get locationMandatory =>
      'الموقع إلزامي للإبلاغ عن الحادثة\nيرجى السماح بالوصول إلى الموقع للمتابعة';

  @override
  String get getLocation => 'الحصول على الموقع';

  @override
  String get updatingLocation => 'تحديث الموقع...';

  @override
  String get reportNow => 'الإبلاغ الآن';

  @override
  String get uploadingPhotos => 'تحميل الصور...';

  @override
  String get pleaseSelectIncidentCategory => 'يرجى اختيار فئة الحادثة';

  @override
  String get pleaseSelectIncidentType => 'يرجى اختيار نوع الحادثة';

  @override
  String get pleaseSelectVehicleType => 'يرجى اختيار نوع المركبة';

  @override
  String get photoRequiredError => 'مطلوب صورة واحدة على الأقل';

  @override
  String get locationMandatoryError => 'الموقع إلزامي للإبلاغ عن الحادثة';

  @override
  String get incidentReportSubmitted => 'تم تقديم تقرير الحادثة بنجاح!';

  @override
  String get failedToSubmitReport => 'فشل في تقديم التقرير';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get errorTakingPhoto => 'خطأ في التقاط الصورة';

  @override
  String photoAdded(Object count) {
    return 'تمت إضافة الصورة! المجموع: $count';
  }

  @override
  String photoRemoved(Object count) {
    return 'تم حذف الصورة! المتبقي: $count';
  }

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة.';

  @override
  String get locationPermissionsDenied => 'تم رفض أذونات الموقع';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'تم رفض أذونات الموقع نهائياً';

  @override
  String get failedToGetLocation => 'فشل في الحصول على الموقع';

  @override
  String get errorUploadingPhotos => 'خطأ في تحميل الصور';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get loadingIncidentCategories => 'تحميل فئات الحادثة...';

  @override
  String get gettingLocation => 'الحصول على الموقع...';

  @override
  String get user => 'المستخدم';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get finalConfirmation => 'التأكيد النهائي';

  @override
  String get accountDeletionWarning =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف حسابك وجميع البيانات المرتبطة به نهائياً.\n\nهل أنت متأكد من أنك تريد حذف حسابك؟';

  @override
  String get deletingAccount => 'حذف الحساب...';

  @override
  String get accountDeletedPermanently => 'تم حذف حسابك نهائياً';

  @override
  String get failedToDeleteAccount => 'فشل في حذف الحساب';

  @override
  String get goBackToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get failedToSendMagicLink => 'فشل في إرسال الرابط السحري';

  @override
  String get googleSignInFailed => 'فشل في تسجيل الدخول بجوجل';

  @override
  String get resendLinkFailed => 'فشل في إعادة إرسال الرابط السحري';

  @override
  String get selectIncidentCategory => 'اختر فئة الحادثة';

  @override
  String get selectIncidentType => 'اختر نوع الحادثة';

  @override
  String get selectVehicleType => 'اختر نوع المركبة';

  @override
  String get describeIncident => 'اوصف الحادثة بالتفصيل';

  @override
  String get later => 'لاحقاً';

  @override
  String get allow => 'السماح';

  @override
  String get permissionRequired => 'إذن مطلوب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get language => 'اللغة';

  @override
  String get loggingOut => 'جاري تسجيل الخروج...';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get enterEmailAddress => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get deleteAccountConfirmation =>
      'لأغراض الأمان، سنرسل رابط تأكيد إلى عنوان بريدك الإلكتروني.\n\nيرجى التحقق من بريدك الإلكتروني والنقر على الرابط لتأكيد حذف الحساب.';

  @override
  String get sendVerificationEmail => 'إرسال بريد التأكيد';

  @override
  String get verificationEmailSent =>
      'تم إرسال بريد التأكيد! تحقق من صندوق الوارد وانقر على الرابط لتأكيد الحذف.';

  @override
  String get failedToSendVerificationEmail => 'فشل في إرسال بريد التأكيد';

  @override
  String get phoneNumberChanged =>
      'لقد قمت بتغيير رقم هاتفك. يرجى تأكيده للمتابعة.';

  @override
  String resendOTPCountdown(Object seconds) {
    return 'إعادة إرسال الرمز ($seconds ث)';
  }

  @override
  String get phoneVerifiedSuccessfully => 'تم تأكيد رقم الهاتف بنجاح!';

  @override
  String get profileUpdatedAndVerified =>
      'تم تحديث الملف الشخصي وتأكيده بنجاح!';

  @override
  String get profileUpdatedButVerificationFailed =>
      'تم تحديث الملف الشخصي ولكن فشل التأكيد. يرجى المحاولة مرة أخرى.';

  @override
  String get pleaseEnterValidPhoneNumber => 'يرجى إدخال رقم هاتف صحيح';
}
