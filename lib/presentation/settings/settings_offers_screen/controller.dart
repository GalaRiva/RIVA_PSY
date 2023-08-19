import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/firebase/firebase_cloud_storage.dart';
import '../../../core/user_data/user.dart';

class K10Controller extends GetxController {

final model = Get.put(K10Model().obs);

Future getImage () async {
  final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
  model.value.fileName = image?.name ?? 'image.png';
  model.value.file = File(image!.path);

  this.update();
}

Future createOffer () async {
  final _service = CloudStorageService();
  final collection = FirebaseFirestore.instance.collection('Offers');
  CloudStorageResult storageResult;
    storageResult = await _service.uploadImage(
        imageToUpload: model.value.file!, title: '${CurrentUser.repo.userId()} ${model.value.fileName}');


  await collection.doc('${CurrentUser.repo.userId()} ${DateTime.now().toIso8601String()}').set({
    "text": model.value.controller.text,
    "image_source": storageResult.imageUrl,
    "image_name": storageResult.imageFileName
  });
}

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class K10Model {
  final TextEditingController controller = TextEditingController();
  String? fileName;
  File? file;
}