import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({required this.orderId, Key? key}) : super(key: key);

  /// Carga datos de la orden incluyendo dirección y productos
  Future<Map<String, dynamic>> _loadData() async {
    final client = Supabase.instance.client;

    final result = await client
        .from('order')
        .select('''
          order_id,
          customer_id,
          merchant_id,
          total,
          placed_at,
          status,
          delivery_address:delivery_address_id ( street ),
          items:order_item (
            order_item_id,
            quantity,
            product:product_id ( name, price )
          )
        ''')
        .eq('order_id', orderId)
        .maybeSingle();

    if (result == null) throw Exception('No se encontró la orden $orderId');
    return Map<String, dynamic>.from(result as Map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Orden')), 
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data!;
          final street = (data['delivery_address'] as Map<String, dynamic>?)?['street'] as String? ?? '-';
          final items = data['items'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Cliente: ${data['customer_id']}'),
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: Text('Comerciante: ${data['merchant_id']}'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('Dirección: $street'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text('Total: \$${(data['total'] as num).toDouble().toStringAsFixed(2)}'),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Fecha: ${DateTime.parse(data['placed_at'] as String).toLocal()}'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text('Estado: ${(data['status'] as String).toUpperCase()}'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...items.map((item) {
                final m = item as Map<String, dynamic>;
                final prod = m['product'] as Map<String, dynamic>;
                final qty = m['quantity'] as int;
                return ListTile(
                  title: Text(prod['name'] as String),
                  subtitle: Text('Cantidad: $qty'),
                  trailing: Text('\$${(prod['price'] as num).toDouble().toStringAsFixed(2)}'),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
