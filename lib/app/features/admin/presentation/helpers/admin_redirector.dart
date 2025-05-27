import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

// This is an extension class that provides admin-specific functionality
// to avoid modifying the original code
class AdminRedirector {
  // Call this method when handling login redirection
  static void redirectBasedOnRole(BuildContext context, String userRole) {
    if (userRole == 'admin') {
      // Redirect to admin home page
      Navigator.pushNamedAndRemoveUntil(
        context, 
        Routes.home_admin, 
        (route) => false
      );
    }
    // For other roles, the default behavior in LoginPage will apply
  }
  
  // Helper method to determine if a role is an admin
  static bool isAdmin(String role) {
    return role == 'admin';
  }
  
  // Use this to check if the user has admin role
  static bool hasAdminRole(AuthController authController) {
    return authController.hasRole('admin');
  }
}
