import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleIsAvailableService {
  static Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }
}