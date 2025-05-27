import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';

class GetUserRolesUseCase {
  final AuthRepository repository;

  GetUserRolesUseCase(this.repository);

  Future<List<String>> execute(String userId) async {
    return await repository.getUserRoles(userId);
  }
}
