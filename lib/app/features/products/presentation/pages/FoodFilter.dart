import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/enums/ValorVerMas_enum.dart';
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
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
import 'package:nicoya_now/app/features/products/presentation/pages/HomeFood.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodFilter extends StatefulWidget {
  const FoodFilter({Key? key}) : super(key: key);

  @override
  _FoodFilterState createState() => _FoodFilterState();
}

class _FoodFilterState extends State<FoodFilter> {
  late Future<List<Product>> _productsFuture;
  late Future<List<Product>> _postreFuture;
  late Future<List<Product>> _platoFuerteFuture;
  late Future<List<Product>> _comidaRapida;
  late Future<List<Product>> _bebidasFuture;
  late Future<dynamic> _categoriaFuture;
  late Future<List<Merchant>> _merchantsFuture;
  late String titulo;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valorVerMas categoria =
        ModalRoute.of(context)!.settings.arguments as valorVerMas;
    switch (categoria) {
      case valorVerMas.bebidas:
        _categoriaFuture = _bebidasFuture;
        titulo = 'Bebidas';
        break;

      case valorVerMas.comidaRapida:
        _categoriaFuture = _comidaRapida;
        titulo = 'Comidas rápida';
        break;

      case valorVerMas.platosFuertes:
        _categoriaFuture = _platoFuerteFuture;
        titulo = 'Platos fuertes';
        break;

      case valorVerMas.postres:
        _categoriaFuture = _postreFuture;
        titulo = 'Postres';
        break;

      case valorVerMas.todos:
        _categoriaFuture = _productsFuture;
        titulo = 'Nuestros platillos';
        break;

      case valorVerMas.merchant:
        _categoriaFuture = _merchantsFuture;
        titulo = 'Nuestros comercios';
        break;

      default:
        _categoriaFuture = _productsFuture;
        titulo = 'Nuestros platillos';
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(titulo)),
      body: SafeArea(
        child: FutureBuilder<dynamic>(
          future: _categoriaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encuentra disponible.'));
            }
            //si lo que fuera a ver serian lista de comercios
            if (snapshot.data is List<Merchant>) {
              final merchants = snapshot.data!;
              return GridView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.1,
                ),
                itemCount: merchants.length,
                itemBuilder: (context, index) {
                  final merchant = merchants[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 100,
                        child:
                            merchant.logoUrl != null
                                ? GestureDetector(
                                  onTap: () {
                                    print('Ver comercio');
                                  },
                                  child: Image.network(
                                    merchant.logoUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Text('No imagen suported'),
                      ),
                    ),
                  );
                },
              );

              // si lo que fuera a ver serian lista de productos
            } else if (snapshot.data is List<Product>) {
              final products = snapshot.data!;
              return GridView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.1,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
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
            } else {
              return const Center(child: Text('Tipo de datos desconocido.'));
            }
          },
        ),
      ),
    );
  }
}
