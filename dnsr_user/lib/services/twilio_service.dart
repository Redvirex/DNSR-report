import 'package:twilio_flutter/twilio_flutter.dart';
import '../config/app_config.dart';
import 'dart:developer';

class TwilioService {
  static TwilioService? _instance;
  static TwilioService get instance => _instance ??= TwilioService._();

  late final TwilioFlutter _twilioFlutter;

  TwilioService._() {
    _twilioFlutter = TwilioFlutter(
      accountSid: AppConfig.twilioAccountSid,
      authToken: AppConfig.twilioAuthToken,
      twilioNumber: AppConfig.twilioPhoneNumber,
    );
  }

  Future<bool> sendOTP(String phoneNumber) async {
    try {
      TwilioResponse response = await _twilioFlutter.sendVerificationCode(
        verificationServiceId: AppConfig.twilioVerifyServiceSid,
        recipient: phoneNumber,
        verificationChannel: VerificationChannel.SMS,
      );

      if (response.errorData != null) {
        String errorMessage =
            response.errorData!.message ?? 'Unknown Twilio error';
        int? errorCode = response.errorData!.code;

        log("$errorCode : $errorMessage");
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String code) async {
    try {
      TwilioResponse response = await _twilioFlutter.verifyCode(
        verificationServiceId: AppConfig.twilioVerifyServiceSid,
        recipient: phoneNumber,
        code: code,
      );

      if (response.errorData != null) {
        String errorMessage =
            response.errorData!.message ?? 'Unknown Twilio error';
        int? errorCode = response.errorData!.code;

        log("$errorCode : $errorMessage");
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  String formatPhoneNumber(String phoneNumber, String countryCode) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (!cleanNumber.startsWith(countryCode.replaceAll('+', ''))) {
      cleanNumber = '${countryCode.replaceAll('+', '')}$cleanNumber';
    }

    return '+$cleanNumber';
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+[1-9]\d{9,14}$');
    return regex.hasMatch(phoneNumber);
  }
}
