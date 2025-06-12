import 'package:nicoya_now/app/core/services/role_service.dart';

class AddUserRoleUseCase {
  final RoleService _roleService;

  AddUserRoleUseCase(this._roleService);

  Future<void> execute(String userId, String roleSlug, Map<String, dynamic> roleData) async {
    // Use RoleService directly to maintain proper role isolation
    await _roleService.addRoleWithData(roleSlug, roleData);
  }
}
