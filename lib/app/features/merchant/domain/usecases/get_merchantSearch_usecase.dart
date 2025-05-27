import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';

class GetMerchantSearch{
  final MerchantRepository repo;
  GetMerchantSearch(this.repo);
  Future<List<Merchant>> call(String query) => repo.getMerchantSearch(query);
}