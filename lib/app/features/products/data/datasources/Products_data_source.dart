import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductsDataSource {
  Future<List<Product>> fetchAllProducts();
  Future<List<Product>> fetchPostreProducts();
  Future<List<Product>> fetchPlatoFuerteProduct();
  Future<List<Product>> fetchBebidaProduct();
  Future<List<Product>> fetchComidaRapidaProduct();

  /// Nuevo: obtiene productos filtrados por merchant_id
  Future<List<Product>> fetchProductsByMerchant(String merchantId);
  Future<List<Product>> fetchBySearch(String query);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
}

class ProductsDataSourceImpl implements ProductsDataSource {
  final SupabaseClient supabaseClient;

  ProductsDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> deleteProduct(String productId) async {
    final response =
        await supabaseClient
            .from('product')
            .delete()
            .eq('product_id', productId)
            .select();

    if (response.isEmpty) {
      throw Exception(
        'Failed to delete product: No product found with the given ID.',
      );
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    final response =
        await supabaseClient
            .from('product')
            .update({
              'name': product.name,
              'description': product.description,
              'price': product.price,
              'image_url': product.image_url,
              'category_id': product.category_id,
              'is_active': product.is_activate,
            })
            .eq('product_id', product.product_id)
            .select(); // ← importante para obtener respuesta válida

    if (response.isEmpty) {
      throw Exception('No se pudo actualizar el producto.');
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    try {
      await supabaseClient.from('product').insert({
        'product_id': product.product_id,
        'merchant_id': product.merchant_id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'image_url': product.image_url,
        'is_active': product.is_activate,
        'created_at': product.created_at.toIso8601String(),
        'category_id': product.category_id,
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error al agregar producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchBySearch(String query) async {
    final response = await supabaseClient
        .from('product')
        .select()
        .ilike('name', '%$query%');

    return _mapResponseToProducts(response);
  }

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

  @override
  Future<List<Product>> fetchProductsByMerchant(String merchantId) async {
    final response = await supabaseClient
        .from('product')
        .select()
        .eq('merchant_id', merchantId);

    return _mapResponseToProducts(response);
  }

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
      // ignore: avoid_print
      print('Categoría "$categoryName" no encontrada.');
      return [];
    }

    final categoryId = categoryResponse['category_id'] as String;

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
        price: (item['price'] as num).toDouble(),
        image_url: item['image_url'] as String?,
        is_activate: item['is_active'] as bool? ?? true,
        created_at: DateTime.parse(item['created_at'] as String),
        category_id: item['category_id'] as String,
      );
    }).toList();
  }
}
