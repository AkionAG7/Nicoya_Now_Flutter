import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/enums/ValorVerMas_enum.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/home_food_search.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/merchant_view.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/products_views.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/ver_mas_producto.dart';
import 'package:nicoya_now/app/interface/Widgets/notification_bell.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeFood extends StatefulWidget {
  const HomeFood({super.key});

  @override
  HomeFoodState createState() => HomeFoodState();
}

class HomeFoodState extends State<HomeFood> {
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
            const NotificationBell(size: 35, color: Color(0xffd72a23)),
            const SizedBox(width: 8),
          ],
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                children: [
                  HomeFoodSearch(searchController: _searchController),

                  const SizedBox(height: 40),
                  VerMasProducto(
                    title: 'Nuestros comercios',
                    valor: valorVerMas.merchant,
                  ),

                  MerchantView(merchantsFuture: _merchantsFuture),

                  const SizedBox(height: 20),

                  VerMasProducto(
                    title: 'Diversas comidas',
                    valor: valorVerMas.todos,
                  ),

                  ProductsViews(productsFuture: _productsFuture),

                  SizedBox(height: 20),

                  VerMasProducto(title: 'Postres', valor: valorVerMas.postres),

                  ProductsViews(productsFuture: _postreFuture),

                  SizedBox(height: 20),

                  VerMasProducto(
                    title: 'Platos fuertes',
                    valor: valorVerMas.platosFuertes,
                  ),

                  ProductsViews(productsFuture: _platoFuerteFuture),

                  SizedBox(height: 20),

                  VerMasProducto(
                    title: 'Comidas rápidas',
                    valor: valorVerMas.comidaRapida,
                  ),

                  ProductsViews(productsFuture: _comidaRapida),

                  SizedBox(height: 20),

                  VerMasProducto(title: 'Bebidas', valor: valorVerMas.bebidas),

                  ProductsViews(productsFuture: _bebidasFuture),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
