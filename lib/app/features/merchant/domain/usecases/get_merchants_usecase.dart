import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';

class GetAllMerchants {
  final MerchantRepository repo;
  GetAllMerchants(this.repo);
  Future<List<Merchant>> call() => repo.getAllMerchants();
}
