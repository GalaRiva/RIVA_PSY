import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:riva_psy/core/db/firebase_firestore/models/backup_model.dart';
import 'package:riva_psy/core/models/tariff_model.dart';
import 'package:riva_psy/core/models/user_data_model.dart';
import 'package:riva_psy/core/utils/string_extension.dart';

import '../../../../presentation/settings/settings_promo_screen/models/promo_model.dart';
import '../../../models/user_model.dart';
import '../../../user_data/user.dart';
import '../domain/repository.dart';

class FireStoreRepositoryImpl extends FireStoreRepository {
  final instance = FirebaseFirestore.instance;
  final String _userCollection = 'Users';
  final String _userDataCollection = 'UsersData';
  final String _userBackupsCollection = 'Backups';
  final String _promoCollection = 'Promo';
  final String _promoActivatedUsersCollection = 'ActivatedUsers';
  final String _trialsCollection = 'Trials';


  String _userId() => CurrentUser.repo.userId();

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
        .collection(_userBackupsCollection)
        .where('service', isEqualTo: service)
        .get();
    final listToResult = <BackupModel>[];
    for (var doc in collectionData.docs) {
      try {
        listToResult.add(BackupModel.fromJson(doc.data()));
      } catch (_) {}
    }
    return listToResult;
  }

  @override
  Future deleteBackupFromFireStore(BackupModel backupModel) async {
    final collectionData = await instance
        .collection(_userCollection)
        .doc(_userId())
        .collection(_userBackupsCollection)
        .where('file_ID', isEqualTo: backupModel.file_ID)
        .get();
    String id = collectionData.docs[0].id;
    await instance
        .collection(_userCollection)
        .doc(_userId())
        .collection(_userBackupsCollection)
        .doc(id)
        .delete();
  }

  @override
  Future updateUserDataPassword({required String password}) async {
    final collection = instance.collection(_userDataCollection).doc(_userId());
    final userData =
        UserDataModel(number: _userId(), passwordHash: password!.md5());
    await collection.update(userData.toJson());
  }

  @override
  Future updateUserDataNumber({required String number}) async {
    final collection = instance.collection(_userDataCollection);
    if (!(await collection.doc(number).get()).exists) {
      final oldUserData = UserDataModel.fromJson(
          (await collection.doc(_userId()).get()).data()!);
      final newUserData =
          UserDataModel(number: number, passwordHash: oldUserData.passwordHash);
      await collection.doc(number).set(newUserData.toJson());
      await collection.doc(_userId()).delete();
    }
  }

  @override
  Future<bool> canActivatePromo({required PromoModel promo}) async {
    if (promo is DisposablePromo) {
      debugPrint('promo request on ${_userId()}');
      if (!promo.activatedUsers.contains(_userId()) &&
          promo.maxActivated > promo.activatedUsers.length) {
        return true;
      }
      } else if (promo is ReusablePromo) {
      if (!promo.activatedUsers.contains(_userId())) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>> getPromoModel({required String promo}) async {
    final doc = instance.collection(_promoCollection).doc(promo.toUpperCase());
    final data = (await doc.get()).data();
    if (data == null) {
      return {};
    } else {
      final activatedUsers =
          (await doc.collection(_promoActivatedUsersCollection).get()).docs;
      if (activatedUsers.isNotEmpty) {
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

  @override
  Future updateUser(
      {required String userId,
      UserModel? user,
      String? login,
      String? email,
      int? old,
      bool? male,
      TariffModel? currentTariff,
      DateTime? registrationDate,
      DateTime? quizCompletedAt,
      String? quizLeadingTrait,
      bool create = false,
      Function? onError}) async {
    // TODO: implement updateUser
    Map<String, dynamic> userDataForUpdate = {};
    if (user != null) {
      userDataForUpdate = user.userToFirebase();
    } else {
      if (login != null) userDataForUpdate['login'] = login;
      if (email != null) userDataForUpdate['email'] = email;
      if (old != null) userDataForUpdate['old'] = old;
      if (male != null) userDataForUpdate['male'] = male;
      if (currentTariff != null) {
        userDataForUpdate['tariff'] = currentTariff.name;
        userDataForUpdate['tariff_is_end'] =
            currentTariff.endDate.toIso8601String();
      }
      if (registrationDate != null)
        userDataForUpdate['registration_date'] =
            registrationDate.toIso8601String();
      // quiz_completed_at is the server-side anchor for the welcome-offer
      // countdown — deliberately never derived from device time.
      if (quizCompletedAt != null)
        userDataForUpdate['quiz_completed_at'] =
            quizCompletedAt.toIso8601String();
      if (quizLeadingTrait != null)
        userDataForUpdate['quiz_leading_trait'] = quizLeadingTrait;
    }
    try {
      final doc = instance.collection(_userCollection).doc(userId);
      if (!create) {
        await doc.update(userDataForUpdate);
      } else {
        await doc.set(userDataForUpdate);
      }
    } catch (e) {
      // Was a bare `catch (_) { if (onError != null) onError(); }` with the
      // actual .update()/.set() calls not awaited — the write could fail
      // (or just never finish before the app moved on) with no error ever
      // reaching a caller, no log, nothing. That's how a registration could
      // "succeed" locally while Users/{userId} was never actually created
      // in Firestore. Kept swallowing here (several callers fire this
      // without awaiting it) but now actually awaits the write and logs the
      // failure — getAndSetRemoteUserLocally passes onError to detect this
      // specific case and surface a real error instead of reporting success.
      print('[USERS-WRITE] updateUser(userId: $userId, create: $create) failed: $e');
      if (onError != null) onError();
    }
  }

  @override
  Future<bool> createPostInFirestoreDatabase(
      {required String selectedCollection,
      required String docPath,
      required Map<String, dynamic> content}) async {
    try {
      final doc = instance.collection(selectedCollection).doc(docPath);
     await doc.set(content);
      return true;
    } catch (_) {
      return false;
      print(_);
    }
  }

  @override
  Future<DateTime?> getQuizCompletedAt() async {
    try {
      if (_userId().isEmpty) return null;
      final doc = await instance.collection(_userCollection).doc(_userId()).get();
      final raw = doc.data()?['quiz_completed_at'] as String?;
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> canUseTrial({required String trialName}) async {
    try {
      if(_userId().isEmpty) return false;
      final doc = instance.collection(_trialsCollection).doc(trialName).collection('users').doc(_userId());
      final docref = await doc.get();
      return docref.data() == null;
    }catch (_) {
      debugPrint(" $_");
      return false;
    }
  }

  @override
  Future<bool> useTrial({required String trialName}) async {
    try {
      final doc = instance.collection(_trialsCollection).doc(trialName);
      final coll = doc.collection('users');
      await coll.doc(_userId()).set({'use' : true});
      return true;
    }catch (_) {
      return false;
    }
  }

  final String _oneTimeFlagsCollection = 'OneTimeFlags';

  @override
  Future<bool> hasCompletedOneTimeFlag({required String flagName}) async {
    try {
      if (_userId().isEmpty) return false;
      final doc = instance
          .collection(_oneTimeFlagsCollection)
          .doc(flagName)
          .collection('users')
          .doc(_userId());
      return (await doc.get()).data() != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> completeOneTimeFlag({required String flagName}) async {
    try {
      if (_userId().isEmpty) return false;
      await instance
          .collection(_oneTimeFlagsCollection)
          .doc(flagName)
          .collection('users')
          .doc(_userId())
          .set({'completed_at': DateTime.now().toIso8601String()});
      return true;
    } catch (_) {
      return false;
    }
  }
}
