import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';

class GetUserAdressUsecase {
  final AuthRepository repo;
  GetUserAdressUsecase(this.repo);

  Future<List<Address>> call(String userId) async {
    return await repo.getUserAddresses(userId);
  }
}
