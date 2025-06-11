import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';

class UpdateCustomerInfoCase{
  final AuthRepository repo;
  UpdateCustomerInfoCase(this.repo);

  Future<void> call( {required String userId,required String phone, required String address}) async {
    await repo.updateUserInfo(userId: userId, phone: phone, address: address);
  }
}