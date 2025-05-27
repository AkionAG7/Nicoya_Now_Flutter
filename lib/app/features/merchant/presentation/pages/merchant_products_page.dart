import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/fetch_merchant_products_usecase.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantProductsPage extends StatefulWidget {
  final String merchantId;
  const MerchantProductsPage({Key? key, required this.merchantId})
      : super(key: key);

  @override
  State<MerchantProductsPage> createState() => _MerchantProductsPageState();
}

class _MerchantProductsPageState extends State<MerchantProductsPage> {
  late Future<List<Product>> _productsFuture;

  // Aquí defines tus secciones con el nombre y el UUID de categoría
  final List<_CategorySection> _sections = [
    _CategorySection(name: 'Plato fuerte',      categoryId: '54912ce6-db1b-4178-8fc2-d8ce0323f199'),
    _CategorySection(name: 'Postres',             categoryId: '2ff6dcda-6625-44ac-bbc5-9beb6f066803'),
    _CategorySection(name: 'Comida rápida',       categoryId: 'f549b092-e486-4b40-ab12-891fd3321f77'),
    _CategorySection(name: 'Bebidas',             categoryId: 'c1812c32-c9f7-4ee4-badf-a0c435cc0760'),
  ];

  @override
@override
void initState() {
  super.initState();
  // Aquí inicializas _productsFuture
  final supa = Supabase.instance.client;
  final ds   = ProductsDataSourceImpl(supabaseClient: supa);
  final uc   = FetchMerchantProductsUseCase(ds);
  _productsFuture = uc.call(widget.merchantId);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos Disponibles'),
        titleTextStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        backgroundColor: const Color(0xFFE60023),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final products = snap.data!;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              for (var section in _sections) ...[
                // filtrar productos que coincidan con esta categoría
                if (products.any((p) => p.category_id == section.categoryId)) ...[
                  Text(
                    section.name,
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products
                        .where((p) => p.category_id == section.categoryId)
                        .length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = products
                          .where((p) => p.category_id == section.categoryId)
                          .toList()[i];
                      return _ProductRow(
                        product: p,
 onEdit: () {
  Navigator.pushNamed(
    context,
    Routes.editProduct,
    arguments: p, // 👈 p es el producto actual que se está editando
  ).then((_) {
    // Recargar productos después de editar
    setState(() {
      final supa = Supabase.instance.client;
      final ds = ProductsDataSourceImpl(supabaseClient: supa);
      final uc = FetchMerchantProductsUseCase(ds);
      _productsFuture = uc.call(widget.merchantId);
    });
  });
},
                        onDelete: () { /* eliminar p */ },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],
              Center(
                child: ElevatedButton(
             onPressed: () {
  Navigator.pushNamed(context, Routes.addProduct, arguments: widget.merchantId);
},

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

/// Clase auxiliar para definir cada sección de categoría
class _CategorySection {
  final String name;
  final String categoryId;
  _CategorySection({required this.name, required this.categoryId});
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: product.image_url != null
              ? Image.network(
                  product.image_url!,
                  width: 56, height: 56, fit: BoxFit.cover)
              : Container(width: 56, height: 56, color: Colors.grey[200]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Text('\₡${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        IconButton(
          icon:
              const Icon(Icons.remove_circle, color: Color(0xFFE60023)),
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
