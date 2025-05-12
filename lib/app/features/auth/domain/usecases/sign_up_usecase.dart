import 'package:nicoya_now/app/features/auth/domain/entities/user.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';


class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User> execute(
    String email,
    String password, {
    String? firstName,
    String? lastName1,
    String? lastName2,
    String? phone,
    String? address,
  }) {
    return repository.signUp(
      email,
      password,
      firstName: firstName,
      lastName1: lastName1,
      lastName2: lastName2,
      phone: phone,
      address: address,
    );
  }
}
