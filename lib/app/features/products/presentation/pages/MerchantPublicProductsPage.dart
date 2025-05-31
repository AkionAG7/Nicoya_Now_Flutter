import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/fetch_merchant_products_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/notification_bell.dart';

class MerchantPublicProductsPage extends StatefulWidget {
  const MerchantPublicProductsPage({super.key});

  @override
  State<MerchantPublicProductsPage> createState() => _MerchantPublicProductsPageState();
}

class _MerchantPublicProductsPageState extends State<MerchantPublicProductsPage> {
  late Future<List<Product>> _productsFuture;
  late Merchant merchant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    merchant = ModalRoute.of(context)!.settings.arguments as Merchant;
    final supabase = Supabase.instance.client;
    final ds = ProductsDataSourceImpl(supabaseClient: supabase);
    final uc = FetchMerchantProductsUseCase(ds);
    _productsFuture = uc.call(merchant.merchantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos de ${merchant.businessName}'),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('Este comercio no tiene productos disponibles.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, index) {
              final p = products[index];
              return Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.product_Detail,
                      arguments: p,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: p.image_url != null
                            ? Image.network(p.image_url!, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 50),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '₡${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFFd72a23)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
