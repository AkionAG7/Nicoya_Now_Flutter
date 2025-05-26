import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/fetch_merchant_products_usecase.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantProductsPage extends StatefulWidget {
  /// El ID del comercio cuyos productos queremos mostrar
  final String merchantId;

  const MerchantProductsPage({
    super.key,
    required this.merchantId,
  });

  @override
  State<MerchantProductsPage> createState() => _MerchantProductsPageState();
}

class _MerchantProductsPageState extends State<MerchantProductsPage> {
  late Future<Map<String, List<Product>>> _productsByCategoryFuture;

  @override
  void initState() {
    super.initState();
    _productsByCategoryFuture = _loadProductsByCategory();
  }

  Future<Map<String, List<Product>>> _loadProductsByCategory() async {
    final supa = Supabase.instance.client;
    final ds = ProductsDataSourceImpl(supabaseClient: supa);
    final useCase = FetchMerchantProductsUseCase(ds);

    // 1) obtenemos la lista de productos para este merchant
    final products = await useCase.call(widget.merchantId);

    // 2) agrupamos por categoría
    final Map<String, List<Product>> byCat = {};
    for (var p in products) {
      byCat.putIfAbsent(p.category_id, () => []).add(p);
    }
    return byCat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos Disponibles'),
        backgroundColor: const Color(0xFFE60023),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Product>>>(
        future: _productsByCategoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final productsByCategory = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            children: [
              for (var entry in productsByCategory.entries) ...[
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: entry.value.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = entry.value[i];
                    return _ProductRow(
                      product: p,
                      onEdit:   () { /* navegar a editar p */ },
                      onDelete: () { /* eliminar p */ },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
              Center(
                child: ElevatedButton(
                  onPressed: () { /* navegar a agregar producto */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60023),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Agregar Productos',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: product.image_url != null
              ? Image.network(
                  product.image_url!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
              : Container(width: 56, height: 56, color: Colors.grey[200]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '4:00 pm',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Color(0xFFE60023)),
          onPressed: onDelete,
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFE60023)),
          onPressed: onEdit,
        ),
      ],
    );
  }
}
