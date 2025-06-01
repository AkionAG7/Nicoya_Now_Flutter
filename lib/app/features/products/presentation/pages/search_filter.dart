import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/get_merchantSearch_usecase.dart';

import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/get_productsSeach_usecase.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class SearchFilter extends StatefulWidget {
  const SearchFilter({super.key});

  @override
  SearchFilterState createState() => SearchFilterState();
}

class SearchFilterState extends State<SearchFilter> {
  bool _initialized = false;
  late Future<List<dynamic>> _combinedResults;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final query = ModalRoute.of(context)!.settings.arguments as String;

      final supabase = Supabase.instance.client;

      final productDataSource = ProductsDataSourceImpl(
        supabaseClient: supabase,
      );
      final productRepository = ProductsRepositoryImpl(
        dataSource: productDataSource,
      );
      final getProducts = GetProductSearch(productRepository);

      final merchantDataSource = SupabaseMerchantDataSource(supabase);
      final merchantRepository = MerchantRepositoryImpl(merchantDataSource);
      final getMerchants = GetMerchantSearch(merchantRepository);

      _initialized = true;

      _combinedResults = Future.wait([
        getProducts(query),
        getMerchants(query),
      ]).then((results) {
        final products = results[0] as List<Product>;
        final merchants = results[1] as List<Merchant>;
        return [...products, ...merchants];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: const Color(0xffd72a23),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _combinedResults,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontraron resultados.'));
            }

            final items = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (item is Product) {
                  return Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              Routes.product_Detail,
                              arguments: item,
                            ),
                        child: Image.network(
                          item.image_url ?? '',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  const Center(child: Text('Sin imagen')),
                        ),
                      ),
                    ),
                  );
                } else if (item is Merchant) {
                  return Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {},
                        child: Image.network(
                          item.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  const Center(child: Text('Sin logo')),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
