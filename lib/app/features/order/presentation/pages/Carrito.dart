import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/order/data/repositories/order_repository_impl.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/calcular_total_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/get_user_cart_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/update_carrito_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/update_quantity_carrito_usecase.dart';
import 'package:nicoya_now/app/interface/Widgets/notification_bell.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Carrito extends StatefulWidget {
  const Carrito({Key? key}) : super(key: key);

  @override
  _CarritoState createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  List<Map<String, dynamic>> _items = [];
  late final GetUserCart getUserCart;
  late final CalcularTotal calcularTotal;
  late final UpdateQuantityCarrito updateQuantityCarrito;
  late final UpdateCarrito updateCarrito;

  Future<void> cargarProductos() async {
    final data = await getUserCart();
    setState(() {
      _items = data;
    });
  }

  void incrementarCantidad(int index) {
    setState(() {
      _items = updateQuantityCarrito(
        items: _items,
        index: index,
        increment: true,
      );
    });
  }

  void decrementarCantidad(int index) {
    setState(() {
      _items = updateQuantityCarrito(
        items: _items,
        index: index,
        increment: false,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      cargarProductos();
    }
  }

  @override
  void initState() {
    super.initState();
    final supa = Supabase.instance.client;
    final orderDatasource = OrderDatasourceImpl(supabaseClient: supa);
    final orderRepository = OrderRepositoryImpl(datasource: orderDatasource);
    getUserCart = GetUserCart(repo: orderRepository);
    calcularTotal = CalcularTotal();
    updateQuantityCarrito = UpdateQuantityCarrito();
    updateCarrito = UpdateCarrito(repo: orderRepository);
    cargarProductos();
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
          const NotificationBell(size: 28, color: Color(0xffd72a23)),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child:
                _items.isEmpty
                    ? const Center(
                      child: Text('No hay productos en el carrito'),
                    )
                    : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        Product product = item['product'];
                        int quantity = item['quantity'];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        product.image_url!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),

                                      Text(
                                        'Precio : ${product.price * quantity} CRC',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9B9B9B),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final orderDatasource =
                                              OrderDatasourceImpl(
                                                supabaseClient:
                                                    Supabase.instance.client,
                                              );
                                          await orderDatasource
                                              .removeProductFromOrder(
                                                item['order_item_id'],
                                              );
                                          await cargarProductos(); // para refrescar el estado del carrito
                                        },
                                        child: Text(
                                          'Eliminar',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFf10027),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFfee6e9),
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                onPressed:
                                                    () => decrementarCantidad(
                                                      index,
                                                    ),
                                                icon: Icon(
                                                  NicoyaNowIcons.menos,
                                                  size: 10,
                                                  color: Color(0xFFf10027),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Text(quantity.toString()),

                                          const SizedBox(width: 10),

                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFfee6e9),
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                onPressed:
                                                    () => incrementarCantidad(
                                                      index,
                                                    ),
                                                icon: Icon(
                                                  NicoyaNowIcons.mas,
                                                  size: 10,
                                                  color: Color(0xFFf10027),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 250,
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFf10027),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await updateCarrito(_items);
                  final total = calcularTotal(_items);
                  Navigator.pushNamed(context, Routes.pago, arguments: total);
                  await cargarProductos();
                },
                child: Text(
                  'Confirmar orden',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
