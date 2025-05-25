import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';


class RoleController extends ChangeNotifier {
  RoleController(this._roleService);
  final RoleService _roleService;

  Future<void> ensureRole(String slug) async {
    if (!await _roleService.hasRole(slug)) {
      await _roleService.addRoleIfNotExists(slug);
    }
  }
}
