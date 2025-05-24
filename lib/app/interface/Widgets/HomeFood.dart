import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/Products_data_source.dart';
import 'package:nicoya_now/app/features/auth/data/repositories/products_repository_impl.dart';
import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_plato_fuerte_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_postres_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_products_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeFood extends StatefulWidget {
  const HomeFood({super.key});

  @override
  _HomeFoodState createState() => _HomeFoodState();
}

class _HomeFoodState extends State<HomeFood> {
  late Future<List<Product>> _productsFuture;
  late Future<List<Product>> _postreFuture;
  late Future<List<Product>> _platoFuerteFuture;

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    final dataSource = ProductsDataSourceImpl(supabaseClient: supabase);
    final repository = ProductsRepositoryImpl(dataSource: dataSource);

    final getPostres = GetPostre(repository);
    final getAllProducts = GetAllProducts(repository);
    final getPlatoFuerte = GetPlatoFuerte(repository);

    _productsFuture = getAllProducts();
    _postreFuture = getPostres();
    _platoFuerteFuture = getPlatoFuerte();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'Encuentra tu plato favorito',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(NicoyaNowIcons.campana),
            onPressed: () {
              // Add your notification action here
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay productos disponibles.'),
                      );
                    }

                    final products = snapshot.data!;
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 50,
                            height: 100,
                            child:
                                product.image_url != null
                                    ? Image.network(
                                      product.image_url!,
                                      fit: BoxFit.cover,
                                    )
                                    : const Text('No imagen suported'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: 400,
                height: 400,
                child: FutureBuilder<List<Product>>(
                  future: _postreFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay postres disponibles.'),
                      );
                    }

                    final postres = snapshot.data!;
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: postres.length,
                      itemBuilder: (context, index) {
                        final postre = postres[index];

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 50,
                            height: 100,
                            child:
                                postre.image_url != null
                                    ? Image.network(
                                      postre.image_url!,
                                      fit: BoxFit.cover,
                                    )
                                    : const Text('No imagen suported'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: 400,
                height: 400,
                child: FutureBuilder<List<Product>>(
                  future: _platoFuerteFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay platos fuertes disponibles.'),
                      );
                    }

                    final platosFuertes = snapshot.data!;
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: platosFuertes.length,
                      itemBuilder: (context, index) {
                        final platosFuerte = platosFuertes[index];

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 50,
                            height: 100,
                            child:
                                platosFuerte.image_url != null
                                    ? Image.network(
                                      platosFuerte.image_url!,
                                      fit: BoxFit.cover,
                                    )
                                    : const Text('No imagen suported'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
