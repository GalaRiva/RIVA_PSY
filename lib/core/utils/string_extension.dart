import 'dart:convert';
import 'package:crypto/crypto.dart';

extension StringExtension on String {
  String md5() {
    return generateMd5(this);
  }
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
