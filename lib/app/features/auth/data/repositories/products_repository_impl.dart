import 'package:nicoya_now/app/features/auth/data/datasources/Products_data_source.dart';
import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDataSource dataSource;
  ProductsRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getAllProducts() => dataSource.fetchAllProducts();

  @override
  Future<List<Product>> getPostre() => dataSource.fetchPostreProducts();

    @override
  Future<List<Product>> getPlatoFuerte() => dataSource.fetchPlatoFuerteProduct();

    @override
  Future<List<Product>> getBebida() => dataSource.fetchBebidaProduct();

    @override
  Future<List<Product>> getComidaRapida() => dataSource.fetchComidaRapidaProduct();
}
