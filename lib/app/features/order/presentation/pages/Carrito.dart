import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Carrito extends StatefulWidget {
  const Carrito({Key? key}) : super(key: key);

  @override
  _CarritoState createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    final supa = Supabase.instance.client;
    final userId = supa.auth.currentUser?.id;

    if (userId != null) {
      final orderDatasource = OrderDatasourceImpl(supabaseClient: supa);
      _productsFuture = orderDatasource.getOrderByUserId(userId);
    } else {
      _productsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'Tu carrito',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(NicoyaNowIcons.campana),
            onPressed: () {},
          ),
        ],
      ),

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos en el carrito'));
          }

          final productos = snapshot.data!;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return ListTile(
                leading:
                    producto.image_url != null
                        ? Image.network(producto.image_url!)
                        : const Icon(Icons.image),
                title: Text(producto.name),
                subtitle: Text('₡${producto.price.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
