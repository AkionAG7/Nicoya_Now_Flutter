import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

abstract class ProductsRepository {
  Future<List<Product>> getproductSearch(String query);
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getPostre();
  Future<List<Product>> getPlatoFuerte();
  Future<List<Product>> getBebida();
  Future<List<Product>> getComidaRapida();
  Future<List<Product>> addProduct(Product product);
  Future<List<Product>> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
}
