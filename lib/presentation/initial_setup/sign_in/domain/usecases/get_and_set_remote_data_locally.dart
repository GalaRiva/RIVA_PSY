import 'package:riva_psy/presentation/initial_setup/sign_in/data/repository.dart';

import '../models/firebase_result.dart';

class GetAndSetRemoteDataLocally {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> getAndSetRemoteDataLocally(String userId, {String? login, String? email}) async {
    return _repo.getAndSetRemoteUserLocally(userId, login: login, email: email);
  }
}