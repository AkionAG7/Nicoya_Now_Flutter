import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/features/auth/domain/entities/user.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);
  @override
  Future<User> signIn(String email, String password, {bool ignoreDriverVerification = false}) async {
    try {
      final userData = await dataSource.signIn(email, password, ignoreDriverVerification: ignoreDriverVerification);
      return _mapToUser(userData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> signUp(
    String email,
    String password, {
    String? firstName,
    String? lastName1,
    String? lastName2,
    String? phone,
    String? address,
  }) async {
    try {
      final userData = await dataSource.signUp(email, password);
      final String userId = userData['id'];

      await dataSource.updateProfile(userId, {
        'first_name': firstName,
        'last_name1': lastName1,
        'last_name2': lastName2,
        'phone': phone,
      });

      if (address != null && address.isNotEmpty) {
        await dataSource.createAddress(userId, {
          'street': address,
          'district': '',
          'lat': null,
          'lng': null,
          'note': '',
        });
      }
      return User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName1: lastName1,
        lastName2: lastName2,
        phone: phone,
        role:
            '', // No asignamos rol automáticamente, se hará explícitamente según el flujo de registro
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userData = await dataSource.getCurrentUser();
    if (userData == null) return null;
    return _mapToUser(userData);
  }

  @override
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await dataSource.updateProfile(userId, data);
  }

  @override
  Future<List<String>> getUserRoles(String userId) async {
    return await dataSource.getRolesForUser(userId);
  }

  @override
  Future<void> assignRoleToUser(
    String userId,
    String roleId,
    Map<String, dynamic> roleData,
  ) async {
    await dataSource.addRoleToUser(userId, roleId, roleData);
  }

  @override
  Future<bool> getMerchantVerificationStatus(String userId) async {
    return await dataSource.getMerchantVerificationStatus(userId);
  }

  @override
  Future<bool> getDriverVerificationStatus(String userId) async {
    return await dataSource.getDriverVerificationStatus(userId);
  }

  User _mapToUser(Map<String, dynamic> userData) {
    return User(
      id: userData['id'],
      email: userData['email'],
      firstName: userData['first_name'],
      lastName1: userData['last_name1'],
      lastName2: userData['last_name2'],
      phone: userData['phone'],
      role: userData['role'] ?? '', // No asignamos un rol por defecto
    );
  }

  @override
  Future<void> updateUserInfo({
    required String userId,
    required String phone,
    required String address,
  }) async {
    await dataSource.updateUserInfo(
      userId: userId,
      phone: phone,
      address: address,
    );
  }

  @override
  Future<List<Address>> getUserAddresses(String userId) async {
    return await dataSource.getUserAddress(userId);
  }
  
}
