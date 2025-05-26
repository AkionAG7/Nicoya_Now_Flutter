import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

// Helper class for the LoginPage
class LoginPageHelper {
  /// Updates the switch case in the role selection dialog to handle admin role
  static Widget buildRoleSelectionDialog(BuildContext context, AuthController authController) {
    // Lista de roles disponibles para mostrar
    final roles = authController.userRoles;
    
    return AlertDialog(
      title: const Text('Selecciona tu rol'),
      content: SingleChildScrollView(
        child: ListBody(
          children: roles.map((role) {
            String title;
            IconData icon;
            
            // Configurar título e icono según el rol
            switch (role) {
              case 'customer':
                title = 'Cliente';
                icon = Icons.person;
                break;
              case 'driver':
                title = 'Repartidor';
                icon = Icons.delivery_dining;
                break;
              case 'merchant':
                title = 'Comerciante';
                icon = Icons.store;
                break;
              case 'admin':
                title = 'Administrador';
                icon = Icons.admin_panel_settings;
                break;
              default:
                title = 'Usuario';
                icon = Icons.person;
            }
            
            return ListTile(
              leading: Icon(icon, color: const Color(0xffd72a23)),
              title: Text(title),
              onTap: () {
                // Manejar selección del rol
                switch (role) {
                  case 'customer':
                    Navigator.pushNamedAndRemoveUntil(
                      context, Routes.home_food, (route) => false);
                    break;
                  case 'driver':
                    Navigator.pushNamedAndRemoveUntil(
                      context, Routes.home_food, (route) => false);
                    break;
                  case 'merchant':
                    Navigator.pushNamedAndRemoveUntil(
                      context, Routes.home_merchant, (route) => false);
                    break;
                  case 'admin':
                    Navigator.pushNamedAndRemoveUntil(
                      context, Routes.home_admin, (route) => false);
                    break;
                  default:
                    Navigator.pushNamedAndRemoveUntil(
                      context, Routes.home_food, (route) => false);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  /// Updates the switch case for direct redirection when user has only one role
  static void redirectBasedOnRole(BuildContext context, String userRole) {
    switch (userRole) {
      case 'customer':
        Navigator.pushNamedAndRemoveUntil(
          context, Routes.home_food, (route) => false);
        break;
      case 'driver':
        Navigator.pushNamedAndRemoveUntil(
          context, Routes.home_food, (route) => false);
        break;
      case 'merchant':
        Navigator.pushNamedAndRemoveUntil(
          context, Routes.home_merchant, (route) => false);
        break;
      case 'admin':
        Navigator.pushNamedAndRemoveUntil(
          context, Routes.home_admin, (route) => false);
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
          context, Routes.home_food, (route) => false);
    }
  }
}
