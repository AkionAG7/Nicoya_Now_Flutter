import 'package:nicoya_now/app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, {
    String? firstName,
    String? lastName1,
    String? lastName2,
    String? phone,
    String? address,
  });
  Future<void> signOut();
  Future<User?> getCurrentUser();
  
  Future<bool> isSignedIn();
  Future<void> resetPassword(String email);
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
    // New methods for role management
  Future<List<String>> getUserRoles(String userId);
  Future<void> assignRoleToUser(String userId, String roleId, Map<String, dynamic> roleData);
  
  // Methods for verification status
  Future<bool> getMerchantVerificationStatus(String userId);
  Future<bool> getDriverVerificationStatus(String userId);
}
