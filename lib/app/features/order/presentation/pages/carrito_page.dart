import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/order/data/repositories/order_repository_impl.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/calcular_total_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/get_user_cart_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/update_carrito_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/update_quantity_carrito_usecase.dart';
import 'package:nicoya_now/app/features/order/presentation/widgets/buttom_confirmar_orden.dart';
import 'package:nicoya_now/app/features/order/presentation/widgets/item_cart.dart';
import 'package:nicoya_now/app/interface/Widgets/notification_bell.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  @override
  CarritoState createState() => CarritoState();
}

class CarritoState extends State<Carrito> {
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
          const NotificationBell(size: 35, color: Color(0xffd72a23)),
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
                        return ItemCart(
                          product: product,
                          quantity: quantity,
                          onIncrement: () => incrementarCantidad(index),
                          onDecrement: () => decrementarCantidad(index),
                          onRemove: () async {
                            final orderDatasource = OrderDatasourceImpl(
                              supabaseClient: Supabase.instance.client,
                            );
                            await orderDatasource.removeProductFromOrder(
                              item['order_item_id'],
                            );
                            await cargarProductos();
                          },
                        );
                      },
                    ),
          ),

          const SizedBox(height: 20),

          if (_items.isNotEmpty) ...[
            ButtomConfirmarOrden(
              calcularTotal: CalcularTotal(),
              items: _items,
              updateCarrito: updateCarrito,
              onConfirmed: cargarProductos,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
