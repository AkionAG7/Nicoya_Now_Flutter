import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/get_merchants_usecase.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/get_bebida_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/get_comida_rapida_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/get_plato_fuerte_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/get_postres_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum valorVerMas {
  postres,
  platosFuertes,
  comidaRapida,
  bebidas,
  todos,
  merchant,
}

class HomeFood extends StatefulWidget {
  const HomeFood({super.key});

  @override
  _HomeFoodState createState() => _HomeFoodState();
}

class _HomeFoodState extends State<HomeFood> {
  late Future<List<Product>> _productsFuture;
  late Future<List<Product>> _postreFuture;
  late Future<List<Product>> _platoFuerteFuture;
  late Future<List<Product>> _comidaRapida;
  late Future<List<Product>> _bebidasFuture;
  late Future<List<Merchant>> _merchantsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    final dataSource = ProductsDataSourceImpl(supabaseClient: supabase);
    final repository = ProductsRepositoryImpl(dataSource: dataSource);
    final merchantSource = SupabaseMerchantDataSource(supabase);
    final merchantRepository = MerchantRepositoryImpl(merchantSource);

    final getPostres = GetPostre(repository);
    final getAllProducts = GetAllProducts(repository);
    final getPlatoFuerte = GetPlatoFuerte(repository);
    final getComidaRapida = GetComidaRapida(repository);
    final getBebidas = GetBebidas(repository);
    final getAllMerchants = GetAllMerchants(merchantRepository);

    _productsFuture = getAllProducts();
    _postreFuture = getPostres();
    _platoFuerteFuture = getPlatoFuerte();
    _comidaRapida = getComidaRapida();
    _bebidasFuture = getBebidas();
    _merchantsFuture = getAllMerchants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text(
            'Encuentra tu plato favorito',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(NicoyaNowIcons.campana),
              onPressed: () {},
            ),
          ],
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '¿Que quieres comer hoy?',
                            prefixIcon: const Icon(Icons.storefront_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xffd72a23),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.searchFilter,
                            arguments: _searchController.text.trim(),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nuestros comercios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.food_filter,
                            arguments: valorVerMas.merchant,
                          );
                        },
                        child: Text(
                          'ver más',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd72a23),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder<List<Merchant>>(
                      future: _merchantsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay mercaderes disponibles.'),
                          );
                        }

                        final mercaderes = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: mercaderes.length,
                          itemBuilder: (context, index) {
                            final mercader = mercaderes[index];

                            return Card(
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : 8,
                                right: 8,
                                bottom: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child:
                                      mercader.logoUrl != null
                                          ? GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.product_Detail,
                                                arguments: mercader,
                                              );
                                            },
                                            child: Image.network(
                                              mercader.logoUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Text('No imagen suported'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Diversas comidas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.food_filter,
                            arguments: valorVerMas.todos,
                          );
                        },
                        child: Text(
                          'ver más',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd72a23),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay productos disponibles.'),
                          );
                        }

                        final products = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return Card(
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : 8,
                                right: 8,
                                bottom: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child:
                                      product.image_url != null
                                          ? GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.product_Detail,
                                                arguments: product,
                                              );
                                            },
                                            child: Image.network(
                                              product.image_url!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Text('No imagen suported'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Postres',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.food_filter,
                            arguments: valorVerMas.postres,
                          );
                        },
                        child: Text(
                          'ver más',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd72a23),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder<List<Product>>(
                      future: _postreFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay postres disponibles.'),
                          );
                        }

                        final postres = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: postres.length,
                          itemBuilder: (context, index) {
                            final postre = postres[index];

                            return Card(
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : 8,
                                right: 8,
                                bottom: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child:
                                      postre.image_url != null
                                          ? GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.product_Detail,
                                                arguments: postre,
                                              );
                                            },
                                            child: Image.network(
                                              postre.image_url!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Text('No imagen suported'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Platos fuertes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.food_filter,
                            arguments: valorVerMas.platosFuertes,
                          );
                        },
                        child: Text(
                          'ver más',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd72a23),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder<List<Product>>(
                      future: _platoFuerteFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay platos fuertes disponibles.'),
                          );
                        }

                        final platosFuertes = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: platosFuertes.length,
                          itemBuilder: (context, index) {
                            final platosFuerte = platosFuertes[index];

                            return Card(
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : 8,
                                right: 8,
                                bottom: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child:
                                      platosFuerte.image_url != null
                                          ? GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.product_Detail,
                                                arguments: platosFuerte,
                                              );
                                            },
                                            child: Image.network(
                                              platosFuerte.image_url!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Text('No imagen suported'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comida rápida',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.food_filter,
                            arguments: valorVerMas.comidaRapida,
                          );
                        },
                        child: Text(
                          'ver más',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd72a23),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder<List<Product>>(
                      future: _comidaRapida,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay comidas rápidas disponibles.'),
                          );
                        }

                        final comidaRapidas = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: comidaRapidas.length,
                          itemBuilder: (context, index) {
                            final comidaRapida = comidaRapidas[index];

                            return Card(
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : 8,
                                right: 8,
                                bottom: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child:
                                      comidaRapida.image_url != null
                                          ? GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.product_Detail,
                                                arguments: comidaRapida,
                                              );
                                            },
                                            child: Image.network(
                                              comidaRapida.image_url!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Text('No imagen suported'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bebidas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.food_filter,
                            arguments: valorVerMas.bebidas,
                          );
                        },
                        child: Text(
                          'ver más',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd72a23),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder<List<Product>>(
                      future: _bebidasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay bebidas disponibles.'),
                          );
                        }

                        final bebidas = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: bebidas.length,
                          itemBuilder: (context, index) {
                            final bebida = bebidas[index];

                            return Card(
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : 8,
                                right: 8,
                                bottom: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child:
                                      bebida.image_url != null
                                          ? GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.product_Detail,
                                                arguments: bebida,
                                              );
                                            },
                                            child: Image.network(
                                              bebida.image_url!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Text('No imagen suported'),
                                ),
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
        ),
      ),
    );
  }
}
