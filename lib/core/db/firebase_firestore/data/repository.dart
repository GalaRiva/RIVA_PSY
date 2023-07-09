import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listenmebaby71_s_application17/core/db/firebase_firestore/models/backup_model.dart';
import 'package:listenmebaby71_s_application17/core/models/user_data_model.dart';
import 'package:listenmebaby71_s_application17/core/utils/string_extension.dart';

import '../../../../presentation/settings/settings_promo_screen/models/promo_model.dart';
import '../../../user_data/user.dart';
import '../domain/repository.dart';

class FireStoreRepositoryImpl extends FireStoreRepository {
  final instance = FirebaseFirestore.instance;
  final String _userCollection = 'Users';
  final String _userDataCollection = 'UsersData';
  final String _userBackupsCollection = 'Backups';
  final String _promoCollection = 'Promo';
  final String _promoActivatedUsersCollection = 'ActivatedUsers';
  String _userId () => CurrentUser.repo.userId();

  @override
  Future addServiceBackup(BackupModel backupModel) async {
    await instance
        .collection(_userCollection)
        .doc(_userId())
        .collection(_userBackupsCollection)
        .add(backupModel.toJson());
  }

  @override
  Future<List<BackupModel>> getServiceBackups(String service) async {
    final collectionData = await instance
        .collection(_userCollection)
        .doc(_userId())
        .collection(_userBackupsCollection).where('service', isEqualTo: service).get();
    final listToResult = <BackupModel>[];
    for(var doc in collectionData.docs) {
      try {
        listToResult.add(BackupModel.fromJson(doc.data()));
      } catch(_) {

      }
    }
    return listToResult;
  }

  @override
  Future deleteBackupFromFireStore(BackupModel backupModel) async {
    final collectionData = await instance
        .collection(_userCollection)
        .doc(_userId())
        .collection(_userBackupsCollection).where('file_ID', isEqualTo: backupModel.file_ID).get();
    String id = collectionData.docs[0].id;
    await instance
        .collection(_userCollection)
        .doc(_userId())
        .collection(_userBackupsCollection).doc(id).delete();

  }

  @override
  Future updateUserDataPassword({required String password}) async {
    final collection = instance
        .collection(_userDataCollection)
        .doc(_userId());
    final userData = UserDataModel(number: _userId(), passwordHash: password!.md5());
    await collection.update(userData.toJson());
  }

  @override
  Future updateUserDataNumber({required String number}) async {
    final collection = instance
        .collection(_userDataCollection);
    if (!(await collection.doc(number).get()).exists) {
      final oldUserData = UserDataModel.fromJson((await collection.doc(_userId()).get()).data()!);
      final newUserData = UserDataModel(number: number, passwordHash: oldUserData.passwordHash);
      await collection.doc(number).set(newUserData.toJson());
      await collection.doc(_userId()).delete();

    }
  }

  @override
  Future<bool> canActivatePromo({required PromoModel promo}) async {
    final doc = instance.collection(_promoCollection).doc(promo.promo);
    final activatedUsersCollection = doc.collection(_promoActivatedUsersCollection);
    final activatedUsersDocs = (await doc.collection(_promoActivatedUsersCollection).get()).docs;
    if(promo is DisposablePromo) {
      if (!promo.activatedUsers.contains(_userId()) &&
          promo.maxActivated > activatedUsersDocs.length) {
        return true;
      } else if (promo is ReusablePromo) {
        if (!promo.activatedUsers.contains(_userId())) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>> getPromoModel({required String promo}) async {
    final doc = instance.collection(_promoCollection).doc(promo.toUpperCase());
    final data = (await doc.get()).data();
    if(data == null){
      return {};
    }
    else {
      final activatedUsers = (await doc.collection(_promoActivatedUsersCollection).get()).docs;
      if(activatedUsers.isNotEmpty) {
        data['activated_users'] = activatedUsers.map((e) => e.id).toList();
      }
      return data;
    }
  }

  @override
  Future<bool> activatePromo({required String promo}) async {
    try {
      final doc =
          instance.collection(_promoCollection).doc(promo.toUpperCase());
      final activatedUsersCollection =
          doc.collection(_promoActivatedUsersCollection);
      activatedUsersCollection
          .doc(_userId())
          .set({'activation_date': DateTime.now().toIso8601String()});
      return true;
    } catch (_) {
      print('activate was finished because - ' + _.toString());
      return false;
    }
  }


}
