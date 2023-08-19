import '../../data/repository.dart';
import '../models/firebase_result.dart';

class CheckUserState {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> checkUserState (String userId, {String? password}) async {
    return _repo.checkUserState(userId, password);
  }
}