import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductsDataSource {
  Future<List<Product>> fetchAllProducts();
  Future<List<Product>> fetchPostreProducts();
  Future<List<Product>> fetchPlatoFuerteProduct();
  Future<List<Product>> fetchBebidaProduct();
  Future<List<Product>> fetchComidaRapidaProduct();
}

class ProductsDataSourceImpl implements ProductsDataSource {
  final SupabaseClient supabaseClient;

  ProductsDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Product>> fetchAllProducts() async {
    final response = await supabaseClient.from('product').select();
    return _mapResponseToProducts(response);
  }

  @override
  Future<List<Product>> fetchPostreProducts() =>
      _fetchProductsByCategoryName('Postre');

  @override
  Future<List<Product>> fetchPlatoFuerteProduct() =>
      _fetchProductsByCategoryName('Plato fuerte');

  @override
  Future<List<Product>> fetchBebidaProduct() =>
      _fetchProductsByCategoryName('Bebida');

  @override
  Future<List<Product>> fetchComidaRapidaProduct() =>
      _fetchProductsByCategoryName('Comida rápida');

  Future<List<Product>> _fetchProductsByCategoryName(
    String categoryName,
  ) async {
    // Paso 1: obtener el ID de la categoría
    final categoryResponse =
        await supabaseClient
            .from('category')
            .select('category_id')
            .eq('name', categoryName)
            .maybeSingle();

    if (categoryResponse == null) {
      print('⚠️ Categoría "$categoryName" no encontrada.');
      return [];
    }

    final categoryId = categoryResponse['category_id'];

    // Paso 2: obtener los productos filtrados por ese ID
    final response = await supabaseClient
        .from('product')
        .select()
        .eq('category_id', categoryId);

    return _mapResponseToProducts(response);
  }

  List<Product> _mapResponseToProducts(dynamic response) {
    return (response as List).map((item) {
      return Product(
        product_id: item['product_id'] as String,
        merchant_id: item['merchant_id'] as String,
        name: item['name'] as String,
        description: item['description'] as String,
        price: item['price'] as double,
        image_url: item['image_url'] as String?,
        is_activate: item['is_active'] ?? true,
        created_at: DateTime.parse(item['created_at']),
        category_id: item['category_id'] as String,
      );
    }).toList();
  }
}
