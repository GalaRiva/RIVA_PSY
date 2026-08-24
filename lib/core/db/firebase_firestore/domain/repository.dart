import '../../../../presentation/settings/settings_promo_screen/models/promo_model.dart';
import '../../../models/tariff_model.dart';
import '../models/backup_model.dart';

abstract class FireStoreRepository {

  Future<List<BackupModel>> getServiceBackups (String service);

  Future addServiceBackup (BackupModel backupModel);

  Future deleteBackupFromFireStore (BackupModel backupModel);

  Future updateUserDataPassword ({required String password});

  Future updateUserDataNumber ({required String number});

  Future updateUser ({
   required String userId,
    String? login,
    String? email,
    int? old,
    bool? male,
    TariffModel? currentTariff,
    DateTime? registrationDate,
    DateTime? quizCompletedAt,
    String? quizLeadingTrait,
    bool create,
    Function? onError
  });

  Future<Map<String, dynamic>> getPromoModel ({required String promo});

  Future<bool> activatePromo ({required String promo});

  Future<bool> canActivatePromo ({required PromoModel promo});

  Future<bool> canUseTrial ({required String trialName});

  // Reads the welcome-offer anchor back — used by the main-screen banner to
  // decide whether the 24h window is still open after the user closed the
  // paywall without buying (quizCompletedAt itself is only held in memory
  // for the session where the quiz just finished).
  Future<DateTime?> getQuizCompletedAt ();

  // Generic per-account "seen it once" gate — same doc-existence idiom as
  // canUseTrial/useTrial above, just under its own collection so flag names
  // don't collide with trial names.
  Future<bool> hasCompletedOneTimeFlag ({required String flagName});

  Future<bool> completeOneTimeFlag ({required String flagName});

  Future<bool> createPostInFirestoreDatabase ({required String selectedCollection,
    required String docPath, required Map<String, dynamic> content});
}