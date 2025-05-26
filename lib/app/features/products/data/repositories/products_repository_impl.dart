import 'package:nicoya_now/app/features/products/data/datasources/Products_data_source.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDataSource dataSource;
  ProductsRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getproductSearch(String query) => dataSource.fetchBySearch(query);

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
