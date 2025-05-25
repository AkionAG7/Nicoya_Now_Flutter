import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';

class FetchMerchantProductsUseCase {
  final ProductsDataSource _productsDs;
  FetchMerchantProductsUseCase(this._productsDs);

  /// Llama al método que filtra por merchantId
  Future<List<Product>> call(String merchantId) {
    return _productsDs.fetchProductsByMerchant(merchantId);
  }
}
