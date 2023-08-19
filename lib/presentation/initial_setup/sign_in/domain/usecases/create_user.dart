import '../../data/repository.dart';
import '../models/firebase_result.dart';

class CreateUser {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> createUser (
      {String? email,
      String? number,
      String? service,
      String? password}) async {
    return _repo.createUser(password: password, email: email, number: number, service: service);
  }
}