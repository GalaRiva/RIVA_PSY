import 'package:dio/dio.dart';

class HttpDownloader {
  static const _BASE_URL = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

  Future<bool> downloadFile(String filePath, String savePath) async {
    try {
      await Dio().download(
        _BASE_URL + filePath,
        savePath,
      );
      return true;
    } catch (e) {
      print(e);
      return false;

    }
  }
}
