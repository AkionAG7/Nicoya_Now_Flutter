import 'package:nicoya_now/app/features/auth/domain/entities/user.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User> execute(String email, String password, {bool ignoreDriverVerification = false}) {
    return repository.signIn(email, password, ignoreDriverVerification: ignoreDriverVerification);
  }
}
