import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/services/firebase/http_downloader.dart';
import 'package:path_provider/path_provider.dart';

class CloudStorageService {

  Future<CloudStorageResult> uploadImage({
    required File imageToUpload,
    required String title,
  }) async {
    var imageFileName = title + ' ' + DateTime.now().toIso8601String();
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageFileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    var downloadUrl = await storageSnapshot.ref.getDownloadURL();
    var url = downloadUrl.toString();
    return CloudStorageResult(
      imageUrl: url,
      imageFileName: imageFileName,
    );
  }
  final httpDownloader = HttpDownloader();
  Future<String> downloadFile(
      VoidCallback onError, VoidCallback onComplete, String folderName, String path,
      {bool downloadFromHttp  = false}) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String folder = appDocDir.path + '/' + '$folderName/';

    if(downloadFromHttp) {
      final  savePath = folder+path;
      final result = await httpDownloader.downloadFile(path, savePath);
      return result ? savePath : '';
    } else {
      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.refFromURL(
          'gs://rigel-psy.appspot.com/$path');
      final String filePath = appDocDir.path + '/' + '$path';

      final File tempFile = File(filePath);
      try {
        if (!(await Directory(folder).exists()))
          await Directory(folder).create();
        await ref.writeToFile(tempFile);
        await tempFile.create();
        onComplete();
        return filePath;
      } on firebase_core.FirebaseException {
        onError();
        return '';
      }
    }

  }

  Future<String> getUrl(String path) async {
    try {
    final firebase_storage.Reference ref =
    firebase_storage.FirebaseStorage.instance.refFromURL('gs://rigel-psy.appspot.com/$path');
      return ref.getDownloadURL();
    } on firebase_core.FirebaseException {
      return '';
    }

  }
}

class CloudStorageResult {
  final String imageUrl;
  final String imageFileName;
  CloudStorageResult({required this.imageUrl, required this.imageFileName});
}