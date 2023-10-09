import 'package:dio/dio.dart';

class HttpDownloader {
  static const _BASE_URL = 'http://95.181.164.171/';

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
