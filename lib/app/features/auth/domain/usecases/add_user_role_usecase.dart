import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';

class AddUserRoleUseCase {
  final AuthRepository repository;

  AddUserRoleUseCase(this.repository);

  Future<void> execute(String userId, String roleId, Map<String, dynamic> roleData) async {
    await repository.assignRoleToUser(userId, roleId, roleData);
  }
}
