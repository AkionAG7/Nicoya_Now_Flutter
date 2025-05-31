import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
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

  Future<void> cargarProductos() async {
    final supa = Supabase.instance.client;
    final userId = supa.auth.currentUser?.id;

    if (userId != null) {
      final orderDatasource = OrderDatasourceImpl(supabaseClient: supa);
      final data = await orderDatasource.getOrderByUserId(userId);
      setState(() {
        _items = data;
      });
    }
  }

  double calcularTotal() {
    return _items.fold(0.0, (total, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      return total + (product.price * quantity);
    });
  }

  void incrementarCantidad(int index) {
    setState(() {
      _items[index]['quantity']++;
    });
  }

  void decrementarCantidad(int index) {
    setState(() {
      if (_items[index]['quantity'] > 1) {
        _items[index]['quantity']--;
      }
    });
  }

  Future<void> actualizarCarrito() async {
    final supabase = Supabase.instance.client;
    bool _isSaving = true;

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, double> orderTotals = {};

      for (final item in _items) {
        final orderItemId = item['order_item_id'];
        final quantity = item['quantity'];
        final product = item['product'] as Product;

        // 1. Actualizar la cantidad en Supabase
        final updated =
            await supabase
                .from('order_item')
                .update({'quantity': quantity})
                .eq('order_item_id', orderItemId)
                .select('order_id, unit_price')
                .single();

        final String orderId = updated['order_id'];
        final double unitPrice = (updated['unit_price'] as num).toDouble();
        final double subtotal = unitPrice * quantity;

        // 2. Acumular total por orden
        orderTotals[orderId] = (orderTotals[orderId] ?? 0) + subtotal;
      }

      // 3. Actualizar totales en tabla order
      for (final entry in orderTotals.entries) {
        await supabase
            .from('order')
            .update({'total': entry.value})
            .eq('order_id', entry.key);
      }

      print('✔️ Carrito actualizado correctamente');
    } catch (e) {
      print('❌ Error actualizando carrito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los cambios')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Esto se llama cada vez que la pestaña se vuelve visible
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      cargarProductos();
    }
  }

  @override
  void initState() {
    super.initState();
    final supa = Supabase.instance.client;
    final userId = supa.auth.currentUser?.id;
    cargarProductos();

    if (userId != null) {
      final orderDatasource = OrderDatasourceImpl(supabaseClient: supa);
      orderDatasource.getOrderByUserId(userId).then((data) {
        setState(() {
          _items = data;
        });
      });
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
                  actualizarCarrito();
                  final total = calcularTotal();
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
