import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';

extension StringExtension on String {
  String md5() {
    return generateMd5(this);
  }

  String t () {
    return this.tr();
  }

}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
